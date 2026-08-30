create type public.app_role as enum ('admin', 'educator', 'family');
create type public.daily_log_type as enum ('check_in', 'check_out', 'meal', 'nap', 'diaper', 'home_note', 'school_note', 'activity');

create table public.centers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  created_at timestamptz not null default now()
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  created_at timestamptz not null default now()
);

create table public.center_memberships (
  center_id uuid not null references public.centers(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role public.app_role not null,
  created_at timestamptz not null default now(),
  primary key (center_id, user_id)
);

create table public.classrooms (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

create table public.children (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  classroom_id uuid references public.classrooms(id) on delete set null,
  full_name text not null,
  birth_date date,
  allergies text,
  created_at timestamptz not null default now()
);

create table public.child_guardians (
  child_id uuid not null references public.children(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  relationship text not null,
  can_pick_up boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (child_id, user_id)
);

create table public.daily_logs (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  author_id uuid references public.profiles(id) on delete set null,
  log_type public.daily_log_type not null,
  occurred_at timestamptz not null default now(),
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table public.announcements (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  title text not null,
  body text not null,
  published_at timestamptz,
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.calendar_events (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  title text not null,
  starts_on date not null,
  ends_on date,
  is_closed_day boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.menus (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  menu_date date not null,
  first_course text,
  second_course text,
  dessert text,
  created_at timestamptz not null default now(),
  unique (center_id, menu_date)
);

alter table public.centers enable row level security;
alter table public.profiles enable row level security;
alter table public.center_memberships enable row level security;
alter table public.classrooms enable row level security;
alter table public.children enable row level security;
alter table public.child_guardians enable row level security;
alter table public.daily_logs enable row level security;
alter table public.announcements enable row level security;
alter table public.calendar_events enable row level security;
alter table public.menus enable row level security;

create or replace function public.is_center_member(target_center_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.center_memberships
    where center_id = target_center_id
      and user_id = auth.uid()
  );
$$;

create or replace function public.is_child_guardian(target_child_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.child_guardians
    where child_id = target_child_id
      and user_id = auth.uid()
  );
$$;

create policy "Users can read own profile"
on public.profiles for select
to authenticated
using (id = auth.uid());

create policy "Members can read their centers"
on public.centers for select
to authenticated
using (public.is_center_member(id));

create policy "Users can read own memberships"
on public.center_memberships for select
to authenticated
using (user_id = auth.uid());

create policy "Members can read center classrooms"
on public.classrooms for select
to authenticated
using (public.is_center_member(center_id));

create policy "Members and guardians can read children"
on public.children for select
to authenticated
using (public.is_center_member(center_id) or public.is_child_guardian(id));

create policy "Guardians can read their links"
on public.child_guardians for select
to authenticated
using (user_id = auth.uid() or public.is_child_guardian(child_id));

create policy "Members and guardians can read daily logs"
on public.daily_logs for select
to authenticated
using (
  public.is_child_guardian(child_id)
  or exists (
    select 1
    from public.children c
    where c.id = child_id
      and public.is_center_member(c.center_id)
  )
);

create policy "Members can read announcements"
on public.announcements for select
to authenticated
using (public.is_center_member(center_id));

create policy "Members can read calendar events"
on public.calendar_events for select
to authenticated
using (public.is_center_member(center_id));

create policy "Members can read menus"
on public.menus for select
to authenticated
using (public.is_center_member(center_id));
