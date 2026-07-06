import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function PATCH(req: Request) {
  try {
    const { id, status } = await req.json();
    if (!id || !status) {
      return NextResponse.json({ error: "id and status are required" }, { status: 400 });
    }

    if (!supabaseAdmin) {
      return NextResponse.json({ error: "Supabase not configured" }, { status: 500 });
    }

    // Must map UI Status back to lowercase DB enum
    const dbStatus = String(status).toLowerCase();

    const { error } = await supabaseAdmin
      .from("orders")
      .update({ status: dbStatus })
      .eq("id", id);

    if (error) throw error;
    return NextResponse.json({ success: true, id, status: dbStatus });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
