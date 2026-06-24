import { BarChart3, Download } from "lucide-react";
import { Card, CardHead, Pill } from "@/components/ui";
import { SalesArea, CategoryDonut } from "@/components/charts";
import { categorySplit } from "@/lib/data";

const GST = [
  ["GSTR-1 (Outward)", "₹48,42,375", "₹2,42,118", "Filed"],
  ["GSTR-2 (Inward)", "₹34,04,375", "₹1,70,218", "Filed"],
  ["GSTR-3B (Summary)", "₹14,38,000", "₹71,900", "Pending"],
];
const SHORTCUTS = ["Sales Day-wise", "Purchase Register", "Retailer Outstanding", "Stock Summary", "Profit & Loss", "Tax Summary"];

export default function ReportsPage() {
  return (
    <div className="space-y-5">
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHead title="Revenue vs Target" />
          <div className="px-3 pb-4"><SalesArea /></div>
        </Card>
        <Card>
          <CardHead title="Category Mix" />
          <div className="px-3 pb-2"><CategoryDonut /></div>
          <ul className="space-y-2 px-5 pb-5">
            {categorySplit.map((c) => (
              <li key={c.name} className="flex items-center text-[13px] text-muted">
                <span className="mr-2.5 h-2.5 w-2.5 rounded-full" style={{ background: c.color }} />{c.name}
                <b className="tnum ml-auto text-fg">{c.value}%</b>
              </li>
            ))}
          </ul>
        </Card>
      </div>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <Card className="overflow-hidden lg:col-span-2">
          <CardHead title="GST Summary" />
          <div className="overflow-x-auto">
            <table className="w-full text-[13px]">
              <thead>
                <tr className="border-y border-border text-left text-[11px] uppercase tracking-wide text-faint">
                  <th className="px-5 py-3 font-semibold">Return</th><th className="px-5 py-3 text-right font-semibold">Taxable</th>
                  <th className="px-5 py-3 text-right font-semibold">Tax</th><th className="px-5 py-3 font-semibold">Status</th>
                </tr>
              </thead>
              <tbody>
                {GST.map((r) => (
                  <tr key={r[0]} className="border-b border-border2 last:border-0 hover:bg-card2">
                    <td className="px-5 py-3 font-semibold">{r[0]}</td>
                    <td className="tnum px-5 py-3 text-right">{r[1]}</td>
                    <td className="tnum px-5 py-3 text-right">{r[2]}</td>
                    <td className="px-5 py-3"><Pill s={r[3]} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
        <Card>
          <CardHead title="Download Reports" />
          <div className="grid grid-cols-1 gap-2.5 p-5 pt-1 sm:grid-cols-2">
            {SHORTCUTS.map((s) => (
              <button key={s} className="flex items-center gap-2.5 rounded-lg border border-border bg-card px-3 py-3 text-left text-[12.5px] font-medium transition hover:border-brand hover:bg-brand-soft">
                <BarChart3 size={16} className="text-brand" /><span className="flex-1">{s}</span><Download size={14} className="text-faint" />
              </button>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
}
