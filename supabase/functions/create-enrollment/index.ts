import { createClient } from "npm:@supabase/supabase-js@2";

type GuardianInput = {
  fullName: string;
  email: string;
  relationship: string;
  phone?: string;
  canPickUp?: boolean;
};

type EducatorInput = {
  fullName: string;
  email: string;
  phone?: string;
};

type EnrollmentPayload = {
  centerId: string;
  classroomId?: string | null;
  child: {
    fullName: string;
    birthDate: string;
    sex: "girl" | "boy" | "not_specified";
    allergies?: string;
    medicalNotes?: string;
    notes?: string;
    emergencyContactName?: string;
    emergencyContactPhone?: string;
  };
  guardians: GuardianInput[];
  educators?: EducatorInput[];
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Metodo no permitido" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey =
    Deno.env.get("SERVICE_ROLE_KEY") ??
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    Deno.env.get("SUPABASE_SECRET_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "Servidor sin claves Supabase" }, 500);
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return json({ error: "Sesion requerida" }, 401);
  }

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const userClient = createClient(
    supabaseUrl,
    req.headers.get("apikey") ?? serviceRoleKey,
    {
      global: { headers: { Authorization: authHeader } },
      auth: { autoRefreshToken: false, persistSession: false },
    },
  );

  const {
    data: { user },
    error: userError,
  } = await userClient.auth.getUser();

  if (userError || !user) {
    return json({ error: "Sesion no valida" }, 401);
  }

  const payload = (await req.json()) as EnrollmentPayload;
  const validationError = validatePayload(payload);
  if (validationError) {
    return json({ error: validationError }, 400);
  }

  const { data: membership } = await supabase
    .from("center_memberships")
    .select("role")
    .eq("center_id", payload.centerId)
    .eq("user_id", user.id)
    .maybeSingle();

  if (membership?.role !== "admin") {
    return json({ error: "Solo direccion puede crear accesos" }, 403);
  }

  const { data: child, error: childError } = await supabase
    .from("children")
    .insert({
      center_id: payload.centerId,
      classroom_id: payload.classroomId || null,
      full_name: payload.child.fullName.trim(),
      birth_date: payload.child.birthDate,
      sex: payload.child.sex,
      allergies: clean(payload.child.allergies),
      medical_notes: clean(payload.child.medicalNotes),
      notes: clean(payload.child.notes),
      emergency_contact_name: clean(payload.child.emergencyContactName),
      emergency_contact_phone: clean(payload.child.emergencyContactPhone),
    })
    .select("id")
    .single();

  if (childError) {
    return json({ error: childError.message }, 400);
  }

  const invitedGuardians = [];
  for (const guardian of payload.guardians) {
    invitedGuardians.push(
      await inviteUser({
        supabase,
        centerId: payload.centerId,
        childId: child.id,
        invitedBy: user.id,
        role: "family",
        fullName: guardian.fullName,
        email: guardian.email,
        relationship: guardian.relationship,
        phone: guardian.phone,
        canPickUp: guardian.canPickUp ?? true,
      }),
    );
  }

  const invitedEducators = [];
  for (const educator of payload.educators ?? []) {
    invitedEducators.push(
      await inviteUser({
        supabase,
        centerId: payload.centerId,
        childId: null,
        invitedBy: user.id,
        role: "educator",
        fullName: educator.fullName,
        email: educator.email,
        phone: educator.phone,
      }),
    );
  }

  return json({
    childId: child.id,
    guardians: invitedGuardians,
    educators: invitedEducators,
  });
});

function validatePayload(payload: EnrollmentPayload) {
  if (!payload?.centerId) return "Falta el centro";
  if (!payload.child?.fullName?.trim()) return "Falta el nombre del nino";
  if (!payload.child?.birthDate) return "Falta la fecha de nacimiento";
  if (!["girl", "boy", "not_specified"].includes(payload.child.sex)) {
    return "Sexo no valido";
  }
  if (!payload.guardians?.length) return "Anade al menos un familiar";

  for (const guardian of payload.guardians) {
    if (!guardian.fullName?.trim()) return "Falta el nombre de un familiar";
    if (!isEmail(guardian.email)) return "Email de familiar no valido";
    if (!guardian.relationship?.trim()) return "Falta parentesco";
  }

  for (const educator of payload.educators ?? []) {
    if (!educator.fullName?.trim()) return "Falta el nombre de una educadora";
    if (!isEmail(educator.email)) return "Email de educadora no valido";
  }

  return null;
}

async function inviteUser(args: {
  supabase: ReturnType<typeof createClient>;
  centerId: string;
  childId: string | null;
  invitedBy: string;
  role: "family" | "educator";
  fullName: string;
  email: string;
  relationship?: string;
  phone?: string;
  canPickUp?: boolean;
}) {
  const redirectTo = Deno.env.get("APP_DOWNLOAD_URL") ??
    Deno.env.get("SITE_URL") ??
    undefined;

  const { data, error } = await args.supabase.auth.admin.inviteUserByEmail(
    args.email.trim().toLowerCase(),
    {
      data: {
        full_name: args.fullName.trim(),
        role: args.role,
        center_id: args.centerId,
      },
      redirectTo,
    },
  );

  await args.supabase.from("enrollment_invitations").insert({
    center_id: args.centerId,
    child_id: args.childId,
    email: args.email.trim().toLowerCase(),
    full_name: args.fullName.trim(),
    role: args.role,
    relationship: clean(args.relationship),
    invited_by: args.invitedBy,
    status: error ? "failed" : "sent",
    error_message: error?.message ?? null,
    sent_at: error ? null : new Date().toISOString(),
  });

  if (error || !data.user) {
    return { email: args.email, status: "failed", error: error?.message };
  }

  await args.supabase.from("profiles").upsert({
    id: data.user.id,
    full_name: args.fullName.trim(),
    phone: clean(args.phone),
  });

  await args.supabase.from("center_memberships").upsert({
    center_id: args.centerId,
    user_id: data.user.id,
    role: args.role,
  });

  if (args.role === "family" && args.childId) {
    await args.supabase.from("child_guardians").upsert({
      child_id: args.childId,
      user_id: data.user.id,
      relationship: args.relationship?.trim() ?? "Familiar",
      can_pick_up: args.canPickUp ?? true,
    });
  }

  return { email: args.email, status: "sent" };
}

function clean(value?: string) {
  const trimmed = value?.trim();
  return trimmed ? trimmed : null;
}

function isEmail(value?: string) {
  return Boolean(value?.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/));
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
