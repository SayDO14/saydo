import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_settings.dart';
import '../../core/config.dart';
import 'parse_result.dart';

enum VoiceStatus { idle, recording, uploading, done, error }

/// What went wrong. The UI maps each value to a localized message, so no
/// user-facing text lives in this file.
enum VoiceError { micDenied, nothingRecorded, network, server }

class VoiceState {
  const VoiceState({this.status = VoiceStatus.idle, this.result, this.error});
  final VoiceStatus status;
  final ParseResult? result;
  final VoiceError? error;
}

final voiceControllerProvider =
    NotifierProvider<VoiceController, VoiceState>(VoiceController.new);

class VoiceController extends Notifier<VoiceState> {
  /// Safety net: a forgotten recording is stopped and sent after this long.
  static const maxRecording = Duration(minutes: 2);

  final _recorder = AudioRecorder();
  Timer? _maxTimer;
  String? _currentPath;

  @override
  VoiceState build() {
    ref.onDispose(() {
      _maxTimer?.cancel();
      _recorder.dispose();
    });
    return const VoiceState();
  }

  void reset() => state = const VoiceState();

  /// Tap once to start, tap again to stop and send.
  Future<void> toggle() async {
    switch (state.status) {
      case VoiceStatus.recording:
        await _stopAndSend();
      case VoiceStatus.uploading:
        break; // ignore taps while waiting for the agent
      default:
        await _start();
    }
  }

  /// Aborts an in-progress recording without sending anything (sheet closed).
  Future<void> cancel() async {
    if (state.status != VoiceStatus.recording) return;
    _maxTimer?.cancel();
    try {
      await _recorder.cancel();
    } catch (e) {
      debugPrint('voice: cancel failed: $e');
    }
    _deleteQuietly(_currentPath);
    _currentPath = null;
    state = const VoiceState();
  }

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      state = const VoiceState(
        status: VoiceStatus.error,
        error: VoiceError.micDenied,
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/saydo_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 16000, numChannels: 1),
      path: path,
    );
    _currentPath = path;
    state = const VoiceState(status: VoiceStatus.recording);
    _maxTimer?.cancel();
    _maxTimer = Timer(maxRecording, () {
      if (state.status == VoiceStatus.recording) _stopAndSend();
    });
  }

  Future<void> _stopAndSend() async {
    _maxTimer?.cancel();
    final path = await _recorder.stop();
    _currentPath = null;
    if (path == null) {
      state = const VoiceState(
        status: VoiceStatus.error,
        error: VoiceError.nothingRecorded,
      );
      return;
    }
    state = const VoiceState(status: VoiceStatus.uploading);
    try {
      final result = await _upload(File(path));
      state = VoiceState(status: VoiceStatus.done, result: result);
    } on TimeoutException catch (e) {
      debugPrint('voice: timeout: $e');
      state = const VoiceState(status: VoiceStatus.error, error: VoiceError.network);
    } on SocketException catch (e) {
      debugPrint('voice: socket error: $e');
      state = const VoiceState(status: VoiceStatus.error, error: VoiceError.network);
    } on http.ClientException catch (e) {
      debugPrint('voice: client error: $e');
      state = const VoiceState(status: VoiceStatus.error, error: VoiceError.network);
    } catch (e) {
      debugPrint('voice: agent error: $e');
      state = const VoiceState(status: VoiceStatus.error, error: VoiceError.server);
    } finally {
      _deleteQuietly(path);
    }
  }

  Future<ParseResult> _upload(File file) async {
    final request = http.MultipartRequest('POST', Uri.parse('${AppConfig.agentUrl}/saydo-parse'))
      ..fields['timezone'] = ref.read(timezoneProvider)
      ..fields['client_now'] = DateTime.now().toIso8601String()
      ..files.add(await http.MultipartFile.fromPath('audio', file.path));

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final response = await http.Response.fromStream(
      await request.send().timeout(const Duration(seconds: 60)),
    );

    // Check the status first: a 502/500 often carries an HTML body that
    // would blow up jsonDecode with a confusing FormatException.
    if (response.statusCode != 200) {
      throw 'agent HTTP ${response.statusCode}: ${_snippet(response.bodyBytes)}';
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      throw 'agent returned invalid JSON: ${_snippet(response.bodyBytes)}';
    }

    final result = ParseResult.fromJson(json);
    if (result.status == 'error') throw 'agent reported an error';
    return result;
  }

  static String _snippet(List<int> bytes) {
    final s = utf8.decode(bytes, allowMalformed: true);
    return s.length > 200 ? '${s.substring(0, 200)}…' : s;
  }

  void _deleteQuietly(String? path) {
    if (path == null) return;
    File(path).delete().ignore();
  }
}
