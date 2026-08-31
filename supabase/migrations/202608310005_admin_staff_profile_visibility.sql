do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public'
      and tablename = 'profiles'
      and policyname = 'Admins can read staff profiles'
  ) then
    create policy "Admins can read staff profiles"
    on public.profiles for select
    to authenticated
    using (
      exists (
        select 1
        from public.center_memberships staff_membership
        where staff_membership.user_id = profiles.id
          and staff_membership.role in ('admin', 'educator')
          and public.is_center_role(
            staff_membership.center_id,
            array['admin']::public.app_role[]
          )
      )
    );
  end if;
end $$;
