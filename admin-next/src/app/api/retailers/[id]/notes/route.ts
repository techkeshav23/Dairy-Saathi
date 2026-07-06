import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: Request, props: { params: Promise<{ id: string }> }) {
  try {
    const params = await props.params;
    const retailer_id = params.id;
    const { note, type } = await req.json();

    if (!note) {
      return NextResponse.json({ error: "Note content is required" }, { status: 400 });
    }

    const { error } = await supabaseAdmin
      .from("retailer_notes")
      .insert({ retailer_id, note, type: type || 'note' });

    if (error) throw error;

    return NextResponse.json({ ok: true });
  } catch (err: any) {
    console.error("Failed to add note:", err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
