create policy "Guardians can create home daily reports"
on public.daily_reports for insert
to authenticated
with check (public.is_child_guardian(child_id));

create policy "Guardians can update home daily reports"
on public.daily_reports for update
to authenticated
using (public.is_child_guardian(child_id))
with check (public.is_child_guardian(child_id));
