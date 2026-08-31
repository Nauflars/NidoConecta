create policy "Admins can read center memberships"
on public.center_memberships for select
to authenticated
using (
  public.is_center_role(center_id, array['admin']::public.app_role[])
);
