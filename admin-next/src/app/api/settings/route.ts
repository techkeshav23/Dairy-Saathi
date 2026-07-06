import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function GET() {
  try {
    if (!supabaseAdmin) {
      return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
    }
    const { data, error } = await supabaseAdmin
      .from("store_settings")
      .select("*")
      .eq("id", 1)
      .single();

    if (error && error.code !== "PGRST116") throw error; // PGRST116 is no rows found

    return NextResponse.json(data || {});
  } catch (err: any) {
    console.error("Settings GET Error:", err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}

export async function POST(req: Request) {
  try {
    if (!supabaseAdmin) {
      return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
    }
    const body = await req.json();

    const { error } = await supabaseAdmin
      .from("store_settings")
      .upsert({ id: 1, ...body, updated_at: new Date().toISOString() });

    if (error) throw error;

    return NextResponse.json({ ok: true });
  } catch (err: any) {
    console.error("Settings POST Error:", err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
