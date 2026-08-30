create type public.attendance_event_type as enum ('check_in', 'check_out');
create type public.message_category as enum (
  'absence',
  'meal',
  'schedule',
  'administration',
  'educator',
  'health',
  'other'
);
create type public.media_kind as enum ('photo', 'video', 'document');

create table public.authorized_pickups (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  full_name text not null,
  relationship text not null,
  document_id text,
  phone text,
  valid_from timestamptz,
  valid_until timestamptz,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.attendance_events (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  event_type public.attendance_event_type not null,
  occurred_at timestamptz not null default now(),
  actor_id uuid references public.profiles(id) on delete set null,
  pickup_person_name text,
  notes text,
  created_at timestamptz not null default now()
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  sender_id uuid references public.profiles(id) on delete set null,
  category public.message_category not null default 'other',
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.media_assets (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  classroom_id uuid references public.classrooms(id) on delete set null,
  kind public.media_kind not null,
  storage_path text not null,
  title text,
  activity text,
  taken_on date,
  uploaded_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

alter table public.authorized_pickups enable row level security;
alter table public.attendance_events enable row level security;
alter table public.messages enable row level security;
alter table public.media_assets enable row level security;

create policy "Members and guardians can read authorized pickups"
on public.authorized_pickups for select
to authenticated
using (
  public.is_child_guardian(child_id)
  or exists (
    select 1 from public.children c
    where c.id = child_id and public.is_center_member(c.center_id)
  )
);

create policy "Admins can manage authorized pickups"
on public.authorized_pickups for all
to authenticated
using (
  exists (
    select 1 from public.children c
    where c.id = child_id
      and public.is_center_role(c.center_id, array['admin']::public.app_role[])
  )
)
with check (
  exists (
    select 1 from public.children c
    where c.id = child_id
      and public.is_center_role(c.center_id, array['admin']::public.app_role[])
  )
);

create policy "Members and guardians can read attendance"
on public.attendance_events for select
to authenticated
using (public.is_center_member(center_id) or public.is_child_guardian(child_id));

create policy "Members can create attendance"
on public.attendance_events for insert
to authenticated
with check (
  public.is_center_role(center_id, array['admin', 'educator']::public.app_role[])
  or public.is_child_guardian(child_id)
);

create policy "Members and guardians can read messages"
on public.messages for select
to authenticated
using (
  public.is_center_member(center_id)
  or (child_id is not null and public.is_child_guardian(child_id))
);

create policy "Members and guardians can create messages"
on public.messages for insert
to authenticated
with check (
  public.is_center_member(center_id)
  or (child_id is not null and public.is_child_guardian(child_id))
);

create policy "Members and guardians can read media"
on public.media_assets for select
to authenticated
using (
  public.is_center_member(center_id)
  or (child_id is not null and public.is_child_guardian(child_id))
);

create policy "Members can create media"
on public.media_assets for insert
to authenticated
with check (
  public.is_center_role(center_id, array['admin', 'educator']::public.app_role[])
);

create index authorized_pickups_child_idx on public.authorized_pickups(child_id);
create index attendance_events_child_time_idx on public.attendance_events(child_id, occurred_at desc);
create index messages_center_time_idx on public.messages(center_id, created_at desc);
create index messages_child_time_idx on public.messages(child_id, created_at desc);
create index media_assets_center_date_idx on public.media_assets(center_id, taken_on desc);
create index media_assets_child_date_idx on public.media_assets(child_id, taken_on desc);
