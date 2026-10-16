import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saydo/l10n/app_localizations.dart';

import '../../core/date_format.dart';
import '../voice/parse_result.dart';
import 'proposal_data.dart';
import 'save_service.dart';

/// How the confirmation sheet was closed.
enum ProposalOutcome { saved, rejected }

/// Bottom sheet that shows what the agent understood (event / task / email)
/// so the user can correct it, then confirm or cancel.
class ProposalSheet extends ConsumerStatefulWidget {
  const ProposalSheet({super.key, required this.result});
  final ParseResult result;

  @override
  ConsumerState<ProposalSheet> createState() => _ProposalSheetState();
}

class _ProposalSheetState extends ConsumerState<ProposalSheet> {
  final _formKey = GlobalKey<FormState>();
  late ProposalData _data = ProposalData.fromResult(widget.result);

  late final _title = TextEditingController(text: _data.title);
  late final _people = TextEditingController(text: _data.people.join(', '));
  late final _toName = TextEditingController(text: _data.toName);
  late final _toEmail = TextEditingController(text: _data.toEmail);
  late final _subject = TextEditingController(text: _data.subject);
  late final _body = TextEditingController(text: _data.body);

  bool _saving = false;
  bool _showDateTimeError = false;
  String? _error;

  bool get _isEvent => _data.type == 'event';
  bool get _isEmail => _data.type == 'email';

  @override
  void initState() {
    super.initState();
    if (_isEmail && _data.toName.trim().isNotEmpty) _prefillEmail();
  }

  @override
  void dispose() {
    for (final c in [_title, _people, _toName, _toEmail, _subject, _body]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "email Sarah" -> fill her saved address, if we have one.
  Future<void> _prefillEmail() async {
    final email = await ref.read(saveServiceProvider).findContactEmail(_data.toName);
    if (mounted && email != null && _toEmail.text.trim().isEmpty) {
      _toEmail.text = email;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _data.date ?? DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _data = _data.copyWith(date: DateTime(picked.year, picked.month, picked.day)));
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _data.time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _data = _data.copyWith(time: picked));
  }

  /// Copies the text fields into the data object.
  ProposalData _collect() => _data.copyWith(
        title: _title.text,
        people: _people.text
            .split(RegExp(r'[,،]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        toName: _toName.text,
        toEmail: _toEmail.text,
        subject: _subject.text,
        body: _body.text,
      );

  Future<void> _confirm() async {
    final formOk = _formKey.currentState!.validate();
    final missingWhen = _isEvent && (_data.date == null || _data.time == null);
    setState(() => _showDateTimeError = missingWhen);
    if (!formOk || missingWhen) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(saveServiceProvider).confirm(widget.result, _collect());
      if (mounted) Navigator.pop(context, ProposalOutcome.saved);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = AppLocalizations.of(context)!.saveError('$e');
        });
      }
    }
  }

  Future<void> _cancel() async {
    setState(() => _saving = true);
    await ref.read(saveServiceProvider).reject(widget.result);
    if (mounted) Navigator.pop(context, ProposalOutcome.rejected);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final heading = switch (_data.type) {
      'event' => l.proposalNewEvent,
      'email' => l.proposalNewEmail,
      _ => l.proposalNewTask,
    };
    String req(String? v) => (v == null || v.trim().isEmpty) ? l.required : '';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(heading, style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                if (_isEmail) ..._emailFields(l, req) else ..._eventTaskFields(l, req),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _cancel,
                        child: Text(l.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _saving ? null : _confirm,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l.confirm),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _eventTaskFields(AppLocalizations l, String Function(String?) req) {
    final theme = Theme.of(context);
    return [
      TextFormField(
        controller: _title,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l.fieldTitle, border: const OutlineInputBorder()),
        validator: (v) {
          final m = req(v);
          return m.isEmpty ? null : m;
        },
      ),
      const SizedBox(height: 12),
      InkWell(
        onTap: _pickDate,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: _isEvent ? l.fieldDate : l.fieldDueDateOptional,
            border: const OutlineInputBorder(),
            suffixIcon: (!_isEvent && _data.date != null)
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _data = _data.copyWith(clearDate: true)),
                  )
                : const Icon(Icons.calendar_today),
          ),
          child: Text(_data.date != null ? formatDayLabel(_data.date!) : l.noDate),
        ),
      ),
      if (_isEvent) ...[
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickTime,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l.fieldTime,
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.access_time),
            ),
            child: Text(
              _data.time != null
                  ? formatClock(DateTime(2000, 1, 1, _data.time!.hour, _data.time!.minute))
                  : '—',
            ),
          ),
        ),
        if (_showDateTimeError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(l.required, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
          ),
      ],
      const SizedBox(height: 12),
      TextFormField(
        controller: _people,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: l.fieldPeople, border: const OutlineInputBorder()),
      ),
    ];
  }

  List<Widget> _emailFields(AppLocalizations l, String Function(String?) req) {
    return [
      TextFormField(
        controller: _toName,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(labelText: l.fieldToName, border: const OutlineInputBorder()),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _toEmail,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        decoration: InputDecoration(labelText: l.fieldEmailAddress, border: const OutlineInputBorder()),
        validator: (v) {
          final s = (v ?? '').trim();
          if (s.isEmpty) return l.required;
          return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s) ? null : l.invalidEmail;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _subject,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: l.fieldSubject, border: const OutlineInputBorder()),
        validator: (v) {
          final m = req(v);
          return m.isEmpty ? null : m;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _body,
        minLines: 4,
        maxLines: 10,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: l.fieldMessage,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
        validator: (v) {
          final m = req(v);
          return m.isEmpty ? null : m;
        },
      ),
    ];
  }
}
