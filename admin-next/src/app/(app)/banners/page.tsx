"use client";
import { useCallback, useEffect, useState } from "react";
import { Plus, Pencil, Trash2, X, Loader2 } from "lucide-react";
import { banners as seed } from "@/lib/data";

type Banner = { id: string; title: string; sub: string; tag: string; color: string; active: boolean };

const BLANK: Banner = { id: "", title: "", sub: "", tag: "OFFER", color: "#2b50d6", active: true };
const TAGS = ["OFFER", "STOCK AVAILABLE", "KHATA", "NEW", "COMBO", "SALE"];

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
      if (Array.isArray(data) && data.length) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        setItems(data.map((b: any) => ({ id: b.id, title: b.title || "", sub: b.subtitle || "", tag: b.tag || "", color: b.accent_hex || "#2b50d6", active: true })));
      } else {
        setItems(seed.map((b, i) => ({ ...b, id: "seed_" + i })));
      }
    } catch {
      setItems(seed.map((b, i) => ({ ...b, id: "seed_" + i })));
    }
    setLoading(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  const toggle = (id: string) => setItems((p) => p.map((b) => (b.id === id ? { ...b, active: !b.active } : b)));

  const save = async () => {
    if (!modal || !modal.title.trim()) { setErr("Title is required"); return; }
    setSaving(true); setErr("");
    const isEdit = !!modal.id && !modal.id.startsWith("seed_");
    try {
      const res = await fetch("/api/banners", {
        method: isEdit ? "PATCH" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: modal.id, title: modal.title, subtitle: modal.sub, tag: modal.tag, color: modal.color }),
      });
      const j = await res.json();
      if (!res.ok) { setErr(j.error || "Save failed"); setSaving(false); return; }
      setSaving(false); setModal(null); await load();
    } catch {
      setErr("Network error"); setSaving(false);
    }
  };

  const del = async (id: string) => {
    if (id.startsWith("seed_")) { setItems((p) => p.filter((b) => b.id !== id)); return; }
    if (!confirm("Delete this banner?")) return;
    await fetch("/api/banners", { method: "DELETE", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id }) });
    await load();
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center">
        <div>
          <h2 className="text-[15px] font-semibold tracking-tight text-fg">Promotional Banners</h2>
          <p className="mt-0.5 text-[12px] text-faint">Shown on the retailer app home screen.</p>
        </div>
        <button onClick={() => { setErr(""); setModal({ ...BLANK }); }} className="ml-auto flex items-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(43,80,214,.20)] transition hover:opacity-95">
          <Plus size={16} />Add Banner
        </button>
      </div>

      {loading ? (
        <div className="flex h-40 items-center justify-center text-muted"><Loader2 size={22} className="spin" /></div>
      ) : (
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {items.map((b) => (
            <div key={b.id} className="overflow-hidden rounded-xl border border-border bg-card elev-1">
              <div className="flex min-h-[130px] flex-col justify-center p-5 text-white" style={{ background: `linear-gradient(135deg, ${b.color}, ${b.color}cc)` }}>
                {b.tag && <span className="self-start rounded bg-white/25 px-2 py-0.5 text-[10px] font-bold tracking-wider">{b.tag}</span>}
                <h4 className="mt-2.5 text-xl font-bold">{b.title}</h4>
                <p className="mt-1 text-[13px] text-white/90">{b.sub}</p>
              </div>
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
              <h3 className="text-[15px] font-semibold text-fg">{modal.id && !modal.id.startsWith("seed_") ? "Edit Banner" : "Add Banner"}</h3>
              <button onClick={() => setModal(null)} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>

            {/* live preview */}
            <div className="px-5 pt-5">
              <div className="flex min-h-[104px] flex-col justify-center rounded-xl p-4 text-white" style={{ background: `linear-gradient(135deg, ${modal.color}, ${modal.color}cc)` }}>
                {modal.tag && <span className="self-start rounded bg-white/25 px-2 py-0.5 text-[9px] font-bold tracking-wider">{modal.tag}</span>}
                <h4 className="mt-1.5 text-lg font-bold">{modal.title || "Banner title"}</h4>
                <p className="text-[12px] text-white/90">{modal.sub || "Subtitle text"}</p>
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
              <div className="grid grid-cols-2 gap-4">
                <label className="block">
                  <span className="mb-1 block text-[12px] font-medium text-muted">Tag</span>
                  <select value={modal.tag} onChange={(e) => setModal({ ...modal, tag: e.target.value })}
                    className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand">
                    {TAGS.map((t) => <option key={t} value={t}>{t}</option>)}
                  </select>
                </label>
                <label className="block">
                  <span className="mb-1 block text-[12px] font-medium text-muted">Colour</span>
                  <div className="flex items-center gap-2 rounded-lg border border-border bg-card px-2 py-1.5">
                    <input type="color" value={modal.color} onChange={(e) => setModal({ ...modal, color: e.target.value })} className="h-7 w-9 cursor-pointer rounded border-0 bg-transparent p-0" />
                    <input value={modal.color} onChange={(e) => setModal({ ...modal, color: e.target.value })} className="w-full bg-transparent text-[13px] text-fg outline-none" />
                  </div>
                </label>
              </div>
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
