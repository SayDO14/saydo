import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contacts_repository.dart';
import 'package:saydo/l10n/app_localizations.dart';

/// Add (contact == null) or edit a contact. Pops true when saved.
Future<bool?> showContactSheet(BuildContext context, {Contact? contact}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => ContactSheet(contact: contact),
  );
}

class ContactSheet extends ConsumerStatefulWidget {
  const ContactSheet({super.key, this.contact});
  final Contact? contact;

  @override
  ConsumerState<ContactSheet> createState() => _ContactSheetState();
}

class _ContactSheetState extends ConsumerState<ContactSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.contact?.name);
  late final _email = TextEditingController(text: widget.contact?.email);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(contactsRepositoryProvider).save(
            id: widget.contact?.id,
            name: _name.text,
            email: _email.text,
          );
      ref.invalidate(contactsProvider);
      if (mounted) Navigator.pop(context, true);
    } on DuplicateContactException {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = AppLocalizations.of(context)!.contactDuplicate;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = AppLocalizations.of(context)!.saveError('$e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final editing = widget.contact != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(editing ? AppLocalizations.of(context)!.contactEdit : AppLocalizations.of(context)!.contactNew, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fieldName, border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context)!.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.fieldEmailAddress, border: OutlineInputBorder()),
                validator: (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v?.trim() ?? '')
                    ? null
                    : AppLocalizations.of(context)!.invalidEmail,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
