do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'center_memberships'
      and policyname = 'Admins can read center memberships'
  ) then
    create policy "Admins can read center memberships"
    on public.center_memberships for select
    to authenticated
    using (
      public.is_center_role(center_id, array['admin']::public.app_role[])
    );
  end if;
end $$;
