import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saydo/l10n/app_localizations.dart';

import '../confirm/proposal_sheet.dart';
import '../contacts/contacts_repository.dart';
import '../emails/emails_repository.dart';
import '../events/events_repository.dart';
import '../tasks/tasks_repository.dart';
import 'parse_result.dart';
import 'voice_controller.dart';

/// True while the voice bottom sheet (opened from Events/Tasks/Emails) is on
/// screen. Home stays mounted inside the IndexedStack and also listens to the
/// voice controller; this flag tells it to stand down so only one flow reacts.
class VoiceSheetOpen extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool open) => state = open;
}

final voiceSheetOpenProvider =
    NotifierProvider<VoiceSheetOpen, bool>(VoiceSheetOpen.new);

/// Localized message for a [VoiceError].
String voiceErrorText(AppLocalizations l, VoiceError? error) => switch (error) {
      VoiceError.micDenied => l.voiceErrorMic,
      VoiceError.nothingRecorded => l.voiceErrorNothing,
      VoiceError.network => l.voiceErrorNetwork,
      VoiceError.server => l.voiceErrorServer,
      null => l.errorGeneric,
    };

/// The ONE place that turns a parsed voice capture into a confirmation sheet.
///
/// Both the Home mic and the voice bottom sheet end up here. Having a single
/// path matters: Home stays alive inside the IndexedStack, so two independent
/// listeners used to open two proposal sheets for the same capture.
Future<void> presentProposal(
  BuildContext context,
  WidgetRef ref,
  ParseResult result,
) async {
  if (!result.isProposal) return;

  final outcome = await showModalBottomSheet<ProposalOutcome>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    builder: (_) => ProposalSheet(result: result),
  );

  if (!context.mounted) return;
  ref.read(voiceControllerProvider.notifier).reset();

  if (outcome == ProposalOutcome.saved) {
    refreshAfterSave(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(AppLocalizations.of(context)!.voiceSaved)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// A saved capture can create an event, a task, an email and a contact.
/// Refresh all of them everywhere so no list shows stale data.
void refreshAfterSave(WidgetRef ref) {
  ref.invalidate(eventsProvider);
  ref.invalidate(tasksProvider);
  ref.invalidate(emailsProvider);
  ref.invalidate(contactsProvider);
}
