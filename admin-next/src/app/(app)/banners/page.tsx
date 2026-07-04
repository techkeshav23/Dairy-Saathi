"use client";
import { useState } from "react";
import { Plus, Pencil, Eye } from "lucide-react";
import { banners as seed } from "@/lib/data";

export default function BannersPage() {
  const [items, setItems] = useState(seed.map((b) => ({ ...b })));
  const toggle = (i: number) => setItems((p) => p.map((b, idx) => (idx === i ? { ...b, active: !b.active } : b)));

  return (
    <div className="space-y-4">
      <div className="flex items-center">
        <h2 className="text-base font-semibold">Promotional Banners</h2>
        <button className="ml-auto flex items-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(15,23,42,.12)]"><Plus size={16} />Add Banner</button>
      </div>
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {items.map((b, i) => (
          <div key={i} className="overflow-hidden rounded-xl border border-border bg-card shadow-[0_1px_2px_rgba(16,24,40,.04)]">
            <div className="flex min-h-[130px] flex-col justify-center p-5 text-white" style={{ background: `linear-gradient(135deg, ${b.color}, ${b.color}cc)` }}>
              <span className="self-start rounded bg-white/25 px-2 py-0.5 text-[10px] font-bold tracking-wider">{b.tag}</span>
              <h4 className="mt-2.5 text-xl font-bold">{b.title}</h4>
              <p className="mt-1 text-[13px] text-white/90">{b.sub}</p>
            </div>
            <div className="flex items-center justify-between px-4 py-3">
              <button onClick={() => toggle(i)} className="flex items-center gap-2 text-[13px] font-medium text-muted">
                <span className={`relative h-5 w-9 rounded-full transition ${b.active ? "bg-success" : "bg-border"}`}>
                  <span className={`absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition-all ${b.active ? "left-[18px]" : "left-0.5"}`} />
                </span>
                {b.active ? "Active" : "Inactive"}
              </button>
              <div className="flex gap-3 text-faint">
                <Pencil size={17} className="cursor-pointer hover:text-brand" />
                <Eye size={17} className="cursor-pointer hover:text-brand" />
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
