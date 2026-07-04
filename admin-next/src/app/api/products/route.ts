import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Products CRUD via the service_role client (server-only). Maps the admin's simple
// product shape to the products table + a base price_slab. Category is matched by name.

/* eslint-disable @typescript-eslint/no-explicit-any */

async function resolveCategoryId(name: string): Promise<string | null> {
  if (!supabaseAdmin || !name) return null;
  const { data } = await supabaseAdmin.from("categories").select("id, name");
  const m = (data ?? []).find((c: any) => String(c.name).toLowerCase() === name.toLowerCase());
  return m ? m.id : null;
}

export async function GET() {
  if (!supabaseAdmin) return NextResponse.json([]);
  const { data, error } = await supabaseAdmin
    .from("products")
    .select("id, name, brand, unit, mrp, moq, stock, image_url, categories(name), price_slabs(min_qty, price_per_unit)")
    .order("name");
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  const rows = (data ?? []).map((p: any) => {
    const cat = Array.isArray(p.categories) ? p.categories[0]?.name : p.categories?.name;
    const prices = (p.price_slabs ?? []).map((s: any) => Number(s.price_per_unit)).filter((n: number) => n > 0);
    const rate = prices.length ? Math.min(...prices) : Number(p.mrp);
    return { id: p.id, name: p.name || "", cat: cat || "Uncategorized", mrp: Number(p.mrp) || 0, rate: rate || 0, resale: Number(p.mrp) || 0, moq: p.moq || 1, stock: p.stock || 0, pack: p.unit || "1 unit", image: p.image_url || "" };
  });
  return NextResponse.json(rows);
}

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.name?.trim()) return NextResponse.json({ error: "Name required" }, { status: 400 });
  const id = "prd_" + Date.now().toString(36);
  const cid = await resolveCategoryId(b.cat);
  const { error } = await supabaseAdmin.from("products").insert({
    id, name: b.name, brand: b.brand ?? "", category_id: cid, unit: b.pack ?? "1 unit",
    mrp: Number(b.mrp) || 0, moq: Number(b.moq) || 1, stock: Number(b.stock) || 0,
    image_url: (b.image && String(b.image).trim()) || "",
    is_popular: false, is_featured: false, description: b.description ?? "",
  });
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  if (Number(b.rate) > 0) {
    await supabaseAdmin.from("price_slabs").insert({ product_id: id, min_qty: 1, price_per_unit: Number(b.rate) });
  }
  return NextResponse.json({ ok: true, id });
}

export async function PATCH(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.id) return NextResponse.json({ error: "id required" }, { status: 400 });
  const cid = await resolveCategoryId(b.cat);
  const { error } = await supabaseAdmin.from("products").update({
    name: b.name, category_id: cid, unit: b.pack ?? "1 unit",
    mrp: Number(b.mrp) || 0, moq: Number(b.moq) || 1, stock: Number(b.stock) || 0,
    image_url: (b.image && String(b.image).trim()) || "",
  }).eq("id", b.id);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  if (Number(b.rate) > 0) {
    await supabaseAdmin.from("price_slabs").delete().eq("product_id", b.id);
    await supabaseAdmin.from("price_slabs").insert({ product_id: b.id, min_qty: 1, price_per_unit: Number(b.rate) });
  }
  return NextResponse.json({ ok: true });
}

export async function DELETE(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const { id } = await req.json();
  if (!id) return NextResponse.json({ error: "id required" }, { status: 400 });
  const { error } = await supabaseAdmin.from("products").delete().eq("id", id);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}
