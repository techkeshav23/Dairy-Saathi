import { Card, CardHead } from "@/components/ui";
import { SalesArea, CategoryDonut } from "@/components/charts";
import ReportDownloads from "@/components/ReportDownloads";
import { inr } from "@/lib/format";
import {
  getSalesTrend, getCategorySplit, getDashboardKpis,
  getOrders, getLedger, getRetailers, getProducts,
} from "@/lib/supabase-data";

export default async function ReportsPage() {
  const [salesTrend, catSplit, kpi, orders, ledger, retailers, products] = await Promise.all([
    getSalesTrend(),
    getCategorySplit(),
    getDashboardKpis(),
    getOrders(),
    getLedger(),
    getRetailers(),
    getProducts(),
  ]);

  const receipts = ledger.reduce((s, l) => s + l.credit, 0);
  const avgOrder = orders.length ? Math.round(kpi.revenue / orders.length) : 0;

  const summary: [string, string][] = [
    ["Total Sales (net)", inr(kpi.revenue)],
    ["Total Receipts", inr(receipts)],
    ["Net Outstanding", inr(kpi.outstanding)],
    ["Total Orders", String(kpi.orders)],
    ["Active Retailers", String(kpi.retailers)],
    ["Avg Order Value", inr(avgOrder)],
  ];

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHead title="Revenue vs Target" />
          <div className="px-3 pb-4"><SalesArea data={salesTrend} /></div>
        </Card>
        <Card>
          <CardHead title="Category Mix" />
          <div className="px-3 pb-2"><CategoryDonut data={catSplit} /></div>
          <ul className="space-y-2 px-5 pb-5">
            {catSplit.map((c) => (
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
          <CardHead title="Business Summary" />
          <div className="grid grid-cols-2 gap-px bg-border2 sm:grid-cols-3">
            {summary.map(([label, val]) => (
              <div key={label} className="bg-card px-5 py-4">
                <div className="text-[12px] font-medium text-muted">{label}</div>
                <div className="tnum mt-1 text-lg font-bold text-fg">{val}</div>
              </div>
            ))}
          </div>
        </Card>
        <Card>
          <CardHead title="Download Reports" />
          <ReportDownloads orders={orders} ledger={ledger} retailers={retailers} products={products} />
        </Card>
      </div>
    </div>
  );
}
