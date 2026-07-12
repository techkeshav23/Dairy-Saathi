import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Bill Import: the admin uploads a supplier bill, reviews the parsed line items, sets
// selling MRP/rate + category per row, and confirms only the rows they want. New items are
// created in the catalog with stock from the bill qty; existing (matched) items get their
// stock incremented (and MRP/rate/category updated if the admin edited them).
//
// Category can be a name (created if missing) or empty / "Uncategorized" -> category_id null.

/* eslint-disable @typescript-eslint/no-explicit-any */

type Item = {
  productId?: string | null;   // set when matched to an existing catalog product
  name: string;                // internal / bill name
  displayName?: string;        // customer-facing name (blank => hidden in app)
  category?: string;           // "" or "Uncategorized" => uncategorized
  mrp?: number | string;
  rate?: number | string;      // per-PIECE selling rate (retailer price)
  cratePrice?: number | string;// per-CRATE selling price (0 = no crate option)
  eaPerCrate?: number | string;// pieces in one crate (0 = piece-only)
  stock?: number | string;     // qty from the bill, in PIECES (EA)
};

const num = (v: unknown) => {
  const n = Number(String(v ?? "").replace(/[^0-9.]/g, ""));
  return isNaN(n) ? 0 : n;
};

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const body = await req.json();
  const items: Item[] = Array.isArray(body?.items) ? body.items : [];
  if (items.length === 0) return NextResponse.json({ error: "No items selected" }, { status: 400 });

  const errors: string[] = [];

  // Resolve / create categories once. "" or "uncategorized" => null.
  const { data: existingCats } = await supabaseAdmin.from("categories").select("id, name");
  const catMap = new Map<string, string>();
  (existingCats ?? []).forEach((c: any) => catMap.set(String(c.name).toLowerCase(), c.id));
  const CAT_COLORS = ["#2b50d6", "#0f9d63", "#c07708", "#586172", "#2b6cf0", "#dc4249", "#7c3aed", "#0891b2"];

  async function resolveCategory(name?: string): Promise<string | null> {
    const n = (name ?? "").trim();
    if (!n || n.toLowerCase() === "uncategorized") return null;
    const hit = catMap.get(n.toLowerCase());
    if (hit) return hit;
    const id = "cat_" + Date.now().toString(36) + "_" + catMap.size;
    const { error } = await supabaseAdmin!.from("categories").insert({
      id, name: n, color_hex: CAT_COLORS[catMap.size % CAT_COLORS.length], item_count: 0,
    });
    if (error) { errors.push(`Category "${n}": ${error.message}`); return null; }
    catMap.set(n.toLowerCase(), id);
    return id;
  }

  // Server-side de-dup safety net: match any un-linked row to an existing product by
  // normalized name, so a re-import (or a name the client's matcher missed) RESTOCKS the
  // existing product instead of creating a duplicate. Newly-created products are added to
  // the map too, so a same-name row later in the SAME request also restocks (not duplicates).
  const normName = (s: string) => (s || "").toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
  const byNorm = new Map<string, string>();
  const { data: allProds } = await supabaseAdmin.from("products").select("id, name");
  (allProds ?? []).forEach((p: any) => { const k = normName(p.name); if (k && !byNorm.has(k)) byNorm.set(k, p.id); });

  let created = 0;
  let restocked = 0;

  for (let i = 0; i < items.length; i++) {
    const it = items[i];
    if (!it?.name || !String(it.name).trim()) { errors.push(`Row ${i + 1}: missing name`); continue; }
    const catId = await resolveCategory(it.category);
    const mrp = num(it.mrp);
    const rate = num(it.rate) || mrp;
    const cratePrice = num(it.cratePrice);
    const eaPerCrate = num(it.eaPerCrate);
    const qty = num(it.stock);   // pieces (EA)
    const displayName = (it.displayName && String(it.displayName).trim()) || null;
    const nameKey = normName(it.name);
    const existingId = it.productId || byNorm.get(nameKey) || null;

    if (existingId) {
      // Existing product: increment stock; update mrp/category/display name + crate info if provided.
      const { data: cur } = await supabaseAdmin.from("products").select("stock").eq("id", existingId).single();
      const newStock = (Number(cur?.stock) || 0) + qty;
      const patch: any = { stock: newStock };
      if (mrp > 0) patch.mrp = mrp;
      if (catId !== null) patch.category_id = catId;
      if (displayName) patch.display_name = displayName;
      if (eaPerCrate > 0) patch.ea_per_crate = eaPerCrate;
      if (cratePrice > 0) patch.crate_price = cratePrice;
      const { error } = await supabaseAdmin.from("products").update(patch).eq("id", existingId);
      if (error) { errors.push(`${it.name}: ${error.message}`); continue; }
      if (rate > 0) {
        await supabaseAdmin.from("price_slabs").delete().eq("product_id", existingId);
        await supabaseAdmin.from("price_slabs").insert({ product_id: existingId, min_qty: 1, price_per_unit: rate });
      }
      restocked++;
    } else {
      // New product from the bill.
      const id = `prd_${Date.now().toString(36)}_${i}`;
      const { error } = await supabaseAdmin.from("products").insert({
        id, name: String(it.name).trim(), display_name: displayName,
        brand: "", category_id: catId, unit: "1 unit",
        mrp, moq: 1, stock: qty, image_url: "",
        is_popular: false, is_featured: false, description: "",
        resale_price: 0, ea_per_kg: 0,
        ea_per_crate: eaPerCrate, crate_price: cratePrice,
      });
      if (error) { errors.push(`${it.name}: ${error.message}`); continue; }
      if (rate > 0) {
        await supabaseAdmin.from("price_slabs").insert({ product_id: id, min_qty: 1, price_per_unit: rate });
      }
      created++;
    }
  }

  return NextResponse.json({ ok: true, created, restocked, errors });
}
