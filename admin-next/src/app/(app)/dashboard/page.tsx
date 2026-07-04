import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { Card, CardHead, Pill } from "@/components/ui";
import { KpiCard } from "@/components/kpi";
import { SalesArea, CategoryDonut, TopProductsBars } from "@/components/charts";
import { kpis, orders, categorySplit } from "@/lib/data";
import { inr } from "@/lib/format";
import { getDashboardKpis } from "@/lib/supabase-data";
import { useSupabase } from "@/lib/supabase";

export default async function DashboardPage() {
  const live = await getDashboardKpis();

  const displayKpis = kpis.map((k) => {
    if (useSupabase) {
      const liveValue = live[k.key as keyof typeof live];
      if (liveValue !== undefined && liveValue > 0) {
        return { ...k, value: liveValue };
      }
    }
    return k;
  });

  return (
    <div className="space-y-5">
      {/* KPIs */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {displayKpis.map((k, i) => (
          <KpiCard 
            key={k.key} 
            label={k.label} 
            value={k.value} 
            prefix={k.prefix} 
            delta={k.delta} 
            down={k.down} 
            spark={k.spark} 
            delay={i * 70} 
          />
        ))}
      </div>

      {/* charts */}
      {/* TODO: wire up live data for charts */}
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHead title="Sales Performance" action={
            <div className="flex items-center gap-4 text-[12px] text-muted">
              <span className="flex items-center gap-1.5"><i className="inline-block h-0.5 w-4 rounded bg-brand" />Sales</span>
              <span className="flex items-center gap-1.5"><i className="inline-block h-0.5 w-4 rounded bg-faint" />Target</span>
            </div>} />
          <div className="px-3 pb-4"><SalesArea /></div>
        </Card>
        <Card>
          <CardHead title="Category Mix" />
          <div className="px-3"><CategoryDonut /></div>
          <ul className="space-y-2 px-5 pb-5 pt-1">
            {categorySplit.map((c) => (
              <li key={c.name} className="flex items-center text-[13px] text-muted">
                <span className="mr-2.5 h-2.5 w-2.5 rounded-full" style={{ background: c.color }} />
                {c.name}<b className="tnum ml-auto text-fg">{c.value}%</b>
              </li>
            ))}
          </ul>
        </Card>
      </div>

      {/* recent + top */}
      {/* TODO: wire up live data for recent orders and top products */}
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHead title="Recent Orders" action={
            <Link href="/orders" className="flex items-center gap-1 text-[13px] font-medium text-info">View all <ChevronRight size={15} /></Link>} />
          <div className="overflow-x-auto">
            <table className="w-full text-[13px]">
              <thead>
                <tr className="border-y border-border text-left text-[11px] uppercase tracking-wide text-faint">
                  <th className="px-5 py-3 font-semibold">Order</th>
                  <th className="px-5 py-3 font-semibold">Retailer</th>
                  <th className="px-5 py-3 text-right font-semibold">Amount</th>
                  <th className="px-5 py-3 font-semibold">Status</th>
                </tr>
              </thead>
              <tbody>
                {orders.slice(0, 6).map((o) => (
                  <tr key={o.id} className="border-b border-border2 last:border-0 hover:bg-card2">
                    <td className="px-5 py-3 font-semibold">{o.ref}</td>
                    <td className="px-5 py-3">{o.retailer}</td>
                    <td className="tnum px-5 py-3 text-right">{inr(o.amount)}</td>
                    <td className="px-5 py-3"><Pill s={o.status} /></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
        <Card>
          <CardHead title="Top Products" />
          <div className="px-2 pb-4"><TopProductsBars /></div>
        </Card>
      </div>
    </div>
  );
}