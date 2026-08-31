import { createClient } from "@supabase/supabase-js";
import { readFileSync } from "node:fs";

const env = loadEnv();
const supabaseUrl = baseUrl(env.SUPABASE_URL);
const serviceRoleKey =
  env.SUPABASE_SECRET_KEY ?? env.SUPABASE_SERVICE_ROLE_KEY ?? env.SERVICE_ROLE_KEY;
const defaultPassword = process.env.DEMO_PASSWORD ?? "NidoDemo-2026!";

if (!supabaseUrl || !serviceRoleKey) {
  throw new Error("Falta SUPABASE_URL o SERVICE_ROLE_KEY en .env");
}

if (defaultPassword.length < 10) {
  throw new Error("DEMO_PASSWORD debe tener al menos 10 caracteres");
}

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { autoRefreshToken: false, persistSession: false },
});

const center = { name: "Escola Bressol Nido Demo", slug: "nido-demo-26-27" };
const director = user("direccion@nido-demo.test", "Clara Vidal", "admin");
const educators = [
  user("laura.marti@nido-demo.test", "Laura Marti", "educator"),
  user("marta.soler@nido-demo.test", "Marta Soler", "educator"),
  user("julia.pons@nido-demo.test", "Julia Pons", "educator"),
];
const classrooms = [
  ["petits", "Petits 0-1"],
  ["mitjans", "Mitjans 1-2"],
  ["grans", "Grans 2-3"],
];
const children = [
  ["Aina Ruiz", "2026-02-14", "girl", "petits"],
  ["Marc Ferrer", "2026-01-22", "boy", "petits"],
  ["Noa Garcia", "2026-03-08", "girl", "petits"],
  ["Leo Navarro", "2025-12-18", "boy", "petits"],
  ["Iria Torres", "2026-04-02", "girl", "petits"],
  ["Nil Romero", "2026-05-11", "boy", "petits"],
  ["Berta Casas", "2026-02-27", "girl", "petits"],
  ["Pol Marin", "2026-01-05", "boy", "petits"],
  ["Ona Puig", "2026-03-19", "girl", "petits"],
  ["Jan Roca", "2025-11-30", "boy", "petits"],
  ["Emma Vidal", "2025-06-15", "girl", "mitjans"],
  ["Hugo Alba", "2025-08-03", "boy", "mitjans"],
  ["Lia Moreno", "2025-04-21", "girl", "mitjans"],
  ["Bruno Gil", "2025-07-09", "boy", "mitjans"],
  ["Arlet Cano", "2025-10-12", "girl", "mitjans"],
  ["Teo Domenech", "2025-05-28", "boy", "mitjans"],
  ["Claudia Serra", "2025-09-17", "girl", "mitjans"],
  ["Gael Vega", "2025-03-06", "boy", "mitjans"],
  ["Nora Pascual", "2025-11-01", "girl", "mitjans"],
  ["Biel Costa", "2025-02-25", "boy", "mitjans"],
  ["Martina Rius", "2024-09-13", "girl", "grans"],
  ["Lucas Pujol", "2024-11-24", "boy", "grans"],
  ["Abril Ortega", "2024-08-02", "girl", "grans"],
  ["Mateo Molina", "2024-12-30", "boy", "grans"],
  ["Laia Font", "2024-10-19", "girl", "grans"],
  ["Eric Sanz", "2024-07-07", "boy", "grans"],
  ["Valeria Mir", "2024-06-22", "girl", "grans"],
  ["Izan Calvo", "2024-05-14", "boy", "grans"],
  ["Sira Leon", "2024-04-11", "girl", "grans"],
  ["Max Rey", "2024-03-26", "boy", "grans"],
].map(([fullName, birthDate, sex, classroomKey]) =>
  demoChild(fullName, birthDate, sex, classroomKey)
);

const savedCenter = await upsertCenter();
await clearDemoActivity(savedCenter.id);

const userIds = new Map();
const existingUsers = await listExistingUsers();
for (const demoUser of [director, ...educators, ...guardianUsers(children)]) {
  const id = await ensureUser(demoUser, existingUsers);
  userIds.set(demoUser.email, id);
  await upsert("center_memberships", {
    center_id: savedCenter.id,
    user_id: id,
    role: demoUser.role,
  });
}

const classroomIds = new Map();
for (const [key, name] of classrooms) {
  const data = await upsertSelect(
    "classrooms",
    { center_id: savedCenter.id, name },
    "center_id,name",
    "id",
  );
  classroomIds.set(key, data.id);
}

for (const child of children) {
  const data = await upsertSelect(
    "children",
    {
      center_id: savedCenter.id,
      classroom_id: classroomIds.get(child.classroomKey),
      full_name: child.fullName,
      birth_date: child.birthDate,
      sex: child.sex,
      allergies: child.fullName === "Emma Vidal" ? "Intolerancia leve a la lactosa" : null,
      medical_notes: child.fullName === "Lucas Pujol" ? "Requiere autorizacion para inhalador" : null,
      emergency_contact_name: child.guardians[0].fullName,
      emergency_contact_phone: child.guardians[0].phone,
    },
    "center_id,full_name",
    "id",
  );

  for (const guardian of child.guardians) {
    await upsert("child_guardians", {
      child_id: data.id,
      user_id: userIds.get(guardian.email),
      relationship: guardian.relationship,
      can_pick_up: true,
    });
  }

  await seedChildActivity(savedCenter.id, data.id, userIds.get("laura.marti@nido-demo.test"));
}

await seedCalendar(savedCenter.id);
await seedMenus(savedCenter.id);
await seedAnnouncements(savedCenter.id, userIds.get(director.email));

console.log(
  JSON.stringify(
    {
      center: savedCenter,
      password: "Usa DEMO_PASSWORD o el valor por defecto configurado localmente",
      director: director.email,
      educators: educators.map((item) => item.email),
      sampleFamilies: [
        "aina.padre@nido-demo.test",
        "aina.madre@nido-demo.test",
        "lucas.padre@nido-demo.test",
        "martina.madre@nido-demo.test",
      ],
      classrooms: classrooms.map(([, name]) => name),
      children: children.length,
    },
    null,
    2,
  ),
);

async function upsertCenter() {
  return upsertSelect("centers", center, "slug", "id,name,slug");
}

async function ensureUser(demoUser, existingUsers) {
  const existing = existingUsers.get(demoUser.email);
  let id = existing?.id;
  if (!id) {
    const { data, error } = await supabase.auth.admin.createUser({
      email: demoUser.email,
      password: defaultPassword,
      email_confirm: true,
      user_metadata: {
        full_name: demoUser.fullName,
        role: demoUser.role,
        center_slug: center.slug,
      },
    });
    if (error) throw error;
    id = data.user.id;
    existingUsers.set(demoUser.email, data.user);
  }

  const { error: updateError } = await supabase.auth.admin.updateUserById(id, {
    password: defaultPassword,
    email_confirm: true,
    user_metadata: {
      full_name: demoUser.fullName,
      role: demoUser.role,
      center_slug: center.slug,
    },
  });
  if (updateError) throw updateError;

  await upsert("profiles", {
    id,
    full_name: demoUser.fullName,
    phone: demoUser.phone ?? null,
  });
  return id;
}

async function listExistingUsers() {
  const users = new Map();
  for (let page = 1; page <= 20; page += 1) {
    const { data, error } = await supabase.auth.admin.listUsers({ page, perPage: 1000 });
    if (error) throw error;
    for (const item of data.users) {
      if (item.email) users.set(item.email.toLowerCase(), item);
    }
    if (data.users.length < 1000) return users;
  }
  return users;
}

async function clearDemoActivity(centerId) {
  for (const table of ["announcements", "attendance_events", "messages", "media_assets"]) {
    const { error } = await supabase.from(table).delete().eq("center_id", centerId);
    if (error) throw error;
  }
}

async function seedChildActivity(centerId, childId, educatorId) {
  const today = new Date().toISOString().substring(0, 10);
  await upsert(
    "daily_reports",
    {
      center_id: centerId,
      child_id: childId,
      report_date: today,
      breakfast: "all",
      lunch: "most",
      snack: "little",
      morning_bowel_movement: false,
      afternoon_bowel_movement: true,
      morning_sleep: "good",
      morning_sleep_time: "12:45",
      afternoon_sleep: "good",
      afternoon_sleep_time: "14:15",
      school_notes: "Ha participado en pintura y juego simbolico.",
      home_notes: "Ha dormido bien y llega con su botella de agua.",
      medication: null,
      created_by: educatorId,
      updated_by: educatorId,
    },
    "child_id,report_date",
  );
  await insert("attendance_events", {
    center_id: centerId,
    child_id: childId,
    event_type: "check_in",
    actor_id: educatorId,
    notes: "Entrada demo por QR del centro",
  });
  await insert("messages", {
    center_id: centerId,
    child_id: childId,
    sender_id: educatorId,
    category: "educator",
    body: "Hoy trabajaremos autonomia, musica y juego de patio.",
  });
  await insert("media_assets", {
    center_id: centerId,
    child_id: childId,
    kind: "photo",
    storage_path: `demo/${childId}/pintura.jpg`,
    title: "Actividad de pintura",
    activity: "Pintura",
    taken_on: today,
    uploaded_by: educatorId,
  });
}

async function seedCalendar(centerId) {
  for (const [title, starts_on, is_closed_day] of [
    ["Inicio de curso", "2026-09-07", false],
    ["Reunion familias Petits", "2026-09-14", false],
    ["Fiesta de castanyada", "2026-10-30", false],
    ["Puente de diciembre", "2026-12-07", true],
    ["Vacaciones de Navidad", "2026-12-23", true],
    ["Carnaval", "2027-02-12", false],
    ["Vacaciones de Semana Santa", "2027-03-29", true],
    ["Sant Jordi", "2027-04-23", false],
    ["Fiesta de fin de curso", "2027-06-18", false],
    ["Ultimo dia de curso", "2027-06-30", false],
  ]) {
    await upsert(
      "calendar_events",
      { center_id: centerId, title, starts_on, ends_on: null, is_closed_day },
      "center_id,title,starts_on",
    );
  }
}

async function seedMenus(centerId) {
  for (const [menu_date, first_course, second_course, dessert] of [
    ["2026-09-07", "Crema de verduras", "Pollo al horno", "Fruta"],
    ["2026-09-08", "Arroz con tomate", "Merluza", "Yogur"],
    ["2026-09-09", "Lentejas suaves", "Tortilla francesa", "Fruta"],
    ["2026-09-10", "Pasta integral", "Pavo guisado", "Compota"],
    ["2026-09-11", "Verdura salteada", "Hamburguesa vegetal", "Fruta"],
  ]) {
    await upsert(
      "menus",
      { center_id: centerId, menu_date, first_course, second_course, dessert },
      "center_id,menu_date",
    );
  }
}

async function seedAnnouncements(centerId, directorId) {
  await insert("announcements", {
    center_id: centerId,
    title: "Bienvenida curso 2026-2027",
    body:
      "Bienvenidas familias. Centralizaremos agenda, calendario, menus, fotos y comunicados en NidoConecta.",
    published_at: new Date().toISOString(),
    created_by: directorId,
  });
}

async function upsert(table, payload, onConflict) {
  let query = supabase.from(table).upsert(payload);
  if (onConflict) query = supabase.from(table).upsert(payload, { onConflict });
  const { error } = await query;
  if (error) throw error;
}

async function upsertSelect(table, payload, onConflict, select) {
  const { data, error } = await supabase
    .from(table)
    .upsert(payload, { onConflict })
    .select(select)
    .single();
  if (error) throw error;
  return data;
}

async function insert(table, payload) {
  const { error } = await supabase.from(table).insert(payload);
  if (error) throw error;
}

function user(email, fullName, role) {
  return { email, fullName, role };
}

function demoChild(fullName, birthDate, sex, classroomKey) {
  const name = normalize(fullName.split(" ")[0]);
  return {
    fullName,
    birthDate,
    sex,
    classroomKey,
    guardians: [
      {
        fullName: `Carlos ${fullName.split(" ")[1]}`,
        email: `${name}.padre@nido-demo.test`,
        relationship: "Padre/tutor",
        phone: `6${hashDigits(name, 8)}`,
      },
      {
        fullName: `Marina ${fullName.split(" ")[1]}`,
        email: `${name}.madre@nido-demo.test`,
        relationship: "Madre/tutora",
        phone: `7${hashDigits(`${name}m`, 8)}`,
      },
    ],
  };
}

function guardianUsers(source) {
  const users = new Map();
  for (const child of source) {
    for (const guardian of child.guardians) {
      users.set(guardian.email, user(guardian.email, guardian.fullName, "family"));
    }
  }
  return [...users.values()];
}

function loadEnv() {
  const values = {};
  const file = readFileSync(".env", "utf8");
  for (const line of file.split(/\r?\n/)) {
    const match = line.match(/^\s*([^#][^=]+)=(.*)$/);
    if (match) values[match[1].trim()] = match[2].trim().replace(/^"|"$/g, "");
  }
  return values;
}

function baseUrl(value) {
  if (!value) return null;
  const url = new URL(value);
  return `${url.protocol}//${url.host}`;
}

function normalize(value) {
  return value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase();
}

function hashDigits(value, length) {
  let hash = 0;
  for (let index = 0; index < value.length; index += 1) {
    hash = (hash * 31 + value.charCodeAt(index)) % 100000000;
  }
  return hash.toString().padStart(length, "0").substring(0, length);
}
