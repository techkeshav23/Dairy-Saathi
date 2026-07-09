"use client";
import { useCallback, useEffect, useState } from "react";
import { Plus, Pencil, Trash2, X, Loader2, ImageIcon } from "lucide-react";
import ImageInput from "@/components/ImageInput";

type Banner = { id: string; title: string; sub: string; tag: string; color: string; image: string; active: boolean };

const BLANK: Banner = { id: "", title: "", sub: "", tag: "OFFER", color: "#2b50d6", image: "", active: true };
const TAGS = ["OFFER", "STOCK AVAILABLE", "KHATA", "NEW", "COMBO", "SALE"];

function BannerArt({ image, color, children }: { image: string; color: string; children: React.ReactNode }) {
  const hasColor = !!color && color.trim() !== "";
  return (
    <div className="relative flex min-h-[130px] flex-col justify-center overflow-hidden p-5 text-white">
      {image ? (
        <>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src={image} alt="" className="absolute inset-0 h-full w-full object-cover" />
          {hasColor ? (
            <div className="absolute inset-0" style={{ background: `linear-gradient(120deg, ${color}f2 0%, ${color}b3 55%, ${color}66 100%)` }} />
          ) : (
            /* image only — subtle dark scrim so overlaid text stays legible */
            <div className="absolute inset-0 bg-gradient-to-t from-black/55 via-black/10 to-transparent" />
          )}
        </>
      ) : (
        <div className="absolute inset-0" style={{ background: hasColor ? `linear-gradient(135deg, ${color}, ${color}cc)` : "linear-gradient(135deg,#334155,#0f172a)" }} />
      )}
      <div className="relative z-10">{children}</div>
    </div>
  );
}

export default function BannersPage() {
  const [items, setItems] = useState<Banner[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<Banner | null>(null);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState("");

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/banners", { cache: "no-store" });
      const data = await res.json();
      if (Array.isArray(data)) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        setItems(data.map((b: any) => ({ id: b.id, title: b.title || "", sub: b.subtitle || "", tag: b.tag || "", color: b.accent_hex ?? "#2b50d6", image: b.image || b.image_url || "", active: b.active !== false })));
      } else {
        setItems([]);
      }
    } catch {
      setItems([]);
    }
    setLoading(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  const toggle = async (id: string) => {
    const target = items.find((b) => b.id === id);
    if (!target) return;
    const next = !target.active;
    // optimistic flip
    setItems((p) => p.map((b) => (b.id === id ? { ...b, active: next } : b)));
    try {
      const res = await fetch("/api/banners", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, active: next }),
      });
      if (!res.ok) throw new Error();
    } catch {
      // revert on failure
      setItems((p) => p.map((b) => (b.id === id ? { ...b, active: !next } : b)));
    }
  };

  const save = async () => {
    if (!modal || (!modal.title.trim() && !modal.image.trim())) { setErr("Add a title or an image"); return; }
    setSaving(true); setErr("");
    const isEdit = !!modal.id;
    try {
      const res = await fetch("/api/banners", {
        method: isEdit ? "PATCH" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: modal.id, title: modal.title, subtitle: modal.sub, tag: modal.tag, color: modal.color, image: modal.image, active: modal.active }),
      });
      const j = await res.json();
      if (!res.ok) { setErr(j.error || "Save failed"); setSaving(false); return; }
      setSaving(false); setModal(null); await load();
    } catch {
      setErr("Network error"); setSaving(false);
    }
  };

  const del = async (id: string) => {
    if (!confirm("Delete this banner?")) return;
    await fetch("/api/banners", { method: "DELETE", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id }) });
    await load();
  };

  return (
    <div className="space-y-5">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
        <div>
          <h2 className="text-[15px] font-semibold tracking-tight text-fg">Promotional Banners</h2>
          <p className="mt-0.5 text-[12px] text-faint">Shown on the retailer app home screen.</p>
        </div>
        <button onClick={() => { setErr(""); setModal({ ...BLANK }); }} className="w-full sm:w-auto sm:ml-auto flex items-center justify-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(43,80,214,.20)] transition hover:opacity-95">
          <Plus size={16} />Add Banner
        </button>
      </div>

      {loading ? (
        <div className="flex h-40 items-center justify-center text-muted"><Loader2 size={22} className="spin" /></div>
      ) : (
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {items.map((b) => (
            <div key={b.id} className="overflow-hidden rounded-xl border border-border bg-card elev-1">
              <BannerArt image={b.image} color={b.color}>
                {b.tag && <span className="self-start rounded bg-white/25 px-2 py-0.5 text-[10px] font-bold tracking-wider backdrop-blur-sm">{b.tag}</span>}
                <h4 className="mt-2.5 text-xl font-bold drop-shadow-sm">{b.title}</h4>
                <p className="mt-1 text-[13px] text-white/90 drop-shadow-sm">{b.sub}</p>
              </BannerArt>
              <div className="flex items-center justify-between px-4 py-3">
                <button onClick={() => toggle(b.id)} className="flex items-center gap-2 text-[13px] font-medium text-muted">
                  <span className={`relative h-5 w-9 rounded-full transition ${b.active ? "bg-success" : "bg-border"}`}>
                    <span className={`absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition-all ${b.active ? "left-[18px]" : "left-0.5"}`} />
                  </span>
                  {b.active ? "Active" : "Inactive"}
                </button>
                <div className="flex gap-3 text-faint">
                  <button onClick={() => { setErr(""); setModal({ ...b }); }} title="Edit"><Pencil size={16} className="cursor-pointer transition-colors hover:text-brand" /></button>
                  <button onClick={() => del(b.id)} title="Delete"><Trash2 size={16} className="cursor-pointer transition-colors hover:text-danger" /></button>
                </div>
              </div>
            </div>
          ))}
          {items.length === 0 && (
            <div className="col-span-full rounded-xl border border-dashed border-border py-14 text-center text-muted">No banners yet. Click “Add Banner” to create one.</div>
          )}
        </div>
      )}

      {/* Add / Edit modal */}
      {modal && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4" onClick={() => setModal(null)}>
          <div className="w-full max-w-md rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <h3 className="text-[15px] font-semibold text-fg">{modal.id ? "Edit Banner" : "Add Banner"}</h3>
              <button onClick={() => setModal(null)} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>

            {/* live preview */}
            <div className="px-5 pt-5">
              <div className="overflow-hidden rounded-xl">
                <BannerArt image={modal.image} color={modal.color}>
                  {modal.tag && <span className="self-start rounded bg-white/25 px-2 py-0.5 text-[9px] font-bold tracking-wider">{modal.tag}</span>}
                  <h4 className="mt-1.5 text-lg font-bold drop-shadow-sm">{modal.title || "Banner title"}</h4>
                  <p className="text-[12px] text-white/90 drop-shadow-sm">{modal.sub || "Subtitle text"}</p>
                </BannerArt>
              </div>
            </div>

            <div className="space-y-4 p-5">
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Title</span>
                <input value={modal.title} onChange={(e) => setModal({ ...modal, title: e.target.value })} placeholder="Aaj ka Bumper Stock"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Subtitle</span>
                <input value={modal.sub} onChange={(e) => setModal({ ...modal, sub: e.target.value })} placeholder="Basmati • Atta • Oil — bulk rate par"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <div className="block">
                <ImageInput value={modal.image} onChange={(url) => setModal({ ...modal, image: url })} placeholder="https://…/banner.jpg" />
              </div>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Tag</span>
                <select value={modal.tag} onChange={(e) => setModal({ ...modal, tag: e.target.value })}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand">
                  <option value="">No tag</option>
                  {TAGS.map((t) => <option key={t} value={t}>{t}</option>)}
                </select>
              </label>

              {/* Colour overlay toggle — off = raw image only */}
              <div className="flex items-center justify-between rounded-lg border border-border bg-card2 px-3 py-2.5">
                <div>
                  <div className="text-[12.5px] font-medium text-fg">Colour overlay</div>
                  <div className="text-[11px] text-faint">Turn off to show only the image (no colour tint)</div>
                </div>
                <button type="button" aria-label="Toggle colour overlay" onClick={() => setModal({ ...modal, color: modal.color ? "" : "#2b50d6" })}
                  className={`relative h-5 w-9 shrink-0 rounded-full transition ${modal.color ? "bg-brand" : "bg-border"}`}>
                  <span className={`absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition-all ${modal.color ? "left-[18px]" : "left-0.5"}`} />
                </button>
              </div>

              {modal.color && (
                <label className="block">
                  <span className="mb-1 block text-[12px] font-medium text-muted">Overlay colour</span>
                  <div className="flex items-center gap-2 rounded-lg border border-border bg-card px-2 py-1.5">
                    <input type="color" value={modal.color} onChange={(e) => setModal({ ...modal, color: e.target.value })} className="h-7 w-9 cursor-pointer rounded border-0 bg-transparent p-0" />
                    <input value={modal.color} onChange={(e) => setModal({ ...modal, color: e.target.value })} className="w-full bg-transparent text-[13px] text-fg outline-none" />
                  </div>
                </label>
              )}
              {err && <p className="text-[12px] font-medium text-danger">{err}</p>}
            </div>

            <div className="flex gap-3 px-5 pb-5">
              <button onClick={() => setModal(null)} className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-fg hover:bg-card2">Cancel</button>
              <button onClick={save} disabled={saving} className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white transition hover:opacity-95 disabled:opacity-60">
                {saving && <Loader2 size={15} className="spin" />}{saving ? "Saving…" : "Save Banner"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
