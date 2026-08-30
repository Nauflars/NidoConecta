import { createClient } from "npm:@supabase/supabase-js@2";

type BootstrapPayload = {
  centerName: string;
  centerSlug: string;
  adminEmail: string;
  adminName: string;
};

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, x-worker-secret",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return json({ error: "Metodo no permitido" }, 405);
  }

  const expectedSecret = Deno.env.get("WORKER_SECRET");
  const receivedSecret = req.headers.get("x-worker-secret");
  if (!expectedSecret || receivedSecret !== expectedSecret) {
    return json({ error: "No autorizado" }, 401);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey =
    Deno.env.get("SERVICE_ROLE_KEY") ??
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
    Deno.env.get("SUPABASE_SECRET_KEY");

  if (!supabaseUrl || !serviceRoleKey) {
    return json({ error: "Servidor sin claves Supabase" }, 500);
  }

  const payload = (await req.json()) as BootstrapPayload;
  const error = validate(payload);
  if (error) return json({ error }, 400);

  const supabase = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: center, error: centerError } = await supabase
    .from("centers")
    .upsert({
      name: payload.centerName.trim(),
      slug: payload.centerSlug.trim().toLowerCase(),
    }, { onConflict: "slug" })
    .select("id,name,slug")
    .single();

  if (centerError) return json({ error: centerError.message }, 400);

  const { data: invite, error: inviteError } =
    await supabase.auth.admin.inviteUserByEmail(
      payload.adminEmail.trim().toLowerCase(),
      {
        data: {
          full_name: payload.adminName.trim(),
          role: "admin",
          center_id: center.id,
        },
      },
    );

  if (inviteError || !invite.user) {
    return json({ error: inviteError?.message ?? "No se pudo invitar" }, 400);
  }

  await supabase.from("profiles").upsert({
    id: invite.user.id,
    full_name: payload.adminName.trim(),
  });

  await supabase.from("center_memberships").upsert({
    center_id: center.id,
    user_id: invite.user.id,
    role: "admin",
  });

  return json({ center, adminUserId: invite.user.id });
});

function validate(payload: BootstrapPayload) {
  if (!payload?.centerName?.trim()) return "Falta nombre del centro";
  if (!payload?.centerSlug?.trim()) return "Falta slug del centro";
  if (!payload?.adminName?.trim()) return "Falta nombre de direccion";
  if (!payload?.adminEmail?.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
    return "Email de direccion no valido";
  }
  return null;
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
