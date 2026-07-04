import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Categories CRUD via service_role (server-only). New categories get no icon_code
// (the mobile app falls back to a default category icon) and an admin-chosen colour.

/* eslint-disable @typescript-eslint/no-explicit-any */

export async function GET() {
  if (!supabaseAdmin) return NextResponse.json([]);
  const { data, error } = await supabaseAdmin
    .from("categories")
    .select("id, name, color_hex, products(count)")
    .order("name");
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  const rows = (data ?? []).map((c: any) => ({
    id: c.id,
    name: c.name || "",
    color: c.color_hex || "#2b50d6",
    count: Array.isArray(c.products) ? (c.products[0]?.count ?? 0) : 0,
  }));
  return NextResponse.json(rows);
}

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.name?.trim()) return NextResponse.json({ error: "Category name required" }, { status: 400 });

  // reuse an existing category with the same name (case-insensitive) if present
  const { data: existing } = await supabaseAdmin.from("categories").select("id, name");
  const dup = (existing ?? []).find((c: any) => String(c.name).toLowerCase() === b.name.trim().toLowerCase());
  if (dup) return NextResponse.json({ ok: true, id: dup.id, name: dup.name, existed: true });

  const id = "cat_" + Date.now().toString(36);
  const { error } = await supabaseAdmin.from("categories").insert({
    id, name: b.name.trim(), color_hex: b.color ?? "#2b50d6", item_count: 0,
  });
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true, id, name: b.name.trim() });
}

export async function PATCH(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.id) return NextResponse.json({ error: "id required" }, { status: 400 });
  const { error } = await supabaseAdmin.from("categories").update({
    name: b.name, color_hex: b.color ?? "#2b50d6",
  }).eq("id", b.id);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}

export async function DELETE(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const { id } = await req.json();
  if (!id) return NextResponse.json({ error: "id required" }, { status: 400 });
  // products.category_id is ON DELETE SET NULL — products become "Uncategorized", not deleted.
  const { error } = await supabaseAdmin.from("categories").delete().eq("id", id);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}
