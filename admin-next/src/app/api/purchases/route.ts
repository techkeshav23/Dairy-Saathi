import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Purchases / Stock-In. The distributor's supplier bills. Applying a purchase inserts the
// purchase + its line items AND bumps real product stock — all atomically via the
// apply_purchase RPC (see schema_v24). Server-only service_role (RLS-bypassing).

/* eslint-disable @typescript-eslint/no-explicit-any */

export async function GET() {
  if (!supabaseAdmin) return NextResponse.json([]);
  const { data, error } = await supabaseAdmin
    .from("stock_purchases")
    .select("id, supplier, bill_no, bill_date, item_count, amount, source_file, created_at")
    .order("created_at", { ascending: false })
    .limit(50);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  const rows = (data ?? []).map((p: any) => ({
    date: p.bill_date || (p.created_at ? new Date(p.created_at).toISOString().split("T")[0] : ""),
    supplier: p.supplier || "—",
    billNo: p.bill_no || "—",
    items: p.item_count || 0,
    amount: Number(p.amount) || 0,
    file: p.source_file || "",
  }));
  return NextResponse.json(rows);
}

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  const items = Array.isArray(b?.items) ? b.items : [];
  if (items.length === 0) return NextResponse.json({ error: "No items" }, { status: 400 });

  // Normalize items to what apply_purchase expects.
  const payload = items.map((it: any) => ({
    product_id: it.product_id ?? null,
    name: it.name ?? "",
    qty: Number(it.qty) || 0,
    unit: it.unit ?? "EA",
    rate: Number(it.rate) || 0,
    amount: Number(it.amount) || 0,
  }));

  const { data, error } = await supabaseAdmin.rpc("apply_stock_purchase", {
    p_supplier: b.supplier ?? "Supplier",
    p_bill_no: b.billNo ?? "",
    p_bill_date: b.date ?? "",
    p_source: b.file ?? "",
    p_items: payload,
  });
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true, id: data });
}
