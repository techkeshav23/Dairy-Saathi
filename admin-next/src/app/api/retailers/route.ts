import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Retailer accounts, managed by the distributor (admin). Creating a retailer makes a
// real Supabase Auth user (email + password) AND an app_users profile, so the retailer
// can log into the mobile app with those credentials. All via service_role (server-only).

/* eslint-disable @typescript-eslint/no-explicit-any */

// Standard password policy: 8+ chars with an uppercase, a lowercase and a number.
const PW_RE = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;

export async function GET() {
  if (!supabaseAdmin) return NextResponse.json([]);
  const [uRes, lRes] = await Promise.all([
    supabaseAdmin.from("app_users").select("id, code, business_name, owner_name, area, phone, email, gst, id_type, id_number, credit_limit, status, created_by, role, created_at, orders(id)").eq("role", "retailer"),
    supabaseAdmin.from("ledger_entries").select("user_id, type, amount"),
  ]);
  if (uRes.error) return NextResponse.json({ error: uRes.error.message }, { status: 500 });

  const outMap = new Map<string, number>();
  for (const l of (lRes.data as any[]) ?? []) {
    const cur = outMap.get(l.user_id) ?? 0;
    outMap.set(l.user_id, cur + (l.type === "debit" ? Number(l.amount) : -Number(l.amount)));
  }

  const rows = (uRes.data as any[]).map((u) => ({
    id: u.id,
    code: u.code || "",
    name: u.business_name || u.owner_name || "Retailer",
    owner: u.owner_name || "",
    area: u.area || "",
    phone: u.phone || "",
    email: u.email || "",
    gst: u.gst || "",
    idType: u.id_type || (u.gst ? "gst" : ""),
    idNumber: u.id_number || u.gst || "",
    limit: Number(u.credit_limit) || 0,
    outstanding: Math.max(0, Math.round(outMap.get(u.id) ?? 0)),
    status: u.status || "active",
    role: u.role || "retailer",
    createdBy: u.created_by || "self",
    orders: u.orders?.length ?? 0,
  }));
  return NextResponse.json(rows);
}

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.email?.trim()) return NextResponse.json({ error: "Email is required" }, { status: 400 });
  if (!b?.password || !PW_RE.test(String(b.password))) return NextResponse.json({ error: "Password must be 8+ characters with an uppercase, a lowercase and a number" }, { status: 400 });
  if (String(b.phone ?? "").replace(/\D/g, "").length < 10) return NextResponse.json({ error: "A valid 10-digit phone number is required" }, { status: 400 });
  if (!String(b.idNumber ?? "").trim()) return NextResponse.json({ error: "ID proof (GST / PAN / Aadhaar) is required" }, { status: 400 });

  // 1) create the auth user (email + password, pre-confirmed)
  const { data: created, error: aErr } = await supabaseAdmin.auth.admin.createUser({
    email: b.email.trim(),
    password: b.password,
    email_confirm: true,
    user_metadata: { business_name: b.name ?? "", owner_name: b.owner ?? "", created_by: "admin" },
  });
  if (aErr || !created?.user) return NextResponse.json({ error: aErr?.message || "Could not create login" }, { status: 400 });

  const uid = created.user.id;
  const code = (b.code && String(b.code).trim()) || "R" + Date.now().toString().slice(-6);

  // 2) create the retailer profile. Use upsert because the handle_new_user trigger (v27)
  //    already inserted a minimal row when the auth user was created — upsert fills in the
  //    full admin-entered details (credit limit, code, created_by='admin', etc.).
  const { error: pErr } = await supabaseAdmin.from("app_users").upsert({
    id: uid,
    email: b.email.trim(),
    phone: b.phone ? String(b.phone) : null,
    business_name: b.name ?? "",
    owner_name: b.owner ?? "",
    shop_name: b.name ?? "",
    name: b.owner ?? "",
    area: b.area ?? "",
    gst: b.gst ?? "",
    id_type: b.idType ?? null,
    id_number: (b.idNumber && String(b.idNumber).trim()) || null,
    credit_limit: Number(b.limit) || 0,
    status: "active",
    created_by: "admin",
    code,
  });
  if (pErr) {
    // rollback the auth user so we don't leave an orphan login
    await supabaseAdmin.auth.admin.deleteUser(uid);
    return NextResponse.json({ error: pErr.message }, { status: 500 });
  }
  return NextResponse.json({ ok: true, id: uid, code });
}

export async function PATCH(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.id) return NextResponse.json({ error: "id required" }, { status: 400 });

  const patch: Record<string, unknown> = {};
  if (b.name !== undefined) { patch.business_name = b.name; patch.shop_name = b.name; }
  if (b.owner !== undefined) { patch.owner_name = b.owner; patch.name = b.owner; }
  if (b.area !== undefined) patch.area = b.area;
  if (b.phone !== undefined) patch.phone = b.phone ? String(b.phone) : null;
  if (b.gst !== undefined) patch.gst = b.gst;
  if (b.idType !== undefined) patch.id_type = b.idType;
  if (b.idNumber !== undefined) patch.id_number = (b.idNumber && String(b.idNumber).trim()) || null;
  if (b.limit !== undefined) patch.credit_limit = Number(b.limit) || 0;
  if (b.status !== undefined) patch.status = b.status;
  if (b.role !== undefined) patch.role = b.role;

  // optional password reset — enforce the same policy
  if (b.password) {
    if (!PW_RE.test(String(b.password))) return NextResponse.json({ error: "Password must be 8+ characters with an uppercase, a lowercase and a number" }, { status: 400 });
    await supabaseAdmin.auth.admin.updateUserById(b.id, { password: b.password });
  }

  if (Object.keys(patch).length) {
    const { error } = await supabaseAdmin.from("app_users").update(patch).eq("id", b.id);
    if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  }
  return NextResponse.json({ ok: true });
}

export async function DELETE(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const { id } = await req.json();
  if (!id) return NextResponse.json({ error: "id required" }, { status: 400 });
  // Deleting the auth user cascades to app_users (and its orders/ledger) via FK.
  const { error } = await supabaseAdmin.auth.admin.deleteUser(id);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}
