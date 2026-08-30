create policy "Admins can manage center classrooms"
on public.classrooms for all
to authenticated
using (public.is_center_role(center_id, array['admin']::public.app_role[]))
with check (public.is_center_role(center_id, array['admin']::public.app_role[]));

create policy "Admins can manage children"
on public.children for all
to authenticated
using (public.is_center_role(center_id, array['admin']::public.app_role[]))
with check (public.is_center_role(center_id, array['admin']::public.app_role[]));

create policy "Admins can manage announcements"
on public.announcements for all
to authenticated
using (public.is_center_role(center_id, array['admin']::public.app_role[]))
with check (public.is_center_role(center_id, array['admin']::public.app_role[]));

create policy "Admins can manage calendar events"
on public.calendar_events for all
to authenticated
using (public.is_center_role(center_id, array['admin']::public.app_role[]))
with check (public.is_center_role(center_id, array['admin']::public.app_role[]));

create policy "Admins can manage menus"
on public.menus for all
to authenticated
using (public.is_center_role(center_id, array['admin']::public.app_role[]))
with check (public.is_center_role(center_id, array['admin']::public.app_role[]));
