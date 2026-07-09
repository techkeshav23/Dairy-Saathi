import Link from "next/link";
import { ChevronRight } from "lucide-react";
import { Card, CardHead, Pill } from "@/components/ui";
import { KpiCard } from "@/components/kpi";
import { SalesArea, CategoryDonut, TopProductsBars } from "@/components/charts";
import { inr } from "@/lib/format";
import { getDashboardKpis, getSalesTrend, getCategorySplit, getTopProducts, getOrders } from "@/lib/supabase-data";

export default async function DashboardPage() {
  const [live, salesTrend, catSplit, topProds, recentOrders] = await Promise.all([
    getDashboardKpis(),
    getSalesTrend(),
    getCategorySplit(),
    getTopProducts(),
    getOrders(),
  ]);

  // All values are live from Supabase; trend (delta + sparkline) is computed from real
  // monthly data and is simply hidden when there isn't enough history to be meaningful.
  const displayKpis = [
    { key: "revenue", label: "Total Revenue", value: live.revenue, prefix: "₹", trend: live.trend.revenue },
    { key: "orders", label: "Total Orders", value: live.orders, prefix: "", trend: live.trend.orders },
    { key: "retailers", label: "Active Retailers", value: live.retailers, prefix: "", trend: live.trend.retailers },
    { key: "outstanding", label: "Outstanding (Khata)", value: live.outstanding, prefix: "₹", trend: null },
  ];

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
            delta={k.trend?.delta}
            down={k.trend?.down}
            spark={k.trend?.spark}
            delay={i * 70}
          />
        ))}
      </div>

      {/* charts */}
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHead title="Sales Performance" action={
            <div className="flex items-center gap-4 text-[12px] text-muted">
              <span className="flex items-center gap-1.5"><i className="inline-block h-0.5 w-4 rounded bg-brand" />Sales</span>
              <span className="flex items-center gap-1.5"><i className="inline-block h-0.5 w-4 rounded bg-faint" />Target</span>
            </div>} />
          <div className="px-3 pb-4"><SalesArea data={salesTrend} /></div>
        </Card>
        <Card>
          <CardHead title="Category Mix" />
          <div className="px-3"><CategoryDonut data={catSplit} /></div>
          <ul className="space-y-2 px-5 pb-5 pt-1">
            {catSplit.map((c) => (
              <li key={c.name} className="flex items-center text-[13px] text-muted">
                <span className="mr-2.5 h-2.5 w-2.5 rounded-full" style={{ background: c.color }} />
                {c.name}<b className="tnum ml-auto text-fg">{c.value}%</b>
              </li>
            ))}
          </ul>
        </Card>
      </div>

      {/* recent + top */}
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
                {recentOrders.slice(0, 6).map((o) => (
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
          <div className="px-2 pb-4"><TopProductsBars data={topProds} /></div>
        </Card>
      </div>
    </div>
  );
}