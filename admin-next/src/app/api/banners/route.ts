import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Banners CRUD. Writes go through the service_role client (server-only) because the
// banners table is read-only for anon/authenticated under RLS. GET is public catalog.

export async function GET() {
  if (!supabaseAdmin) return NextResponse.json([]);
  const { data, error } = await supabaseAdmin
    .from("banners")
    .select("id, title, subtitle, tag, accent_hex, image, image_url, active")
    .order("id");
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json(data ?? []);
}

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.title?.trim()) return NextResponse.json({ error: "Title required" }, { status: 400 });
  const id = "bnr_" + Date.now().toString(36);
  const img = (b.image && String(b.image).trim()) || `https://picsum.photos/seed/${id}/900/360`;
  const { error } = await supabaseAdmin.from("banners").insert({
    id,
    title: b.title,
    subtitle: b.subtitle ?? "",
    tag: b.tag ?? "",
    accent_hex: b.color ?? "#2b50d6",
    image: img,
    image_url: img,
    active: b.active ?? true,
  });
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true, id });
}

export async function PATCH(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const b = await req.json();
  if (!b?.id) return NextResponse.json({ error: "id required" }, { status: 400 });

  // Toggle-only request (just id + active): flip visibility without touching the content.
  const isToggleOnly =
    typeof b.active === "boolean" && b.title === undefined && b.subtitle === undefined;

  const patch: Record<string, string | boolean> = {};
  if (typeof b.active === "boolean") patch.active = b.active;

  if (!isToggleOnly) {
    patch.title = b.title ?? "";
    patch.subtitle = b.subtitle ?? "";
    patch.tag = b.tag ?? "";
    patch.accent_hex = b.color ?? "#2b50d6";
    if (b.image && String(b.image).trim()) {
      patch.image = b.image;
      patch.image_url = b.image;
    }
  }

  const { error } = await supabaseAdmin.from("banners").update(patch).eq("id", b.id);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}

export async function DELETE(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ error: "Admin not configured" }, { status: 503 });
  const { id } = await req.json();
  if (!id) return NextResponse.json({ error: "id required" }, { status: 400 });
  const { error } = await supabaseAdmin.from("banners").delete().eq("id", id);
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  return NextResponse.json({ ok: true });
}
