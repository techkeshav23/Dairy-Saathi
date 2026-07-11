"use client";
import { useCallback, useEffect, useMemo, useState } from "react";
import { Search, Plus, X, Pencil, Trash2, Loader2, Image as ImageIcon } from "lucide-react";
import { Card, Pill } from "@/components/ui";
import ImageInput from "@/components/ImageInput";
import ConfirmDialog from "@/components/ConfirmDialog";
import ProductImport from "@/components/ProductImport";
import { stockStatus } from "@/lib/data";
import { inr } from "@/lib/format";

type P = { id: string; name: string; cat: string; mrp: number; rate: number; resale: number; eaPerKg: number; moq: number; stock: number; pack: string; image: string; slabs?: { min_qty: number; price_per_unit: number }[] };

const TINTS = [["#eef2fe", "#2b50d6"], ["#faf0dc", "#c07708"], ["#e6f6ee", "#0f9d63"], ["#f1f3f7", "#586172"]];
const BLANK: P = { id: "", name: "", cat: "", mrp: 0, rate: 0, resale: 0, eaPerKg: 0, moq: 1, stock: 0, pack: "1 EA", image: "", slabs: [{ min_qty: 1, price_per_unit: 0 }] };

export default function ProductsPage() {
  const [q, setQ] = useState("");
  const [catFilter, setCatFilter] = useState("All");
  const [list, setList] = useState<P[]>([]);
  const [cats, setCats] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<P | null>(null);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState("");
  const [broken, setBroken] = useState<Record<string, boolean>>({});
  const [deleteConfirm, setDeleteConfirm] = useState<string | null>(null);
  const [deleting, setDeleting] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [productsRes, categoriesRes] = await Promise.all([
        fetch("/api/products", { cache: "no-store" }),
        fetch("/api/categories", { cache: "no-store" }),
      ]);
      const productsData = await productsRes.json();
      const categoriesData = await categoriesRes.json();
      setList(productsRes.ok && Array.isArray(productsData) ? productsData : []);
      setCats(
        categoriesRes.ok && Array.isArray(categoriesData)
          ? categoriesData.map((c: { name?: string }) => c.name).filter((n): n is string => !!n).sort()
          : []
      );
    } catch {
      setList([]);
      setCats([]);
    }
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const rows = useMemo(() => list.filter((p) =>
    (catFilter === "All" || p.cat === catFilter) &&
    (p.name + p.cat).toLowerCase().includes(q.toLowerCase())
  ), [q, list, catFilter]);

  const openNew = () => { setErr(""); setModal({ ...BLANK, cat: cats[0] || "", slabs: [{ min_qty: 1, price_per_unit: 0 }] }); };

  const save = async () => {
    if (!modal || !modal.name.trim()) { setErr("Product name is required"); return; }
    if (!modal.cat.trim()) { setErr("Create or select a category first"); return; }
    setSaving(true); setErr("");
    const isEdit = !!modal.id && !modal.id.startsWith("mock_");
    try {
      const res = await fetch("/api/products", {
        method: isEdit ? "PATCH" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(modal),
      });
      const j = await res.json();
      if (!res.ok) { setErr(j.error || "Save failed"); setSaving(false); return; }
      setSaving(false); setModal(null); await load();
    } catch {
      setErr("Network error"); setSaving(false);
    }
  };

  const del = async () => {
    if (!deleteConfirm) return;
    const id = deleteConfirm;
    
    if (id.startsWith("mock_")) { 
      setList((p) => p.filter((x) => x.id !== id)); 
      setDeleteConfirm(null);
      return; 
    }
    
    setDeleting(true);
    setErr("");
    try {
      const res = await fetch("/api/products", { method: "DELETE", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id }) });
      if (!res.ok) {
        const j = await res.json();
        // If it's a foreign key error, give a friendly message
        if (j.error?.includes("violates foreign key constraint")) {
          alert("Cannot delete this product because it is part of existing orders. Please change its stock to 0 instead.");
        } else {
          alert("Failed to delete product: " + (j.error || "Unknown error"));
        }
      } else {
        await load();
      }
    } catch {
      alert("Network error while deleting product.");
    } finally {
      setDeleting(false);
      setDeleteConfirm(null);
    }
  };

  // Create a new category inline (from the product modal) and select it.
  const addCategoryInline = async () => {
    const name = window.prompt("New category name:");
    if (!name || !name.trim()) return;
    try {
      const res = await fetch("/api/categories", { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ name: name.trim() }) });
      const j = await res.json();
      if (res.ok && j.name) {
        setCats((prev) => (prev.includes(j.name) ? prev : [...prev, j.name].sort()));
        setModal((m) => (m ? { ...m, cat: j.name } : m));
      }
    } catch { /* ignore */ }
  };

  const NUM: (keyof P)[] = ["mrp", "rate", "resale", "eaPerKg", "moq", "stock"];

  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:flex-wrap">
        <div className="flex w-full sm:w-auto items-center gap-2 rounded-lg border border-border bg-card px-3">
          <Search size={15} className="text-faint" />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search products…" className="w-full sm:w-44 bg-transparent py-2 text-[13px] outline-none placeholder:text-faint" />
        </div>
        <select value={catFilter} onChange={(e) => setCatFilter(e.target.value)} className="w-full sm:w-auto rounded-lg border border-border bg-card px-3 py-2 text-[13px] font-medium text-fg outline-none focus:border-brand">
          <option value="All">All categories</option>
          {cats.map((c) => <option key={c} value={c}>{c}</option>)}
        </select>
        <span className="hidden sm:inline text-[12px] text-faint">{rows.length} items</span>
        <div className="w-full sm:w-auto sm:ml-auto flex flex-col sm:flex-row gap-2">
          <ProductImport onDone={load} />
          <button onClick={openNew} className="w-full sm:w-auto flex items-center justify-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(43,80,214,.20)] transition hover:opacity-95"><Plus size={16} />Add Product</button>
        </div>
      </div>

      <Card className="overflow-hidden">
        {loading ? (
          <div className="flex h-40 items-center justify-center text-muted"><Loader2 size={22} className="spin" /></div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-[13px]">
              <thead>
                <tr className="border-b border-border text-left text-[11px] uppercase tracking-wide text-faint">
                  <th className="px-5 py-3 font-semibold">Product</th><th className="px-5 py-3 font-semibold">Category</th>
                  <th className="px-5 py-3 text-right font-semibold">MRP</th><th className="px-5 py-3 text-right font-semibold">Rate</th>
                  <th className="px-5 py-3 text-right font-semibold">Resale</th><th className="px-5 py-3 text-right font-semibold">MOQ</th>
                  <th className="px-5 py-3 text-right font-semibold">Stock</th><th className="px-5 py-3 font-semibold">Status</th>
                  <th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody>
                {rows.map((p, i) => {
                  const t = TINTS[i % TINTS.length];
                  return (
                    <tr key={p.id} className="group border-b border-border2 last:border-0 hover:bg-card2">
                      <td className="px-5 py-3">
                        <div className="flex items-center gap-3">
                          {p.image && !broken[p.id] ? (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img src={p.image} alt="" onError={() => setBroken((b) => ({ ...b, [p.id]: true }))} className="h-9 w-9 rounded-lg border border-border object-cover" />
                          ) : (
                            <span className="grid h-9 w-9 place-items-center rounded-lg text-[13px] font-bold" style={{ background: t[0], color: t[1] }}>{p.name[0]}</span>
                          )}
                          <div><div className="font-semibold">{p.name}</div><div className="text-[11px] text-faint">{p.pack}</div></div>
                        </div>
                      </td>
                      <td className="px-5 py-3 text-muted">{p.cat}</td>
                      <td className="tnum px-5 py-3 text-right text-faint line-through">{inr(p.mrp)}</td>
                      <td className="tnum px-5 py-3 text-right font-semibold">{inr(p.rate)}</td>
                      <td className="tnum px-5 py-3 text-right text-success">{inr(p.resale)}</td>
                      <td className="tnum px-5 py-3 text-right">{p.moq}</td>
                      <td className="tnum px-5 py-3 text-right">{p.stock}</td>
                      <td className="px-5 py-3"><Pill s={stockStatus(p.stock)} /></td>
                      <td className="px-5 py-3">
                        <div className="flex justify-end gap-3 text-muted">
                          <button onClick={() => { setErr(""); setModal({ ...p, slabs: p.slabs?.length ? p.slabs : [{ min_qty: 1, price_per_unit: p.rate || 0 }] }); }} title="Edit"><Pencil size={15} className="hover:text-brand" /></button>
                          <button onClick={() => setDeleteConfirm(p.id)} title="Delete"><Trash2 size={15} className="hover:text-danger" /></button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
                {rows.length === 0 && <tr><td colSpan={9} className="px-5 py-12 text-center text-muted">No products found.</td></tr>}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {modal && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4" onClick={() => setModal(null)}>
          <div className="w-full max-w-lg rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <h3 className="text-[15px] font-semibold text-fg">{modal.id && !modal.id.startsWith("mock_") ? "Edit Product" : "Add Product"}</h3>
              <button onClick={() => setModal(null)} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 p-5 max-h-[70vh] overflow-y-auto">
              <label className="sm:col-span-2 block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Product Name</span>
                <input value={modal.name} onChange={(e) => setModal({ ...modal, name: e.target.value })} placeholder="India Gate Basmati Rice 5kg"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="col-span-2 block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Category</span>
                <select value={modal.cat} onChange={(e) => { if (e.target.value === "__new__") addCategoryInline(); else setModal({ ...modal, cat: e.target.value }); }}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand">
                  {cats.map((c) => <option key={c} value={c}>{c}</option>)}
                  <option value="__new__">+ New category…</option>
                </select>
              </label>
              <div className="col-span-2 flex items-end gap-3">
                <div className="flex-1">
                  <ImageInput value={modal.image} onChange={(url) => setModal({ ...modal, image: url })} placeholder="https://…/product.jpg" />
                </div>
                {modal.image
                  ? // eslint-disable-next-line @next/next/no-img-element
                    <img src={modal.image} alt="" className="h-10 w-10 shrink-0 rounded-lg border border-border object-cover" />
                  : <div className="grid h-10 w-10 shrink-0 place-items-center rounded-lg border border-dashed border-border text-faint"><ImageIcon size={16} /></div>}
              </div>
              {(["mrp", "resale", "eaPerKg", "moq", "stock", "pack"] as (keyof P)[]).map((key) => (
                <label key={key} className="block">
                  <span className="mb-1 block text-[12px] font-medium capitalize text-muted">{key === "pack" ? "Pack" : key === "eaPerKg" ? "EA per KG (0 = no KG)" : key}</span>
                  <input
                    type={NUM.includes(key) ? "number" : "text"}
                    value={modal[key] as string | number}
                    onChange={(e) => setModal({ ...modal, [key]: NUM.includes(key) ? Number(e.target.value) || 0 : e.target.value })}
                    className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
                </label>
              ))}
              
              <div className="col-span-2 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="block text-[12px] font-medium text-muted">Pricing Tiers (Bulk Slabs)</span>
                  <button type="button" onClick={() => setModal({ ...modal, slabs: [...(modal.slabs || []), { min_qty: 1, price_per_unit: 0 }] })} className="text-[11px] font-medium text-brand hover:underline">+ Add Tier</button>
                </div>
                {(modal.slabs || [{ min_qty: 1, price_per_unit: modal.rate || 0 }]).map((slab, idx, arr) => (
                  <div key={idx} className="flex items-center gap-3">
                    <div className="relative w-1/2">
                      <span className="absolute left-3 top-1/2 -translate-y-1/2 text-xs font-medium text-muted">Qty ≥</span>
                      <input type="number" value={slab.min_qty} onChange={(e) => {
                        const s = [...arr]; s[idx].min_qty = Number(e.target.value) || 0; setModal({ ...modal, slabs: s });
                      }} className="w-full rounded-lg border border-border bg-card py-2 pl-12 pr-3 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
                    </div>
                    <div className="relative w-1/2">
                      <span className="absolute left-3 top-1/2 -translate-y-1/2 text-xs font-medium text-muted">₹</span>
                      <input type="number" value={slab.price_per_unit} onChange={(e) => {
                        const s = [...arr]; s[idx].price_per_unit = Number(e.target.value) || 0; setModal({ ...modal, slabs: s });
                      }} className="w-full rounded-lg border border-border bg-card py-2 pl-8 pr-3 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
                    </div>
                    <button type="button" onClick={() => {
                      if (arr.length > 1) { const s = [...arr]; s.splice(idx, 1); setModal({ ...modal, slabs: s }); }
                    }} disabled={arr.length <= 1} className="p-1 text-muted hover:text-danger disabled:opacity-30"><Trash2 size={16} /></button>
                  </div>
                ))}
              </div>
              {err && <p className="col-span-2 text-[12px] font-medium text-danger">{err}</p>}
            </div>
            <div className="flex gap-3 px-5 pb-5">
              <button onClick={() => setModal(null)} className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-fg hover:bg-card2">Cancel</button>
              <button onClick={save} disabled={saving} className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white transition hover:opacity-95 disabled:opacity-60">
                {saving && <Loader2 size={15} className="spin" />}{saving ? "Saving…" : "Save Product"}
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!deleteConfirm}
        title="Delete Product"
        desc="Are you sure you want to delete this product? This action cannot be undone."
        confirmText="Delete"
        loading={deleting}
        onConfirm={del}
        onCancel={() => setDeleteConfirm(null)}
      />
    </div>
  );
}
