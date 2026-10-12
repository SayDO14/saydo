import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice/parse_result.dart';
import 'proposal_data.dart';
import 'save_service.dart';
import 'package:saydo/l10n/app_localizations.dart';

enum ProposalOutcome { saved, rejected }

/// Bottom sheet: shows what the agent understood, lets the user fix it,
/// and only then creates anything. Pops with a [ProposalOutcome].
class ProposalSheet extends ConsumerStatefulWidget {
  const ProposalSheet({super.key, required this.result});
  final ParseResult result;

  @override
  ConsumerState<ProposalSheet> createState() => _ProposalSheetState();
}

class _ProposalSheetState extends ConsumerState<ProposalSheet> {
  final _formKey = GlobalKey<FormState>();
  late final ProposalData _data = ProposalData.fromResult(widget.result);

  late final _title = TextEditingController(text: _data.title);
  late final _people = TextEditingController(text: _data.people.join(', '));
  late final _toName = TextEditingController(text: _data.toName);
  late final _toEmail = TextEditingController();
  late final _subject = TextEditingController(text: _data.subject);
  late final _body = TextEditingController(text: _data.body);

  bool _saving = false;
  String? _error;

  bool get _isEvent => _data.type == 'event';
  bool get _isEmail => _data.type == 'email';

  @override
  void initState() {
    super.initState();
    if (_isEmail) _prefillEmail();
  }

  Future<void> _prefillEmail() async {
    final email = await ref.read(saveServiceProvider).findContactEmail(_data.toName);
    if (mounted && email != null && _toEmail.text.isEmpty) _toEmail.text = email;
  }

  @override
  void dispose() {
    for (final c in [_title, _people, _toName, _toEmail, _subject, _body]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _data.date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _data.date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _data.time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _data.time = picked);
  }

  void _readFields() {
    _data
      ..title = _title.text
      ..toName = _toName.text
      ..toEmail = _toEmail.text
      ..subject = _subject.text
      ..body = _body.text
      ..people = _people.text
          .split(',')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
  }

  Future<void> _confirm() async {
    if (!_formKey.currentState!.validate()) return;
    _readFields();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(saveServiceProvider).confirm(widget.result, _data);
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

  Future<void> _reject() async {
    await ref.read(saveServiceProvider).reject(widget.result);
    if (mounted) Navigator.pop(context, ProposalOutcome.rejected);
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.required : null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = switch (_data.type) {
      'event' => AppLocalizations.of(context)!.proposalNewEvent,
      'email' => AppLocalizations.of(context)!.proposalNewEmail,
      _ => AppLocalizations.of(context)!.proposalNewTask,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(heading, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '"${widget.result.transcript}"',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              if (_isEmail) ..._emailFields() else ..._eventTaskFields(),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _reject,
                      child: Text(AppLocalizations.of(context)!.cancel),
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
                          : Text(AppLocalizations.of(context)!.confirm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _eventTaskFields() => [
        TextFormField(
          controller: _title,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fieldTitle, border: OutlineInputBorder()),
          validator: _required,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PickerField(
                label: _isEvent ? AppLocalizations.of(context)!.fieldDate : AppLocalizations.of(context)!.fieldDueDateOptional,
                value: _data.date == null ? null : formatDate(_data.date!),
                icon: Icons.calendar_today,
                onTap: _pickDate,
                onClear: _isEvent ? null : () => setState(() => _data.date = null),
                required: _isEvent,
                requiredText: AppLocalizations.of(context)!.required,
              ),
            ),
            if (_isEvent) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _PickerField(
                  label: AppLocalizations.of(context)!.fieldTime,
                  value: _data.time == null ? null : formatTime(_data.time!),
                  icon: Icons.access_time,
                  onTap: _pickTime,
                  required: true,
                  requiredText: AppLocalizations.of(context)!.required,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _people,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.fieldPeople,
            border: OutlineInputBorder(),
          ),
        ),
      ];

  List<Widget> _emailFields() => [
        TextFormField(
          controller: _toName,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fieldToName, border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _toEmail,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fieldEmailAddress, border: OutlineInputBorder()),
          validator: (v) {
            final t = v?.trim() ?? '';
            return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t) ? null : AppLocalizations.of(context)!.invalidEmail;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _subject,
          decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fieldSubject, border: OutlineInputBorder()),
          validator: _required,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _body,
          minLines: 4,
          maxLines: 10,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.fieldMessage,
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
          validator: _required,
        ),
      ];
}

/// Read-only field that opens a picker; shows an error when required and empty.
class _PickerField extends FormField<String> {
  _PickerField({
    required String label,
    required String? value,
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onClear,
    bool required = false,
    required String requiredText,
  }) : super(
          initialValue: value,
          validator: (_) => required && value == null ? requiredText : null,
          builder: (state) => InkWell(
            onTap: onTap,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                errorText: state.errorText,
                suffixIcon: value != null && onClear != null
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
                    : Icon(icon),
              ),
              child: Text(value ?? ' '),
            ),
          ),
        );
}
