create table public.profiles (
  id uuid primary key references auth.users(id),
  email text not null,
  display_name text,
  avatar_url text,
  timezone text not null default 'Africa/Algiers',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.voice_captures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  raw_transcript text not null,
  audio_path text,
  detected_langs text[] not null default '{}',
  stt_model text,
  llm_model text,
  parsed_json jsonb,
  final_json jsonb,
  intent text check (intent in ('event', 'task', 'unknown')),
  status text not null default 'pending'
    check (status in ('pending', 'confirmed', 'edited', 'rejected', 'failed')),
  error_message text,
  latency_ms integer,
  use_in_testset boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  title text not null check (length(btrim(title)) > 0),
  description text,
  location text,
  start_at timestamptz not null,
  end_at timestamptz,
  all_day boolean not null default false,
  timezone text,
  related_people jsonb not null default '[]'::jsonb
    check (jsonb_typeof(related_people) = 'array'),
  source_transcript text,
  capture_id uuid references public.voice_captures(id),
  google_event_id text,
  synced_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  title text not null check (length(btrim(title)) > 0),
  notes text,
  due_at timestamptz,
  due_has_time boolean not null default false,
  priority smallint not null default 0 check (priority between 0 and 3),
  status text not null default 'todo' check (status in ('todo', 'done', 'cancelled')),
  completed_at timestamptz,
  related_people jsonb not null default '[]'::jsonb
    check (jsonb_typeof(related_people) = 'array'),
  source_transcript text,
  capture_id uuid references public.voice_captures(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);