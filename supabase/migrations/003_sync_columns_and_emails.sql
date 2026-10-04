alter table public.tasks
  add column google_task_id text,
  add column synced_at timestamptz;

create table public.emails (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  to_name text,
  to_email text not null,
  subject text not null,
  body text not null,
  status text not null default 'approved'
    check (status in ('approved', 'sent', 'failed')),
  gmail_message_id text,
  error_message text,
  source_transcript text,
  capture_id uuid references public.voice_captures(id),
  sent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.emails enable row level security;
create policy "emails_select_own" on public.emails
  for select using (user_id = auth.uid());
create policy "emails_insert_own" on public.emails
  for insert with check (user_id = auth.uid());

create table public.contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  name text not null,
  email text not null,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

alter table public.contacts enable row level security;
create policy "contacts_own" on public.contacts
  for all using (user_id = auth.uid()) with check (user_id = auth.uid());