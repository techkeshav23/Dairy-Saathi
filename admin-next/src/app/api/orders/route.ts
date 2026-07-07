import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function PATCH(req: Request) {
  try {
    const { id, status, payment_status } = await req.json();
    if (!id) {
      return NextResponse.json({ error: "id is required" }, { status: 400 });
    }

    if (!supabaseAdmin) {
      return NextResponse.json({ error: "Supabase not configured" }, { status: 500 });
    }

    const updates: any = {};
    if (status) updates.status = String(status).toLowerCase();
    if (payment_status) updates.payment_status = String(payment_status).toLowerCase();

    const { error } = await supabaseAdmin
      .from("orders")
      .update(updates)
      .eq("id", id);

    if (error) throw error;
    return NextResponse.json({ success: true, id, updates });
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
