alter table public.classrooms
  add constraint classrooms_center_name_unique unique (center_id, name);

alter table public.children
  add constraint children_center_full_name_unique unique (center_id, full_name);

alter table public.calendar_events
  add constraint calendar_events_center_title_start_unique unique (
    center_id,
    title,
    starts_on
  );
