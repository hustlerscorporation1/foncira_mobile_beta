// ══════════════════════════════════════════════════════════════
//  FONCIRA — Supabase Edge Function: Create Agent
// ══════════════════════════════════════════════════════════════
// Deploy as: supabase functions deploy create-agent

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

interface CreateAgentRequest {
  email: string;
  firstName: string;
  specialization?: string;
}

serve(async (req) => {
  // CORS headers
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: { "Access-Control-Allow-Origin": "*" },
    });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
    const supabaseServiceRoleKey =
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

    const supabase = createClient(supabaseUrl, supabaseServiceRoleKey);

    const body: CreateAgentRequest = await req.json();
    const { email, firstName, specialization } = body;

    // Validation
    if (!email || !firstName) {
      return new Response(
        JSON.stringify({ error: "Email et prénom sont obligatoires" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // 1. Créer l'utilisateur dans Supabase Auth
    const { data: authUser, error: authError } =
      await supabase.auth.admin.createUser({
        email,
        password: Math.random().toString(36).slice(-12), // Temporary password
        email_confirm: true,
      });

    if (authError) {
      return new Response(
        JSON.stringify({ error: `Auth error: ${authError.message}` }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const userId = authUser?.user?.id;

    // 2. Insérer dans la table users avec role='agent'
    const { error: userError } = await supabase.from("users").insert({
      id: userId,
      email,
      name: firstName,
      role: "agent",
      is_active: true,
      country: "Togo", // Default
    });

    if (userError) {
      return new Response(
        JSON.stringify({ error: `User insert error: ${userError.message}` }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // 3. Insérer dans la table agents
    const { error: agentError } = await supabase.from("agents").insert({
      user_id: userId,
      name: firstName,
      specialization: specialization || null,
      is_available: true,
      current_workload: 0,
      completed_verifications: 0,
      average_rating: 0,
    });

    if (agentError) {
      return new Response(
        JSON.stringify({ error: `Agent insert error: ${agentError.message}` }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    // 4. Envoyer un email d'invitation au nouvel agent (optionnel)
    // Vous pouvez ajouter ici un appel à un service d'email

    return new Response(
      JSON.stringify({
        success: true,
        message: "Agent créé avec succès",
        userId,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
