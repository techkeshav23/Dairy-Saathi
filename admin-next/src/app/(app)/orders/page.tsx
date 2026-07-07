import { Search, Download, ChevronRight } from "lucide-react";
import { Card, Pill } from "@/components/ui";
import OrderStatusSelect from "@/components/OrderStatusSelect";
import PaymentVerification from "@/components/PaymentVerification";
import { orders as mockOrders } from "@/lib/data";
import { getOrders } from "@/lib/supabase-data";
import { useSupabase } from "@/lib/supabase";
import { inr } from "@/lib/format";
import Link from "next/link";
import Form from "next/form";

const CHIPS = ["All", "Placed", "Confirmed", "Packed", "Dispatched", "Delivered", "Cancelled"];

export default async function OrdersPage(props: {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  const searchParams = await props.searchParams;
  const chip = typeof searchParams.chip === "string" ? searchParams.chip : "All";
  const q = typeof searchParams.q === "string" ? searchParams.q : "";

  const allOrders = useSupabase ? await getOrders() : mockOrders;

  const rows = allOrders.filter((o) =>
    (chip === "All" || o.status === chip) &&
    (q === "" || (o.ref + o.retailer + o.area).toLowerCase().includes(q.toLowerCase()))
  );

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center gap-3">
        <div className="flex flex-wrap gap-2">
          {CHIPS.map((c) => (
            <Link key={c} href={`/orders?chip=${encodeURIComponent(c)}&q=${encodeURIComponent(q)}`}
              className={`rounded-full border px-3.5 py-1.5 text-[12.5px] font-medium transition ${
                chip === c ? "border-brand bg-brand text-white shadow-[0_6px_14px_rgba(15,23,42,.12)]" : "border-border bg-card text-muted hover:text-fg"
              }`}>{c}</Link>
          ))}
        </div>
        <div className="ml-auto flex items-center gap-2">
          <Form action="/orders" className="flex items-center gap-2 rounded-lg border border-border bg-card px-3">
            <input type="hidden" name="chip" value={chip} />
            <Search size={15} className="text-faint" />
            <input name="q" defaultValue={q} placeholder="Search orders…" className="w-44 bg-transparent py-2 text-[13px] outline-none placeholder:text-faint" />
          </Form>
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
                  <td className="px-5 py-3">
                    <PaymentVerification 
                      id={o.id} 
                      paymentMode={o.payment} 
                      paymentScreenshot={o.payment_screenshot} 
                      initialPaymentStatus={o.payment_status} 
                    />
                  </td>
                  <td className="px-5 py-3"><OrderStatusSelect id={o.id} currentStatus={o.status} /></td>
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