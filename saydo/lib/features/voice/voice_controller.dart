import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import 'parse_result.dart';

enum VoiceStatus { idle, recording, uploading, done, error }

class VoiceState {
  const VoiceState({this.status = VoiceStatus.idle, this.result, this.error});
  final VoiceStatus status;
  final ParseResult? result;
  final String? error;
}

final voiceControllerProvider =
    NotifierProvider<VoiceController, VoiceState>(VoiceController.new);

class VoiceController extends Notifier<VoiceState> {
  final _recorder = AudioRecorder();

  @override
  VoiceState build() {
    ref.onDispose(_recorder.dispose);
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

  Future<void> _start() async {
    if (!await _recorder.hasPermission()) {
      state = const VoiceState(
        status: VoiceStatus.error,
        error: 'Microphone permission denied.',
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/saydo_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 16000, numChannels: 1),
      path: path,
    );
    state = const VoiceState(status: VoiceStatus.recording);
  }

  Future<void> _stopAndSend() async {
    final path = await _recorder.stop();
    if (path == null) {
      state = const VoiceState(status: VoiceStatus.error, error: 'Nothing recorded.');
      return;
    }
    state = const VoiceState(status: VoiceStatus.uploading);
    try {
      final result = await _upload(File(path));
      state = VoiceState(status: VoiceStatus.done, result: result);
    } catch (e) {
      state = VoiceState(status: VoiceStatus.error, error: 'Could not reach the agent: $e');
    } finally {
      File(path).delete().ignore();
    }
  }

  Future<ParseResult> _upload(File file) async {
    final request = http.MultipartRequest('POST', Uri.parse('${AppConfig.agentUrl}/saydo-parse'))
      ..fields['timezone'] = 'Africa/Algiers' // TODO: take from profile (settings feature)
      ..fields['client_now'] = DateTime.now().toIso8601String()
      ..files.add(await http.MultipartFile.fromPath('audio', file.path));

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    final response = await http.Response.fromStream(
      await request.send().timeout(const Duration(seconds: 60)),
    );
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final result = ParseResult.fromJson(json);
    if (response.statusCode != 200 || result.status == 'error') {
      throw 'agent error (${response.statusCode})';
    }
    return result;
  }
}
