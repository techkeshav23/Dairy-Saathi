import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Bulk product import. Takes parsed CSV rows, auto-creates any missing categories, then
// inserts all products + a base price slab in batched calls. Server-only (service_role).

/* eslint-disable @typescript-eslint/no-explicit-any */

type Row = {
  name?: string; category?: string; brand?: string; pack?: string;
  mrp?: number | string; rate?: number | string; moq?: number | string;
  stock?: number | string; image?: string;
};

const CAT_COLORS = ["#2b50d6", "#0f9d63", "#c07708", "#586172", "#2b6cf0", "#dc4249", "#7c3aed", "#0891b2"];
const num = (v: unknown) => {
  const n = Number(String(v ?? "").replace(/[^0-9.]/g, ""));
  return isNaN(n) ? 0 : n;
};

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const body = await req.json();
  const rows: Row[] = Array.isArray(body?.rows) ? body.rows : [];
  if (rows.length === 0) return NextResponse.json({ error: "No rows" }, { status: 400 });

  const errors: string[] = [];
  const valid = rows.filter((r, i) => {
    if (!r?.name || !String(r.name).trim()) { errors.push(`Row ${i + 1}: missing product name — skipped`); return false; }
    return true;
  });

  // 1) Resolve / create categories (case-insensitive by name).
  const { data: existingCats } = await supabaseAdmin.from("categories").select("id, name");
  const catMap = new Map<string, string>(); // lower name -> id
  (existingCats ?? []).forEach((c: any) => catMap.set(String(c.name).toLowerCase(), c.id));

  const wantedCats = Array.from(new Set(
    valid.map((r) => String(r.category ?? "").trim()).filter((c) => c.length > 0)
  ));
  let colorIdx = catMap.size;
  let catsCreated = 0;
  for (const name of wantedCats) {
    if (catMap.has(name.toLowerCase())) continue;
    const id = "cat_" + Date.now().toString(36) + "_" + colorIdx;
    const { error } = await supabaseAdmin.from("categories").insert({
      id, name, color_hex: CAT_COLORS[colorIdx % CAT_COLORS.length], item_count: 0,
    });
    if (error) { errors.push(`Category "${name}": ${error.message}`); continue; }
    catMap.set(name.toLowerCase(), id);
    colorIdx++;
    catsCreated++;
  }

  // 2) Build product + slab inserts.
  const stamp = Date.now().toString(36);
  const products: any[] = [];
  const slabs: any[] = [];
  valid.forEach((r, i) => {
    const catId = catMap.get(String(r.category ?? "").trim().toLowerCase()) ?? null;
    const id = `prd_${stamp}_${i}`;
    const mrp = num(r.mrp);
    const rate = num(r.rate) || mrp;
    products.push({
      id, name: String(r.name).trim(), brand: String(r.brand ?? "").trim(),
      category_id: catId, unit: String(r.pack ?? "1 unit").trim() || "1 unit",
      mrp, moq: num(r.moq) || 1, stock: num(r.stock),
      image_url: String(r.image ?? "").trim(),
      is_popular: false, is_featured: false, description: "",
    });
    slabs.push({ product_id: id, min_qty: 1, price_per_unit: rate });
  });

  // 3) Insert in batches (chunked to stay well within limits).
  let created = 0;
  const chunk = 100;
  for (let i = 0; i < products.length; i += chunk) {
    const pSlice = products.slice(i, i + chunk);
    const { error } = await supabaseAdmin.from("products").insert(pSlice);
    if (error) { errors.push(`Products ${i + 1}–${i + pSlice.length}: ${error.message}`); continue; }
    created += pSlice.length;
    const sSlice = slabs.slice(i, i + chunk);
    const { error: sErr } = await supabaseAdmin.from("price_slabs").insert(sSlice);
    if (sErr) errors.push(`Price slabs ${i + 1}–${i + sSlice.length}: ${sErr.message}`);
  }

  return NextResponse.json({
    ok: true,
    created,
    skipped: rows.length - valid.length,
    categoriesCreated: catsCreated,
    errors,
  });
}
