import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// AI Bill Reader config (Gemini). The API key is sensitive, so it lives in admin_config
// (service_role only) and is NEVER sent back to the browser — GET returns only whether a
// key is set. All access is server-side via service_role.

/* eslint-disable @typescript-eslint/no-explicit-any */

async function getConfig() {
  if (!supabaseAdmin) return null;
  const { data } = await supabaseAdmin.from("admin_config").select("*").eq("id", 1).single();
  return data;
}

export async function GET() {
  const c = await getConfig();
  return NextResponse.json({
    model: c?.gemini_model || "gemini-2.5-flash",
    enabled: c?.ai_enabled ?? false,
    hasKey: !!(c?.gemini_api_key && String(c.gemini_api_key).trim()),
  });
}

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();

  // Test the current (or supplied) key with a tiny Gemini request.
  if (b?.test) {
    const c = await getConfig();
    const key = (b.gemini_api_key && String(b.gemini_api_key).trim()) || c?.gemini_api_key;
    const model = b.gemini_model || c?.gemini_model || "gemini-2.5-flash";
    if (!key) return NextResponse.json({ ok: false, error: "No API key saved" });
    try {
      const r = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${key}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ contents: [{ parts: [{ text: "Reply with just: OK" }] }] }),
        },
      );
      const j = await r.json();
      if (!r.ok) return NextResponse.json({ ok: false, error: j?.error?.message || `HTTP ${r.status}` });
      const text = j?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
      return NextResponse.json({ ok: true, reply: String(text).trim().slice(0, 40) });
    } catch (e) {
      return NextResponse.json({ ok: false, error: e instanceof Error ? e.message : "Request failed" });
    }
  }

  // Save. Only overwrite the key if a new non-empty value is provided.
  const patch: Record<string, any> = { id: 1, updated_at: new Date().toISOString() };
  if (b.model !== undefined) patch.gemini_model = b.model;
  if (b.enabled !== undefined) patch.ai_enabled = !!b.enabled;
  if (b.gemini_api_key && String(b.gemini_api_key).trim()) patch.gemini_api_key = String(b.gemini_api_key).trim();

  const { error } = await supabaseAdmin.from("admin_config").upsert(patch);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}
