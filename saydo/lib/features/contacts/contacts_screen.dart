import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets.dart';
import 'contact_sheet.dart';
import 'contacts_repository.dart';

class ContactsScreen extends ConsumerWidget {
  const ContactsScreen({super.key});

  Future<void> _delete(BuildContext context, WidgetRef ref, Contact c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete contact?'),
        content: Text('${c.name} (${c.email}) will be removed. Past emails are not affected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(contactsRepositoryProvider).delete(c.id);
      ref.invalidate(contactsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contacts')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add contact',
        onPressed: () => showContactSheet(context),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: contacts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: 'Could not load your contacts.\n$e',
          onRetry: () => ref.invalidate(contactsProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(contactsProvider.future),
          child: items.isEmpty
              ? const EmptyView(
                  icon: Icons.contacts_outlined,
                  message: 'No contacts yet.\nAdd one here, or they are saved\nautomatically when you send an email.',
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) {
                    final c = items[i];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase()),
                      ),
                      title: Text(c.name),
                      subtitle: Text(c.email),
                      onTap: () => showContactSheet(context, contact: c),
                      trailing: IconButton(
                        tooltip: 'Delete',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, ref, c),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
