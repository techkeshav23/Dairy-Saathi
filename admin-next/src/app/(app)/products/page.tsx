"use client";
import { useMemo, useState } from "react";
import { Search, Plus, X } from "lucide-react";
import { Card, Pill } from "@/components/ui";
import { products, stockStatus, type Product } from "@/lib/data";
import { inr } from "@/lib/format";

const TINTS = [["#fdecea", "#e2231a"], ["#fbf0e1", "#d97706"], ["#e7f6ec", "#16a34a"], ["#e8eefc", "#2563eb"]];

export default function ProductsPage() {
  const [q, setQ] = useState("");
  const [ver, setVer] = useState(0);
  const [open, setOpen] = useState(false);
  const [form, setForm] = useState<Product>({ name: "", cat: "Milk", mrp: 0, rate: 0, resale: 0, moq: 1, stock: 0, pack: "1 EA" });

  const rows = useMemo(() => products.filter((p) => (p.name + p.cat).toLowerCase().includes(q.toLowerCase())), [q, ver]);

  const save = () => {
    if (!form.name.trim()) return;
    products.unshift({ ...form });
    setOpen(false); setVer((v) => v + 1);
    setForm({ name: "", cat: "Milk", mrp: 0, rate: 0, resale: 0, moq: 1, stock: 0, pack: "1 EA" });
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2 rounded-lg border border-border bg-card px-3">
          <Search size={15} className="text-faint" />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search products…" className="w-48 bg-transparent py-2 text-[13px] outline-none placeholder:text-faint" />
        </div>
        <button onClick={() => setOpen(true)} className="ml-auto flex items-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(15,23,42,.12)]"><Plus size={16} />Add Product</button>
      </div>

      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-[13px]">
            <thead>
              <tr className="border-b border-border text-left text-[11px] uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">Product</th><th className="px-5 py-3 font-semibold">Category</th>
                <th className="px-5 py-3 text-right font-semibold">MRP</th><th className="px-5 py-3 text-right font-semibold">Rate</th>
                <th className="px-5 py-3 text-right font-semibold">Resale</th><th className="px-5 py-3 text-right font-semibold">MOQ</th>
                <th className="px-5 py-3 text-right font-semibold">Stock</th><th className="px-5 py-3 font-semibold">Status</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((p, i) => {
                const t = TINTS[i % TINTS.length];
                return (
                  <tr key={p.name + i} className="border-b border-border2 last:border-0 hover:bg-card2">
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-3">
                        <span className="grid h-9 w-9 place-items-center rounded-lg text-[13px] font-bold" style={{ background: t[0], color: t[1] }}>{p.name[0]}</span>
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
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </Card>

      {open && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4" onClick={() => setOpen(false)}>
          <div className="w-full max-w-lg rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <h3 className="font-semibold">Add Product</h3>
              <button onClick={() => setOpen(false)} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>
            <div className="grid grid-cols-2 gap-4 p-5">
              {([["Product Name", "name"], ["Category", "cat"], ["MRP", "mrp"], ["Rate", "rate"], ["Resale", "resale"], ["MOQ", "moq"], ["Stock", "stock"], ["Pack", "pack"]] as const).map(([label, key]) => (
                <label key={key} className="block">
                  <span className="mb-1 block text-[12px] font-medium text-muted">{label}</span>
                  <input
                    value={(form as Record<string, string | number>)[key] as string | number}
                    onChange={(e) => setForm({ ...form, [key]: ["mrp", "rate", "resale", "moq", "stock"].includes(key) ? Number(e.target.value) || 0 : e.target.value })}
                    className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
                </label>
              ))}
            </div>
            <div className="flex gap-3 px-5 pb-5">
              <button onClick={() => setOpen(false)} className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-fg">Cancel</button>
              <button onClick={save} className="flex-1 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white">Save Product</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
