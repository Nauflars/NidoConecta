do $$
declare
  v_center_id uuid;
  v_educator_id uuid;
  v_child record;
  v_day date;
  v_signature int;
  v_lunch public.meal_amount;
  v_breakfast public.meal_amount;
  v_snack public.meal_amount;
  v_sleep public.sleep_quality;
begin
  select id into v_center_id
  from public.centers
  where slug = 'nido-demo-26-27';

  if v_center_id is null then
    return;
  end if;

  select id into v_educator_id
  from auth.users
  where lower(email) = 'laura.marti@nido-demo.test';

  for v_child in
    select id, full_name, classroom_id
    from public.children
    where center_id = v_center_id
  loop
    for v_day in
      select generate_series(current_date - interval '59 days', current_date, interval '1 day')::date
    loop
      if extract(isodow from v_day) > 5 then
        continue;
      end if;

      v_signature := extract(doy from v_day)::int + length(v_child.full_name);
      if v_signature % 13 = 0 then
        continue;
      end if;

      v_breakfast := (array['all', 'most', 'little']::public.meal_amount[])[(v_signature % 3) + 1];
      v_lunch := (array['all', 'most', 'little']::public.meal_amount[])[((v_signature + 1) % 3) + 1];
      v_snack := (array['all', 'most', 'little']::public.meal_amount[])[((v_signature + 2) % 3) + 1];
      v_sleep := case
        when v_signature % 9 = 0 then 'bad'::public.sleep_quality
        when v_signature % 5 = 0 then 'none'::public.sleep_quality
        else 'good'::public.sleep_quality
      end;

      insert into public.daily_reports(
        center_id, child_id, report_date, breakfast, lunch, snack,
        morning_bowel_movement, afternoon_bowel_movement,
        morning_sleep, morning_sleep_time, afternoon_sleep, afternoon_sleep_time,
        school_notes, home_notes, medication, created_by, updated_by, created_at, updated_at
      )
      values (
        v_center_id,
        v_child.id,
        v_day,
        v_breakfast,
        v_lunch,
        v_snack,
        v_signature % 4 = 0,
        v_signature % 3 = 0,
        v_sleep,
        case when v_sleep = 'none' then null else '11:' || lpad((35 + (v_signature % 20))::text, 2, '0') end,
        case when v_sleep = 'none' then 'none'::public.sleep_quality else 'good'::public.sleep_quality end,
        case when v_sleep = 'none' then null else '14:' || lpad((5 + (v_signature % 45))::text, 2, '0') end,
        case
          when v_signature % 10 = 0 then 'Ha pedido repetir cuento y ha participado con calma.'
          when v_signature % 7 = 0 then 'Le ha costado la despedida, despues ha estado tranquilo.'
          else 'Dia estable con juego, patio y rutinas completadas.'
        end,
        case
          when v_signature % 8 = 0 then 'La familia avisa de descanso irregular.'
          else null
        end,
        case
          when v_child.full_name = 'Lucas Pujol' and v_signature % 12 = 0 then 'Inhalador autorizado por la familia.'
          else null
        end,
        v_educator_id,
        v_educator_id,
        v_day + time '16:30',
        v_day + time '16:30'
      )
      on conflict (child_id, report_date) do update set
        breakfast = excluded.breakfast,
        lunch = excluded.lunch,
        snack = excluded.snack,
        morning_bowel_movement = excluded.morning_bowel_movement,
        afternoon_bowel_movement = excluded.afternoon_bowel_movement,
        morning_sleep = excluded.morning_sleep,
        morning_sleep_time = excluded.morning_sleep_time,
        afternoon_sleep = excluded.afternoon_sleep,
        afternoon_sleep_time = excluded.afternoon_sleep_time,
        school_notes = excluded.school_notes,
        home_notes = excluded.home_notes,
        medication = excluded.medication,
        updated_by = excluded.updated_by,
        updated_at = excluded.updated_at;

      insert into public.attendance_events(
        center_id, child_id, event_type, occurred_at, actor_id, notes
      )
      select
        v_center_id,
        v_child.id,
        'check_in',
        v_day + time '08:45' + ((v_signature % 18) || ' minutes')::interval,
        v_educator_id,
        'Entrada demo historica'
      where not exists (
        select 1
        from public.attendance_events existing
        where existing.center_id = v_center_id
          and existing.child_id = v_child.id
          and existing.event_type = 'check_in'
          and existing.occurred_at::date = v_day
      );

      if v_signature % 6 = 0 then
        insert into public.messages(center_id, child_id, sender_id, category, body, created_at)
        select
          v_center_id,
          v_child.id,
          v_educator_id,
          'educator',
          'Seguimiento demo ' || to_char(v_day, 'YYYY-MM-DD') || ': rutina revisada con la familia.',
          v_day + time '17:05'
        where not exists (
          select 1
          from public.messages existing
          where existing.center_id = v_center_id
            and existing.child_id = v_child.id
            and existing.created_at::date = v_day
            and existing.body like 'Seguimiento demo %'
        );
      end if;

      if v_signature % 5 = 0 then
        insert into public.media_assets(
          center_id, child_id, classroom_id, kind, storage_path, title,
          activity, taken_on, uploaded_by, created_at
        )
        select
          v_center_id,
          v_child.id,
          v_child.classroom_id,
          'photo',
          'demo/' || v_child.id || '/' || to_char(v_day, 'YYYYMMDD') || '-rutina.jpg',
          'Rutina ' || to_char(v_day, 'DD/MM'),
          case when v_signature % 2 = 0 then 'Patio' else 'Taller sensorial' end,
          v_day,
          v_educator_id,
          v_day + time '15:20'
        where not exists (
          select 1
          from public.media_assets existing
          where existing.center_id = v_center_id
            and existing.child_id = v_child.id
            and existing.taken_on = v_day
            and existing.title like 'Rutina %'
        );
      end if;
    end loop;
  end loop;
end $$;
