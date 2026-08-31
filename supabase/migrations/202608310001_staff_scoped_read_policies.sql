create or replace function public.is_center_staff(target_center_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select public.is_center_role(
    target_center_id,
    array['admin', 'educator']::public.app_role[]
  );
$$;

drop policy if exists "Members can read center classrooms" on public.classrooms;
create policy "Staff can read center classrooms"
on public.classrooms for select
to authenticated
using (
  public.is_center_staff(center_id)
  or exists (
    select 1
    from public.children c
    where c.classroom_id = classrooms.id
      and public.is_child_guardian(c.id)
  )
);

drop policy if exists "Members and guardians can read children" on public.children;
create policy "Staff and guardians can read children"
on public.children for select
to authenticated
using (public.is_center_staff(center_id) or public.is_child_guardian(id));

drop policy if exists "Members and guardians can read daily logs" on public.daily_logs;
create policy "Staff and guardians can read daily logs"
on public.daily_logs for select
to authenticated
using (
  public.is_child_guardian(child_id)
  or exists (
    select 1
    from public.children c
    where c.id = child_id
      and public.is_center_staff(c.center_id)
  )
);

drop policy if exists "Members and guardians can read daily reports" on public.daily_reports;
create policy "Staff and guardians can read daily reports"
on public.daily_reports for select
to authenticated
using (
  public.is_child_guardian(child_id)
  or public.is_center_staff(center_id)
);

drop policy if exists "Members and guardians can read attendance" on public.attendance_events;
create policy "Staff and guardians can read attendance"
on public.attendance_events for select
to authenticated
using (public.is_center_staff(center_id) or public.is_child_guardian(child_id));

drop policy if exists "Members and guardians can read messages" on public.messages;
create policy "Staff and guardians can read messages"
on public.messages for select
to authenticated
using (
  public.is_center_staff(center_id)
  or (child_id is not null and public.is_child_guardian(child_id))
);

drop policy if exists "Members and guardians can read media" on public.media_assets;
create policy "Staff and guardians can read media"
on public.media_assets for select
to authenticated
using (
  public.is_center_staff(center_id)
  or (child_id is not null and public.is_child_guardian(child_id))
);
