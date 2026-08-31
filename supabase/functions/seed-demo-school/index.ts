import { createClient } from "npm:@supabase/supabase-js@2";

type SeedPayload = {
  defaultPassword: string;
};

type DemoUser = {
  email: string;
  fullName: string;
  role: "admin" | "educator" | "family";
  phone?: string;
};

type DemoClassroom = {
  key: string;
  name: string;
  educatorEmails: string[];
};

type DemoChild = {
  fullName: string;
  birthDate: string;
  sex: "girl" | "boy";
  classroomKey: string;
  allergies?: string;
  medicalNotes?: string;
  guardians: Array<{
    fullName: string;
    email: string;
    relationship: string;
    phone: string;
  }>;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-worker-secret",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const center = {
  name: "Escola Bressol Nido Demo",
  slug: "nido-demo-26-27",
};

const director: DemoUser = {
  email: "direccion@nido-demo.test",
  fullName: "Clara Vidal",
  role: "admin",
  phone: "600100001",
};

const educators: DemoUser[] = [
  {
    email: "laura.marti@nido-demo.test",
    fullName: "Laura Marti",
    role: "educator",
    phone: "600200001",
  },
  {
    email: "marta.soler@nido-demo.test",
    fullName: "Marta Soler",
    role: "educator",
    phone: "600200002",
  },
  {
    email: "julia.pons@nido-demo.test",
    fullName: "Julia Pons",
    role: "educator",
    phone: "600200003",
  },
];

const classrooms: DemoClassroom[] = [
  {
    key: "petits",
    name: "Petits 0-1",
    educatorEmails: ["laura.marti@nido-demo.test"],
  },
  {
    key: "mitjans",
    name: "Mitjans 1-2",
    educatorEmails: ["marta.soler@nido-demo.test"],
  },
  {
    key: "grans",
    name: "Grans 2-3",
    educatorEmails: ["julia.pons@nido-demo.test", "laura.marti@nido-demo.test"],
  },
];

const children: DemoChild[] = [
  child("Aina Ruiz", "2026-02-14", "girl", "petits", "Ruiz", "Lopez"),
  child("Marc Ferrer", "2026-01-22", "boy", "petits", "Ferrer", "Costa"),
  child("Noa Garcia", "2026-03-08", "girl", "petits", "Garcia", "Vega"),
  child("Leo Navarro", "2025-12-18", "boy", "petits", "Navarro", "Ribas"),
  child("Iria Torres", "2026-04-02", "girl", "petits", "Torres", "Molina"),
  child("Nil Romero", "2026-05-11", "boy", "petits", "Romero", "Serra"),
  child("Berta Casas", "2026-02-27", "girl", "petits", "Casas", "Duran"),
  child("Pol Marin", "2026-01-05", "boy", "petits", "Marin", "Ortega"),
  child("Ona Puig", "2026-03-19", "girl", "petits", "Puig", "Santos"),
  child("Jan Roca", "2025-11-30", "boy", "petits", "Roca", "Nadal"),
  child("Emma Vidal", "2025-06-15", "girl", "mitjans", "Vidal", "Prats"),
  child("Hugo Alba", "2025-08-03", "boy", "mitjans", "Alba", "Martinez"),
  child("Lia Moreno", "2025-04-21", "girl", "mitjans", "Moreno", "Sanz"),
  child("Bruno Gil", "2025-07-09", "boy", "mitjans", "Gil", "Soto"),
  child("Arlet Cano", "2025-10-12", "girl", "mitjans", "Cano", "Riera"),
  child("Teo Domenech", "2025-05-28", "boy", "mitjans", "Domenech", "Paz"),
  child("Claudia Serra", "2025-09-17", "girl", "mitjans", "Serra", "Mir"),
  child("Gael Vega", "2025-03-06", "boy", "mitjans", "Vega", "Calvo"),
  child("Nora Pascual", "2025-11-01", "girl", "mitjans", "Pascual", "Leon"),
  child("Biel Costa", "2025-02-25", "boy", "mitjans", "Costa", "Rey"),
  child("Martina Rius", "2024-09-13", "girl", "grans", "Rius", "Mora"),
  child("Lucas Pujol", "2024-11-24", "boy", "grans", "Pujol", "Soler"),
  child("Abril Ortega", "2024-08-02", "girl", "grans", "Ortega", "Font"),
  child("Mateo Molina", "2024-12-30", "boy", "grans", "Molina", "Aguilar"),
  child("Laia Font", "2024-10-19", "girl", "grans", "Font", "Vives"),
  child("Eric Sanz", "2024-07-07", "boy", "grans", "Sanz", "Mas"),
  child("Valeria Mir", "2024-06-22", "girl", "grans", "Mir", "Serrano"),
  child("Izan Calvo", "2024-05-14", "boy", "grans", "Calvo", "Ramos"),
  child("Sira Leon", "2024-04-11", "girl", "grans", "Leon", "Roig"),
  child("Max Rey", "2024-03-26", "boy", "grans", "Rey", "Campos"),
];

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Metodo no permitido" }, 405);

  const expectedSecret = Deno.env.get("WORKER_SECRET");
  if (!expectedSecret || req.headers.get("x-worker-secret") !== expectedSecret) {
    return json({ error: "No autorizado" }, 401);
  }

  const payload = (await req.json().catch(() => ({}))) as Partial<SeedPayload>;
  if (!payload.defaultPassword || payload.defaultPassword.length < 10) {
    return json({ error: "defaultPassword debe tener al menos 10 caracteres" }, 400);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey =
    Deno.env.get("SUPABASE_SECRET_KEY") ??
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    Deno.env.get("SERVICE_ROLE_KEY");
  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "Servidor sin claves Supabase" }, 500);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: savedCenter, error: centerError } = await supabase
    .from("centers")
    .upsert(center, { onConflict: "slug" })
    .select("id,name,slug")
    .single();
  if (centerError) return json({ error: centerError.message }, 400);

  await clearDemoActivity(supabase, savedCenter.id);

  const users = [director, ...educators, ...guardianUsers(children)];
  const userIds = new Map<string, string>();
  for (const user of users) {
    const id = await ensureUser(supabase, user, payload.defaultPassword);
    userIds.set(user.email, id);
    await supabase.from("center_memberships").upsert({
      center_id: savedCenter.id,
      user_id: id,
      role: user.role,
    });
  }

  const classroomIds = new Map<string, string>();
  for (const classroom of classrooms) {
    const { data, error } = await supabase
      .from("classrooms")
      .upsert({
        center_id: savedCenter.id,
        name: classroom.name,
      }, { onConflict: "center_id,name" })
      .select("id")
      .single();
    if (error) return json({ error: error.message }, 400);
    classroomIds.set(classroom.key, data.id);
  }

  for (const demoChild of children) {
    const classroomId = classroomIds.get(demoChild.classroomKey);
    const { data: savedChild, error: childError } = await supabase
      .from("children")
      .upsert({
        center_id: savedCenter.id,
        classroom_id: classroomId,
        full_name: demoChild.fullName,
        birth_date: demoChild.birthDate,
        sex: demoChild.sex,
        allergies: demoChild.allergies ?? null,
        medical_notes: demoChild.medicalNotes ?? null,
        emergency_contact_name: demoChild.guardians[0].fullName,
        emergency_contact_phone: demoChild.guardians[0].phone,
      }, { onConflict: "center_id,full_name" })
      .select("id")
      .single();
    if (childError) return json({ error: childError.message }, 400);

    for (const guardian of demoChild.guardians) {
      const userId = userIds.get(guardian.email);
      if (!userId) continue;
      await supabase.from("child_guardians").upsert({
        child_id: savedChild.id,
        user_id: userId,
        relationship: guardian.relationship,
        can_pick_up: true,
      });
    }

    await seedChildActivity(supabase, savedCenter.id, savedChild.id, userIds);
  }

  await seedCalendar(supabase, savedCenter.id);
  await seedMenus(supabase, savedCenter.id);
  await seedAnnouncements(supabase, savedCenter.id, userIds.get(director.email));

  return json({
    center: savedCenter,
    users: users.map((user) => ({
      email: user.email,
      role: user.role,
      fullName: user.fullName,
    })),
    classrooms: classrooms.map((classroom) => classroom.name),
    children: children.length,
    password: "Usa el defaultPassword enviado en la peticion",
  });
});

async function ensureUser(
  supabase: ReturnType<typeof createClient>,
  user: DemoUser,
  password: string,
) {
  const existing = await findUserByEmail(supabase, user.email);
  const id = existing?.id ??
    (await supabase.auth.admin.createUser({
      email: user.email,
      password,
      email_confirm: true,
      user_metadata: {
        full_name: user.fullName,
        role: user.role,
        center_slug: center.slug,
      },
    })).data.user?.id;

  if (!id) throw new Error(`No se pudo crear ${user.email}`);

  await supabase.auth.admin.updateUserById(id, {
    password,
    email_confirm: true,
    user_metadata: {
      full_name: user.fullName,
      role: user.role,
      center_slug: center.slug,
    },
  });

  await supabase.from("profiles").upsert({
    id,
    full_name: user.fullName,
    phone: user.phone ?? null,
  });

  return id;
}

async function clearDemoActivity(
  supabase: ReturnType<typeof createClient>,
  centerId: string,
) {
  await supabase.from("announcements").delete().eq("center_id", centerId);
  await supabase.from("attendance_events").delete().eq("center_id", centerId);
  await supabase.from("messages").delete().eq("center_id", centerId);
  await supabase.from("media_assets").delete().eq("center_id", centerId);
}

async function findUserByEmail(supabase: ReturnType<typeof createClient>, email: string) {
  let page = 1;
  while (page <= 20) {
    const { data, error } = await supabase.auth.admin.listUsers({ page, perPage: 1000 });
    if (error) throw error;
    const found = data.users.find((user) => user.email?.toLowerCase() === email);
    if (found) return found;
    if (data.users.length < 1000) return null;
    page += 1;
  }
  return null;
}

function guardianUsers(source: DemoChild[]) {
  const users = new Map<string, DemoUser>();
  for (const demoChild of source) {
    for (const guardian of demoChild.guardians) {
      users.set(guardian.email, {
        email: guardian.email,
        fullName: guardian.fullName,
        role: "family",
        phone: guardian.phone,
      });
    }
  }
  return [...users.values()];
}

function child(
  fullName: string,
  birthDate: string,
  sex: "girl" | "boy",
  classroomKey: string,
  fatherSurname: string,
  motherSurname: string,
): DemoChild {
  const base = normalize(fullName.split(" ")[0]);
  return {
    fullName,
    birthDate,
    sex,
    classroomKey,
    allergies: fullName.includes("Emma") ? "Intolerancia leve a la lactosa" : undefined,
    medicalNotes: fullName.includes("Lucas") ? "Requiere autorizacion para inhalador" : undefined,
    guardians: [
      {
        fullName: `Carlos ${fatherSurname}`,
        email: `${base}.padre@nido-demo.test`,
        relationship: "Padre/tutor",
        phone: `6${hashDigits(base, 8)}`,
      },
      {
        fullName: `Marina ${motherSurname}`,
        email: `${base}.madre@nido-demo.test`,
        relationship: "Madre/tutora",
        phone: `7${hashDigits(`${base}m`, 8)}`,
      },
    ],
  };
}

async function seedChildActivity(
  supabase: ReturnType<typeof createClient>,
  centerId: string,
  childId: string,
  userIds: Map<string, string>,
) {
  const educatorId = userIds.get("laura.marti@nido-demo.test") ?? null;
  const today = startOfDay(new Date());
  const meals = ["all", "most", "little"] as const;
  const sleeps = ["good", "good", "bad", "none"] as const;

  for (let offset = 59; offset >= 0; offset -= 1) {
    const date = new Date(today);
    date.setUTCDate(today.getUTCDate() - offset);
    if (date.getUTCDay() === 0 || date.getUTCDay() === 6) continue;

    const signature = date.getUTCDate() + childId.length + offset;
    if (signature % 13 === 0) continue;

    const reportDate = isoDate(date);
    const sleep = sleeps[signature % sleeps.length];
    const createdAt = `${reportDate}T16:30:00.000Z`;

    await supabase.from("daily_reports").upsert({
      center_id: centerId,
      child_id: childId,
      report_date: reportDate,
      breakfast: meals[signature % meals.length],
      lunch: meals[(signature + 1) % meals.length],
      snack: meals[(signature + 2) % meals.length],
      morning_bowel_movement: signature % 4 === 0,
      afternoon_bowel_movement: signature % 3 === 0,
      morning_sleep: sleep,
      morning_sleep_time: sleep === "none" ? null : `11:${String(35 + signature % 20).padStart(2, "0")}`,
      afternoon_sleep: sleep === "none" ? "none" : "good",
      afternoon_sleep_time: sleep === "none" ? null : `14:${String(5 + signature % 45).padStart(2, "0")}`,
      school_notes: signature % 7 === 0
        ? "Le ha costado la despedida, despues ha estado tranquilo."
        : "Dia estable con juego, patio y rutinas completadas.",
      home_notes: signature % 8 === 0
        ? "La familia avisa de descanso irregular."
        : null,
      medication: null,
      created_by: educatorId,
      updated_by: educatorId,
      created_at: createdAt,
      updated_at: createdAt,
    }, { onConflict: "child_id,report_date" });

    await supabase.from("attendance_events").insert({
      center_id: centerId,
      child_id: childId,
      event_type: "check_in",
      occurred_at: `${reportDate}T08:${String(42 + signature % 18).padStart(2, "0")}:00.000Z`,
      actor_id: educatorId,
      notes: "Entrada demo historica",
    });

    if (signature % 6 === 0) {
      await supabase.from("messages").insert({
        center_id: centerId,
        child_id: childId,
        sender_id: educatorId,
        category: "educator",
        body: `Seguimiento demo ${reportDate}: rutina revisada con la familia.`,
        created_at: `${reportDate}T17:05:00.000Z`,
      });
    }

    if (signature % 5 === 0) {
      await supabase.from("media_assets").insert({
        center_id: centerId,
        child_id: childId,
        kind: "photo",
        storage_path: `demo/${childId}/${reportDate}-rutina.jpg`,
        title: `Rutina ${reportDate.substring(5)}`,
        activity: signature % 2 === 0 ? "Patio" : "Taller sensorial",
        taken_on: reportDate,
        uploaded_by: educatorId,
        created_at: `${reportDate}T15:20:00.000Z`,
      });
    }
  }
}

function startOfDay(value: Date) {
  return new Date(Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), value.getUTCDate()));
}

function isoDate(value: Date) {
  return value.toISOString().substring(0, 10);
}

async function seedCalendar(supabase: ReturnType<typeof createClient>, centerId: string) {
  const events = [
    ["Inicio de curso", "2026-09-07", false],
    ["Reunion familias Petits", "2026-09-14", false],
    ["Fiesta de castanyada", "2026-10-30", false],
    ["Festivo Todos los Santos", "2026-11-01", true],
    ["Puente de diciembre", "2026-12-07", true],
    ["Vacaciones de Navidad", "2026-12-23", true],
    ["Retorno de Navidad", "2027-01-08", false],
    ["Carnaval", "2027-02-12", false],
    ["Vacaciones de Semana Santa", "2027-03-29", true],
    ["Sant Jordi", "2027-04-23", false],
    ["Fiesta de fin de curso", "2027-06-18", false],
    ["Ultimo dia de curso", "2027-06-30", false],
  ];

  for (const [title, startsOn, isClosedDay] of events) {
    await supabase.from("calendar_events").upsert({
      center_id: centerId,
      title,
      starts_on: startsOn,
      ends_on: isClosedDay && title.includes("Vacaciones") ? startsOn : null,
      is_closed_day: isClosedDay,
    }, { onConflict: "center_id,title,starts_on" });
  }
}

async function seedMenus(supabase: ReturnType<typeof createClient>, centerId: string) {
  const menus = [
    ["2026-09-07", "Crema de verduras", "Pollo al horno", "Fruta"],
    ["2026-09-08", "Arroz con tomate", "Merluza", "Yogur"],
    ["2026-09-09", "Lentejas suaves", "Tortilla francesa", "Fruta"],
    ["2026-09-10", "Pasta integral", "Pavo guisado", "Compota"],
    ["2026-09-11", "Verdura salteada", "Hamburguesa vegetal", "Fruta"],
  ];

  for (const [menuDate, firstCourse, secondCourse, dessert] of menus) {
    await supabase.from("menus").upsert({
      center_id: centerId,
      menu_date: menuDate,
      first_course: firstCourse,
      second_course: secondCourse,
      dessert,
    }, { onConflict: "center_id,menu_date" });
  }
}

async function seedAnnouncements(
  supabase: ReturnType<typeof createClient>,
  centerId: string,
  directorId?: string,
) {
  await supabase.from("announcements").insert({
    center_id: centerId,
    title: "Bienvenida curso 2026-2027",
    body:
      "Bienvenidas familias. Este curso centralizaremos agenda, calendario, menus, fotos y comunicados en NidoConecta.",
    published_at: new Date().toISOString(),
    created_by: directorId ?? null,
  });
}

function normalize(value: string) {
  return value
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function hashDigits(value: string, length: number) {
  let hash = 0;
  for (let index = 0; index < value.length; index += 1) {
    hash = (hash * 31 + value.charCodeAt(index)) % 100000000;
  }
  return hash.toString().padStart(length, "0").substring(0, length);
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
