import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Assign one category to many products at once (bulk). Used to quickly categorize the
// products created via Bill Import (filter by Uncategorized -> select many -> assign).
// category "" or "Uncategorized" => category_id null.

/* eslint-disable @typescript-eslint/no-explicit-any */

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  const ids: string[] = Array.isArray(b?.ids) ? b.ids : [];
  const name = String(b?.category ?? "").trim();
  if (ids.length === 0) return NextResponse.json({ error: "No products selected" }, { status: 400 });

  let categoryId: string | null = null;
  if (name && name.toLowerCase() !== "uncategorized") {
    const { data: cats } = await supabaseAdmin.from("categories").select("id, name");
    const hit = (cats ?? []).find((c: any) => String(c.name).toLowerCase() === name.toLowerCase());
    if (hit) categoryId = hit.id;
    else {
      const id = "cat_" + Date.now().toString(36);
      const { error } = await supabaseAdmin.from("categories").insert({ id, name, color_hex: "#2b50d6", item_count: 0 });
      if (error) return NextResponse.json({ error: error.message }, { status: 500 });
      categoryId = id;
    }
  }

  const { error } = await supabaseAdmin.from("products").update({ category_id: categoryId }).in("id", ids);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true, updated: ids.length });
}
