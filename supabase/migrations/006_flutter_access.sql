-- Access for the Flutter app (role: authenticated).
-- Until now only emails and contacts were granted; events, tasks and
-- voice_captures were written by save_test.py through service_role.

-- The app also records emails as a capture intent.
alter table public.voice_captures
  drop constraint if exists voice_captures_intent_check;
alter table public.voice_captures
  add constraint voice_captures_intent_check
  check (intent in ('event', 'task', 'email', 'unknown'));

grant select, insert, update, delete on public.events, public.tasks to authenticated;
grant select, insert, update on public.voice_captures to authenticated;

alter table public.events enable row level security;
alter table public.tasks enable row level security;
alter table public.voice_captures enable row level security;

drop policy if exists "events_own" on public.events;
create policy "events_own" on public.events
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "tasks_own" on public.tasks;
create policy "tasks_own" on public.tasks
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists "voice_captures_own" on public.voice_captures;
create policy "voice_captures_own" on public.voice_captures
  for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
