do $$
declare
  v_center_id uuid;
  v_petits_id uuid;
  v_mitjans_id uuid;
  v_grans_id uuid;
  v_director_id uuid;
  v_educator_id uuid;
  v_child record;
  v_child_id uuid;
begin
  insert into public.centers(name, slug)
  values ('Escola Bressol Nido Demo', 'nido-demo-26-27')
  on conflict (slug) do update set name = excluded.name
  returning id into v_center_id;

  insert into public.classrooms(center_id, name)
  values
    (v_center_id, 'Petits 0-1'),
    (v_center_id, 'Mitjans 1-2'),
    (v_center_id, 'Grans 2-3')
  on conflict (center_id, name) do update set name = excluded.name;

  select id into v_petits_id from public.classrooms where center_id = v_center_id and name = 'Petits 0-1';
  select id into v_mitjans_id from public.classrooms where center_id = v_center_id and name = 'Mitjans 1-2';
  select id into v_grans_id from public.classrooms where center_id = v_center_id and name = 'Grans 2-3';

  for v_child in
    select * from (values
      ('Aina Ruiz','2026-02-14'::date,'girl'::public.child_sex,v_petits_id,'aina.padre@nido-demo.test','aina.madre@nido-demo.test'),
      ('Marc Ferrer','2026-01-22'::date,'boy'::public.child_sex,v_petits_id,'marc.padre@nido-demo.test','marc.madre@nido-demo.test'),
      ('Noa Garcia','2026-03-08'::date,'girl'::public.child_sex,v_petits_id,'noa.padre@nido-demo.test','noa.madre@nido-demo.test'),
      ('Leo Navarro','2025-12-18'::date,'boy'::public.child_sex,v_petits_id,'leo.padre@nido-demo.test','leo.madre@nido-demo.test'),
      ('Iria Torres','2026-04-02'::date,'girl'::public.child_sex,v_petits_id,'iria.padre@nido-demo.test','iria.madre@nido-demo.test'),
      ('Nil Romero','2026-05-11'::date,'boy'::public.child_sex,v_petits_id,'nil.padre@nido-demo.test','nil.madre@nido-demo.test'),
      ('Berta Casas','2026-02-27'::date,'girl'::public.child_sex,v_petits_id,'berta.padre@nido-demo.test','berta.madre@nido-demo.test'),
      ('Pol Marin','2026-01-05'::date,'boy'::public.child_sex,v_petits_id,'pol.padre@nido-demo.test','pol.madre@nido-demo.test'),
      ('Ona Puig','2026-03-19'::date,'girl'::public.child_sex,v_petits_id,'ona.padre@nido-demo.test','ona.madre@nido-demo.test'),
      ('Jan Roca','2025-11-30'::date,'boy'::public.child_sex,v_petits_id,'jan.padre@nido-demo.test','jan.madre@nido-demo.test'),
      ('Emma Vidal','2025-06-15'::date,'girl'::public.child_sex,v_mitjans_id,'emma.padre@nido-demo.test','emma.madre@nido-demo.test'),
      ('Hugo Alba','2025-08-03'::date,'boy'::public.child_sex,v_mitjans_id,'hugo.padre@nido-demo.test','hugo.madre@nido-demo.test'),
      ('Lia Moreno','2025-04-21'::date,'girl'::public.child_sex,v_mitjans_id,'lia.padre@nido-demo.test','lia.madre@nido-demo.test'),
      ('Bruno Gil','2025-07-09'::date,'boy'::public.child_sex,v_mitjans_id,'bruno.padre@nido-demo.test','bruno.madre@nido-demo.test'),
      ('Arlet Cano','2025-10-12'::date,'girl'::public.child_sex,v_mitjans_id,'arlet.padre@nido-demo.test','arlet.madre@nido-demo.test'),
      ('Teo Domenech','2025-05-28'::date,'boy'::public.child_sex,v_mitjans_id,'teo.padre@nido-demo.test','teo.madre@nido-demo.test'),
      ('Claudia Serra','2025-09-17'::date,'girl'::public.child_sex,v_mitjans_id,'claudia.padre@nido-demo.test','claudia.madre@nido-demo.test'),
      ('Gael Vega','2025-03-06'::date,'boy'::public.child_sex,v_mitjans_id,'gael.padre@nido-demo.test','gael.madre@nido-demo.test'),
      ('Nora Pascual','2025-11-01'::date,'girl'::public.child_sex,v_mitjans_id,'nora.padre@nido-demo.test','nora.madre@nido-demo.test'),
      ('Biel Costa','2025-02-25'::date,'boy'::public.child_sex,v_mitjans_id,'biel.padre@nido-demo.test','biel.madre@nido-demo.test'),
      ('Martina Rius','2024-09-13'::date,'girl'::public.child_sex,v_grans_id,'martina.padre@nido-demo.test','martina.madre@nido-demo.test'),
      ('Lucas Pujol','2024-11-24'::date,'boy'::public.child_sex,v_grans_id,'lucas.padre@nido-demo.test','lucas.madre@nido-demo.test'),
      ('Abril Ortega','2024-08-02'::date,'girl'::public.child_sex,v_grans_id,'abril.padre@nido-demo.test','abril.madre@nido-demo.test'),
      ('Mateo Molina','2024-12-30'::date,'boy'::public.child_sex,v_grans_id,'mateo.padre@nido-demo.test','mateo.madre@nido-demo.test'),
      ('Laia Font','2024-10-19'::date,'girl'::public.child_sex,v_grans_id,'laia.padre@nido-demo.test','laia.madre@nido-demo.test'),
      ('Eric Sanz','2024-07-07'::date,'boy'::public.child_sex,v_grans_id,'eric.padre@nido-demo.test','eric.madre@nido-demo.test'),
      ('Valeria Mir','2024-06-22'::date,'girl'::public.child_sex,v_grans_id,'valeria.padre@nido-demo.test','valeria.madre@nido-demo.test'),
      ('Izan Calvo','2024-05-14'::date,'boy'::public.child_sex,v_grans_id,'izan.padre@nido-demo.test','izan.madre@nido-demo.test'),
      ('Sira Leon','2024-04-11'::date,'girl'::public.child_sex,v_grans_id,'sira.padre@nido-demo.test','sira.madre@nido-demo.test'),
      ('Max Rey','2024-03-26'::date,'boy'::public.child_sex,v_grans_id,'max.padre@nido-demo.test','max.madre@nido-demo.test')
    ) as t(full_name, birth_date, sex, classroom_id, father_email, mother_email)
  loop
    insert into public.children(center_id, classroom_id, full_name, birth_date, sex, allergies, medical_notes)
    values (
      v_center_id,
      v_child.classroom_id,
      v_child.full_name,
      v_child.birth_date,
      v_child.sex,
      case when v_child.full_name = 'Emma Vidal' then 'Intolerancia leve a la lactosa' else null end,
      case when v_child.full_name = 'Lucas Pujol' then 'Requiere autorizacion para inhalador' else null end
    )
    on conflict (center_id, full_name) do update set
      classroom_id = excluded.classroom_id,
      birth_date = excluded.birth_date,
      sex = excluded.sex,
      allergies = excluded.allergies,
      medical_notes = excluded.medical_notes
    returning id into v_child_id;

    insert into public.daily_reports(
      center_id, child_id, report_date, breakfast, lunch, snack,
      morning_bowel_movement, afternoon_bowel_movement,
      morning_sleep, morning_sleep_time, afternoon_sleep, afternoon_sleep_time,
      school_notes, home_notes
    )
    values (
      v_center_id, v_child_id, current_date, 'all', 'most', 'little',
      false, true, 'good', '12:45', 'good', '14:15',
      'Ha participado en pintura y juego simbolico.',
      'Ha dormido bien y llega con su botella de agua.'
    )
    on conflict (child_id, report_date) do update set
      breakfast = excluded.breakfast,
      lunch = excluded.lunch,
      snack = excluded.snack,
      school_notes = excluded.school_notes,
      home_notes = excluded.home_notes;

    insert into public.authorized_pickups(child_id, full_name, relationship, phone)
    values
      (v_child_id, 'Padre demo', 'Padre/tutor', '600000001'),
      (v_child_id, 'Madre demo', 'Madre/tutora', '600000002')
    on conflict do nothing;

    insert into public.child_guardians(child_id, user_id, relationship, can_pick_up)
    select v_child_id, u.id, 'Padre/tutor', true
    from auth.users u
    where lower(u.email) = v_child.father_email
    on conflict (child_id, user_id) do update set relationship = excluded.relationship;

    insert into public.child_guardians(child_id, user_id, relationship, can_pick_up)
    select v_child_id, u.id, 'Madre/tutora', true
    from auth.users u
    where lower(u.email) = v_child.mother_email
    on conflict (child_id, user_id) do update set relationship = excluded.relationship;
  end loop;

  insert into public.calendar_events(center_id, title, starts_on, is_closed_day)
  values
    (v_center_id, 'Inicio de curso', '2026-09-07', false),
    (v_center_id, 'Reunion familias Petits', '2026-09-14', false),
    (v_center_id, 'Fiesta de castanyada', '2026-10-30', false),
    (v_center_id, 'Puente de diciembre', '2026-12-07', true),
    (v_center_id, 'Vacaciones de Navidad', '2026-12-23', true),
    (v_center_id, 'Carnaval', '2027-02-12', false),
    (v_center_id, 'Vacaciones de Semana Santa', '2027-03-29', true),
    (v_center_id, 'Sant Jordi', '2027-04-23', false),
    (v_center_id, 'Fiesta de fin de curso', '2027-06-18', false),
    (v_center_id, 'Ultimo dia de curso', '2027-06-30', false)
  on conflict (center_id, title, starts_on) do update set is_closed_day = excluded.is_closed_day;

  insert into public.menus(center_id, menu_date, first_course, second_course, dessert)
  values
    (v_center_id, '2026-09-07', 'Crema de verduras', 'Pollo al horno', 'Fruta'),
    (v_center_id, '2026-09-08', 'Arroz con tomate', 'Merluza', 'Yogur'),
    (v_center_id, '2026-09-09', 'Lentejas suaves', 'Tortilla francesa', 'Fruta'),
    (v_center_id, '2026-09-10', 'Pasta integral', 'Pavo guisado', 'Compota'),
    (v_center_id, '2026-09-11', 'Verdura salteada', 'Hamburguesa vegetal', 'Fruta')
  on conflict (center_id, menu_date) do update set
    first_course = excluded.first_course,
    second_course = excluded.second_course,
    dessert = excluded.dessert;

  select id into v_director_id from auth.users where lower(email) = 'direccion@nido-demo.test';
  select id into v_educator_id from auth.users where lower(email) = 'laura.marti@nido-demo.test';

  insert into public.announcements(center_id, title, body, published_at, created_by)
  values (
    v_center_id,
    'Bienvenida curso 2026-2027',
    'Bienvenidas familias. Centralizaremos agenda, calendario, menus, fotos y comunicados en NidoConecta.',
    now(),
    v_director_id
  )
  on conflict do nothing;

  insert into public.center_memberships(center_id, user_id, role)
  select v_center_id, u.id, v.role::public.app_role
  from auth.users u
  join (values
    ('direccion@nido-demo.test', 'admin'),
    ('laura.marti@nido-demo.test', 'educator'),
    ('marta.soler@nido-demo.test', 'educator'),
    ('julia.pons@nido-demo.test', 'educator')
  ) as v(email, role) on lower(u.email) = v.email
  on conflict (center_id, user_id) do update set role = excluded.role;

  insert into public.attendance_events(center_id, child_id, event_type, actor_id, notes)
  select v_center_id, c.id, 'check_in', v_educator_id, 'Entrada demo por QR del centro'
  from public.children c
  where c.center_id = v_center_id
    and not exists (
      select 1
      from public.attendance_events a
      where a.center_id = v_center_id
        and a.child_id = c.id
        and a.event_type = 'check_in'
        and a.occurred_at::date = current_date
    );

  insert into public.media_assets(center_id, child_id, kind, storage_path, title, activity, taken_on, uploaded_by)
  select v_center_id, c.id, 'photo', 'demo/' || c.id || '/pintura.jpg',
    'Actividad de pintura', 'Pintura', current_date, v_educator_id
  from public.children c
  where c.center_id = v_center_id
    and not exists (
      select 1 from public.media_assets m
      where m.center_id = v_center_id and m.child_id = c.id and m.title = 'Actividad de pintura'
    );

  insert into public.messages(center_id, child_id, sender_id, category, body)
  select v_center_id, c.id, v_educator_id, 'educator',
    'Hoy trabajaremos autonomia, musica y juego de patio.'
  from public.children c
  where c.center_id = v_center_id
    and not exists (
      select 1 from public.messages m
      where m.center_id = v_center_id and m.child_id = c.id and m.body = 'Hoy trabajaremos autonomia, musica y juego de patio.'
    );
end $$;
