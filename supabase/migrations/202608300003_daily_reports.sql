create type public.meal_amount as enum ('all', 'most', 'little', 'none');
create type public.sleep_quality as enum ('good', 'bad', 'none');

create table public.daily_reports (
  id uuid primary key default gen_random_uuid(),
  center_id uuid not null references public.centers(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  report_date date not null default current_date,
  breakfast public.meal_amount not null default 'all',
  lunch public.meal_amount not null default 'most',
  snack public.meal_amount not null default 'little',
  morning_bowel_movement boolean not null default false,
  afternoon_bowel_movement boolean not null default false,
  morning_sleep public.sleep_quality not null default 'none',
  morning_sleep_time text,
  afternoon_sleep public.sleep_quality not null default 'none',
  afternoon_sleep_time text,
  school_notes text,
  home_notes text,
  medication text,
  created_by uuid references public.profiles(id) on delete set null,
  updated_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (child_id, report_date)
);

alter table public.daily_reports enable row level security;

create or replace function public.is_center_role(
  target_center_id uuid,
  allowed_roles public.app_role[]
)
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
      and role = any(allowed_roles)
  );
$$;

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  new.updated_by = auth.uid();
  return new;
end;
$$;

create trigger daily_reports_touch_updated_at
before update on public.daily_reports
for each row execute function public.touch_updated_at();

create policy "Members and guardians can read daily reports"
on public.daily_reports for select
to authenticated
using (
  public.is_child_guardian(child_id)
  or public.is_center_member(center_id)
);

create policy "Educators and admins can create daily reports"
on public.daily_reports for insert
to authenticated
with check (
  public.is_center_role(center_id, array['admin', 'educator']::public.app_role[])
);

create policy "Educators and admins can update daily reports"
on public.daily_reports for update
to authenticated
using (
  public.is_center_role(center_id, array['admin', 'educator']::public.app_role[])
)
with check (
  public.is_center_role(center_id, array['admin', 'educator']::public.app_role[])
);

create index daily_reports_center_date_idx
  on public.daily_reports(center_id, report_date);

create index daily_reports_child_date_idx
  on public.daily_reports(child_id, report_date desc);
