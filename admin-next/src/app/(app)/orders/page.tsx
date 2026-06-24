"use client";
import { useMemo, useState } from "react";
import { Search, Download, ChevronRight } from "lucide-react";
import { Card, Pill } from "@/components/ui";
import { orders } from "@/lib/data";
import { inr } from "@/lib/format";

const CHIPS = ["All", "Placed", "Confirmed", "Packed", "Dispatched", "Delivered", "Cancelled"];

export default function OrdersPage() {
  const [chip, setChip] = useState("All");
  const [q, setQ] = useState("");

  const rows = useMemo(() => {
    return orders.filter((o) =>
      (chip === "All" || o.status === chip) &&
      (q === "" || (o.ref + o.retailer + o.area).toLowerCase().includes(q.toLowerCase()))
    );
  }, [chip, q]);

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex flex-wrap gap-2">
          {CHIPS.map((c) => (
            <button key={c} onClick={() => setChip(c)}
              className={`rounded-full border px-3.5 py-1.5 text-[12.5px] font-medium transition ${
                chip === c ? "border-brand bg-brand text-white shadow-[0_6px_14px_rgba(226,35,26,.25)]" : "border-border bg-card text-muted hover:text-fg"
              }`}>{c}</button>
          ))}
        </div>
        <div className="ml-auto flex items-center gap-2">
          <div className="flex items-center gap-2 rounded-lg border border-border bg-card px-3">
            <Search size={15} className="text-faint" />
            <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search orders…" className="w-44 bg-transparent py-2 text-[13px] outline-none placeholder:text-faint" />
          </div>
          <button className="flex items-center gap-2 rounded-lg border border-border bg-card px-3 py-2 text-[13px] font-medium text-fg hover:bg-card2"><Download size={15} />Export</button>
        </div>
      </div>

      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-[13px]">
            <thead>
              <tr className="border-b border-border text-left text-[11px] uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">Order</th>
                <th className="px-5 py-3 font-semibold">Retailer</th>
                <th className="px-5 py-3 font-semibold">Items</th>
                <th className="px-5 py-3 text-right font-semibold">Amount</th>
                <th className="px-5 py-3 font-semibold">Payment</th>
                <th className="px-5 py-3 font-semibold">Status</th>
                <th className="px-5 py-3" />
              </tr>
            </thead>
            <tbody>
              {rows.map((o) => (
                <tr key={o.id} className="border-b border-border2 last:border-0 hover:bg-card2">
                  <td className="px-5 py-3">
                    <div className="font-semibold">{o.ref}</div>
                    <div className="text-[11px] text-faint">{o.date} · {o.time}</div>
                  </td>
                  <td className="px-5 py-3">{o.retailer}<div className="text-[11px] text-faint">{o.area}</div></td>
                  <td className="px-5 py-3">{o.items}</td>
                  <td className="tnum px-5 py-3 text-right font-medium">{inr(o.amount)}</td>
                  <td className="px-5 py-3"><Pill s={o.payment} /></td>
                  <td className="px-5 py-3"><Pill s={o.status} /></td>
                  <td className="px-5 py-3 text-right text-faint"><ChevronRight size={16} /></td>
                </tr>
              ))}
              {rows.length === 0 && <tr><td colSpan={7} className="px-5 py-10 text-center text-muted">No orders match your filters.</td></tr>}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
