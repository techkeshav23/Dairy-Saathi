import { supabaseAdmin } from "@/lib/supabase-admin";
import { Card, CardHead, Pill } from "@/components/ui";
import { inr, inrFull } from "@/lib/format";
import Link from "next/link";
import { ArrowLeft, Phone, Mail, MapPin, Store } from "lucide-react";
import RetailerNotes from "./RetailerNotes";
import OrderStatusSelect from "@/components/OrderStatusSelect";

export default async function Retailer360Page(props: { params: Promise<{ id: string }> }) {
  const params = await props.params;
  const retailerId = params.id;

  // Fetch Retailer Profile
  if (!supabaseAdmin) {
    return <div className="p-10 text-center text-muted">Admin not configured. Please add SUPABASE_SERVICE_ROLE_KEY to .env.local</div>;
  }

  const { data: user } = await supabaseAdmin
    .from("app_users")
    .select("*")
    .eq("id", retailerId)
    .single();

  if (!user) {
    return <div className="p-10 text-center text-muted">Retailer not found.</div>;
  }

  // Fetch Orders
  const { data: orders } = await supabaseAdmin
    .from("orders")
    .select("*, order_items(qty)")
    .eq("user_id", retailerId)
    .order("created_at", { ascending: false })
    .limit(10);

  // Fetch Ledger
  const { data: ledger } = await supabaseAdmin
    .from("ledger_entries")
    .select("*")
    .eq("user_id", retailerId)
    .order("created_at", { ascending: false })
    .limit(15);

  // Fetch Notes
  const { data: notes } = await supabaseAdmin
    .from("retailer_notes")
    .select("*")
    .eq("retailer_id", retailerId)
    .order("created_at", { ascending: false });

  const formatDate = (ds: string) => {
    const d = new Date(ds);
    return d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
  };

  const code = user.id.split('-')[0].toUpperCase();
  const outstanding = Number(user.outstanding_balance) || 0;
  const creditLimit = Number(user.credit_limit) || 50000;

  return (
    <div className="space-y-5 pb-10">
      <div className="flex items-center gap-3">
        <Link href="/retailers" className="flex h-8 w-8 items-center justify-center rounded-lg border border-border bg-card text-muted hover:text-fg hover:bg-card2"><ArrowLeft size={16} /></Link>
        <h1 className="text-xl font-bold text-fg">Retailer Profile</h1>
      </div>

      {/* Top Overview Card */}
      <Card className="p-6">
        <div className="flex flex-col gap-6 md:flex-row md:items-start md:justify-between">
          <div className="space-y-3">
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-2xl font-bold text-fg">{user.business_name || user.shop_name}</h2>
                <span className={`rounded-md px-2 py-[3px] text-[11px] font-medium ${user.status === "blocked" ? "bg-danger-soft text-danger" : "bg-success-soft text-success"}`}>
                  {user.status === "blocked" ? "Blocked" : "Active"}
                </span>
              </div>
              <p className="text-sm font-medium text-muted">#{code} · Owner: {user.owner_name || user.name || "N/A"}</p>
            </div>
            
            <div className="flex flex-wrap gap-x-6 gap-y-2 text-sm text-faint">
              <div className="flex items-center gap-1.5"><Phone size={14} />{user.phone}</div>
              <div className="flex items-center gap-1.5"><Mail size={14} />{user.email || 'N/A'}</div>
              <div className="flex items-center gap-1.5"><MapPin size={14} />{user.area || 'N/A'}</div>
              <div className="flex items-center gap-1.5"><Store size={14} />GST: {user.gst || 'N/A'}</div>
            </div>
          </div>
          
          <div className="flex gap-4">
            <div className="rounded-xl border border-border bg-card2 px-5 py-3 text-right">
              <div className="text-[12px] font-medium text-muted">Credit Limit</div>
              <div className="mt-0.5 text-lg font-bold text-fg">{inrFull(creditLimit)}</div>
            </div>
            <div className="rounded-xl border border-border bg-card2 px-5 py-3 text-right">
              <div className="text-[12px] font-medium text-muted">Outstanding</div>
              <div className={`mt-0.5 text-lg font-bold ${outstanding > 0 ? "text-brand" : "text-success"}`}>{inrFull(outstanding)}</div>
            </div>
          </div>
        </div>
      </Card>

      <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
        {/* Left Column: Recent Orders & Ledger */}
        <div className="space-y-5 lg:col-span-2">
          
          {/* Recent Orders */}
          <Card className="overflow-hidden">
            <CardHead title="Recent Orders" />
            <div className="overflow-x-auto">
              <table className="w-full text-[13px]">
                <thead>
                  <tr className="border-y border-border text-left text-[11px] uppercase tracking-wide text-faint">
                    <th className="px-5 py-3 font-semibold">Date</th>
                    <th className="px-5 py-3 font-semibold">Items</th>
                    <th className="px-5 py-3 text-right font-semibold">Amount</th>
                    <th className="px-5 py-3 font-semibold">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {(orders || []).map((o) => {
                    const totalItems = o.order_items?.reduce((s: number, i: any) => s + i.qty, 0) || 0;
                    return (
                      <tr key={o.id} className="border-b border-border2 last:border-0 hover:bg-card2">
                        <td className="px-5 py-3 font-medium">{formatDate(o.created_at)}</td>
                        <td className="px-5 py-3">{totalItems}</td>
                        <td className="tnum px-5 py-3 text-right font-medium">{inr(o.total)}</td>
                        <td className="px-5 py-3"><OrderStatusSelect id={o.id} currentStatus={o.status} /></td>
                      </tr>
                    );
                  })}
                  {!orders?.length && <tr><td colSpan={4} className="px-5 py-8 text-center text-muted">No orders yet.</td></tr>}
                </tbody>
              </table>
            </div>
          </Card>

          {/* Ledger Statement */}
          <Card className="overflow-hidden">
            <CardHead title="Ledger & Payments" />
            <div className="overflow-x-auto">
              <table className="w-full text-[13px]">
                <thead>
                  <tr className="border-y border-border text-left text-[11px] uppercase tracking-wide text-faint">
                    <th className="px-5 py-3 font-semibold">Date</th>
                    <th className="px-5 py-3 font-semibold">Details</th>
                    <th className="px-5 py-3 text-right font-semibold">Debit</th>
                    <th className="px-5 py-3 text-right font-semibold">Credit</th>
                  </tr>
                </thead>
                <tbody>
                  {(ledger || []).map((l) => (
                    <tr key={l.id} className="border-b border-border2 last:border-0 hover:bg-card2">
                      <td className="px-5 py-3">{formatDate(l.created_at)}</td>
                      <td className="px-5 py-3 text-muted">{l.note}</td>
                      <td className="tnum px-5 py-3 text-right text-brand">{l.type === 'debit' ? inrFull(l.amount) : "—"}</td>
                      <td className="tnum px-5 py-3 text-right text-success">{l.type === 'credit' ? inrFull(l.amount) : "—"}</td>
                    </tr>
                  ))}
                  {!ledger?.length && <tr><td colSpan={4} className="px-5 py-8 text-center text-muted">No ledger entries.</td></tr>}
                </tbody>
              </table>
            </div>
          </Card>

        </div>

        {/* Right Column: CRM / Notes */}
        <div>
          <RetailerNotes retailerId={retailerId} initialNotes={notes || []} />
        </div>
      </div>
    </div>
  );
}
