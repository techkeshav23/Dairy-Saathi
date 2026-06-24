"use client";
import { useMemo, useState } from "react";
import { Search, Plus } from "lucide-react";
import { Card, Pill } from "@/components/ui";
import { retailers } from "@/lib/data";
import { inr } from "@/lib/format";

export default function RetailersPage() {
  const [q, setQ] = useState("");
  const rows = useMemo(() => retailers.filter((r) => (r.name + r.owner + r.area).toLowerCase().includes(q.toLowerCase())), [q]);
  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2 rounded-lg border border-border bg-card px-3">
          <Search size={15} className="text-faint" />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search retailers…" className="w-48 bg-transparent py-2 text-[13px] outline-none placeholder:text-faint" />
        </div>
        <button className="ml-auto flex items-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(226,35,26,.25)]"><Plus size={16} />Add Retailer</button>
      </div>
      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-[13px]">
            <thead>
              <tr className="border-b border-border text-left text-[11px] uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">Code</th><th className="px-5 py-3 font-semibold">Shop / Owner</th>
                <th className="px-5 py-3 font-semibold">Area</th><th className="px-5 py-3 font-semibold">Phone</th>
                <th className="px-5 py-3 text-right font-semibold">Credit Limit</th><th className="px-5 py-3 text-right font-semibold">Outstanding</th>
                <th className="px-5 py-3 font-semibold">KYC</th><th className="px-5 py-3 text-right font-semibold">Orders</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r) => (
                <tr key={r.code} className="border-b border-border2 last:border-0 hover:bg-card2">
                  <td className="px-5 py-3 font-semibold">#{r.code}</td>
                  <td className="px-5 py-3">{r.name}<div className="text-[11px] text-faint">{r.owner}</div></td>
                  <td className="px-5 py-3 text-muted">{r.area}</td>
                  <td className="px-5 py-3 text-muted">{r.phone}</td>
                  <td className="tnum px-5 py-3 text-right">{inr(r.limit)}</td>
                  <td className={`tnum px-5 py-3 text-right font-medium ${r.outstanding > 0 ? "text-brand" : "text-success"}`}>{inr(r.outstanding)}</td>
                  <td className="px-5 py-3"><Pill s={r.kyc} /></td>
                  <td className="tnum px-5 py-3 text-right">{r.orders}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
