# Google-only sign-in, open to everyone

## Files in this zip
- auth/*.dart            -> replace lib/features/auth/ (gmail_sender.dart is DELETED, remove it)
- confirm/save_service.dart -> replace lib/features/confirm/save_service.dart
- confirm/proposal_data.dart, confirm/proposal_sheet.dart -> REBUILT (were missing from the project). If you still have your originals, keep them and skip these two.
- core/date_format.dart -> now also defines isoWithOffset(). If you already have it elsewhere, remove one copy.

## Steps
1. pubspec.yaml: remove `http` if nothing else uses it.
2. Google Cloud Console > APIs & Services > OAuth consent screen:
   - Data access / Scopes: only openid, email, profile (remove gmail.send).
   - Audience > "Publish app" -> status "In production".
     Basic scopes need NO Google verification, so anyone can sign in.
3. Supabase > Authentication > Providers > Google: enabled with your
   client ID/secret. URL Configuration: add your app redirect URL.
4. n8n: workflow reacts to emails.status = 'approved' again and sends.
   Re-activate your Send Gmail branch; tell your teammate NOT to disable it.
5. Sign out, sign in with Google, test.

## Notes
- Emails are sent by n8n, not from each user's own Gmail.
- Never commit the Google client secret or Supabase service key to GitHub.
