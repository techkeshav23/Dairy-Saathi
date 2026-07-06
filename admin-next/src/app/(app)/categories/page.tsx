"use client";
import { useCallback, useEffect, useState } from "react";
import { Plus, Pencil, Trash2, X, Loader2, Tag } from "lucide-react";
import { Card } from "@/components/ui";
import ConfirmDialog from "@/components/ConfirmDialog";

type Cat = { id: string; name: string; color: string; count: number };
const BLANK: Cat = { id: "", name: "", color: "#2b50d6", count: 0 };

export default function CategoriesPage() {
  const [items, setItems] = useState<Cat[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<Cat | null>(null);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState("");
  const [deleteConfirm, setDeleteConfirm] = useState<Cat | null>(null);
  const [deleting, setDeleting] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/categories", { cache: "no-store" });
      const data = await res.json();
      setItems(Array.isArray(data) ? data : []);
    } catch { setItems([]); }
    setLoading(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  const save = async () => {
    if (!modal || !modal.name.trim()) { setErr("Category name is required"); return; }
    setSaving(true); setErr("");
    try {
      const res = await fetch("/api/categories", {
        method: modal.id ? "PATCH" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id: modal.id, name: modal.name, color: modal.color }),
      });
      const j = await res.json();
      if (!res.ok) { setErr(j.error || "Save failed"); setSaving(false); return; }
      setSaving(false); setModal(null); await load();
    } catch { setErr("Network error"); setSaving(false); }
  };

  const del = async () => {
    if (!deleteConfirm) return;
    setDeleting(true);
    try {
      await fetch("/api/categories", { method: "DELETE", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id: deleteConfirm.id }) });
      await load();
    } catch {
      // ignore
    } finally {
      setDeleting(false);
      setDeleteConfirm(null);
    }
  };

  return (
    <div className="space-y-5">
      <div className="flex items-center">
        <div>
          <h2 className="text-[15px] font-semibold tracking-tight text-fg">Product Categories</h2>
          <p className="mt-0.5 text-[12px] text-faint">Categories shown to retailers when browsing the catalog.</p>
        </div>
        <button onClick={() => { setErr(""); setModal({ ...BLANK }); }} className="ml-auto flex items-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(43,80,214,.20)] transition hover:opacity-95">
          <Plus size={16} />Add Category
        </button>
      </div>

      {loading ? (
        <div className="flex h-40 items-center justify-center text-muted"><Loader2 size={22} className="spin" /></div>
      ) : (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {items.map((c) => (
            <Card key={c.id} className="flex items-center gap-3 p-4">
              <span className="grid h-11 w-11 shrink-0 place-items-center rounded-xl" style={{ background: c.color + "1f", color: c.color }}><Tag size={18} /></span>
              <div className="min-w-0 flex-1">
                <div className="truncate text-[14px] font-semibold text-fg">{c.name}</div>
                <div className="text-[12px] text-faint">{c.count} product{c.count === 1 ? "" : "s"}</div>
              </div>
              <div className="flex gap-2 text-faint">
                <button onClick={() => { setErr(""); setModal({ ...c }); }} title="Edit"><Pencil size={15} className="hover:text-brand" /></button>
                <button onClick={() => setDeleteConfirm(c)} title="Delete"><Trash2 size={15} className="hover:text-danger" /></button>
              </div>
            </Card>
          ))}
          {items.length === 0 && (
            <div className="col-span-full rounded-xl border border-dashed border-border py-14 text-center text-muted">No categories yet. Click “Add Category”.</div>
          )}
        </div>
      )}

      {modal && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4" onClick={() => setModal(null)}>
          <div className="w-full max-w-sm rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <h3 className="text-[15px] font-semibold text-fg">{modal.id ? "Edit Category" : "Add Category"}</h3>
              <button onClick={() => setModal(null)} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>
            <div className="space-y-4 p-5">
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Category Name</span>
                <input autoFocus value={modal.name} onChange={(e) => setModal({ ...modal, name: e.target.value })} placeholder="e.g. Frozen Foods"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Colour</span>
                <div className="flex items-center gap-2 rounded-lg border border-border bg-card px-2 py-1.5">
                  <input type="color" value={modal.color} onChange={(e) => setModal({ ...modal, color: e.target.value })} className="h-7 w-9 cursor-pointer rounded border-0 bg-transparent p-0" />
                  <input value={modal.color} onChange={(e) => setModal({ ...modal, color: e.target.value })} className="w-full bg-transparent text-[13px] text-fg outline-none" />
                </div>
              </label>
              {err && <p className="text-[12px] font-medium text-danger">{err}</p>}
            </div>
            <div className="flex gap-3 px-5 pb-5">
              <button onClick={() => setModal(null)} className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-fg hover:bg-card2">Cancel</button>
              <button onClick={save} disabled={saving} className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white transition hover:opacity-95 disabled:opacity-60">
                {saving && <Loader2 size={15} className="spin" />}{saving ? "Saving…" : "Save Category"}
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteConfirm}
        title="Delete Category"
        desc={`Are you sure you want to delete "${deleteConfirm?.name}"? Its ${deleteConfirm?.count} product(s) will become Uncategorized.`}
        confirmText="Delete"
        loading={deleting}
        onConfirm={del}
        onCancel={() => setDeleteConfirm(null)}
      />
    </div>
  );
}
