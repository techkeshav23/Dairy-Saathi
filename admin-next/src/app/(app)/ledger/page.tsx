import { Download } from "lucide-react";
import { Card, CardHead, Pill } from "@/components/ui";
import { ledger as mockLedger, recharges } from "@/lib/data";
import { getLedger } from "@/lib/supabase-data";
import { useSupabase } from "@/lib/supabase";
import { supabaseAdmin } from "@/lib/supabase-admin";
import { inr, inrFull } from "@/lib/format";
import ManualEntryForm from "@/components/ManualEntryForm";

export default async function LedgerPage() {
  const ledger = useSupabase ? await getLedger() : mockLedger;
  
  let retailers: any[] = [];
  if (useSupabase && supabaseAdmin) {
    const { data } = await supabaseAdmin.from("app_users").select("id, name:business_name, owner:owner_name").eq("role", "retailer");
    if (data) retailers = data;
  }

  const debit = ledger.reduce((s, l) => s + l.debit, 0);
  const credit = ledger.reduce((s, l) => s + l.credit, 0);
  const mini = (label: string, val: number, cls: string) => (
    <Card className="p-4">
      <div className="text-[12.5px] font-medium text-muted">{label}</div>
      <div className={`tnum mt-1 text-2xl font-bold ${cls}`}>{inr(val)}</div>
    </Card>
  );

  return (
    <div className="space-y-5">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
        {mini("Total Debit (Sales)", debit, "text-brand")}
        {mini("Total Credit (Receipts)", credit, "text-success")}
        {mini("Net Outstanding", debit - credit, "text-brand")}
      </div>

      <Card className="overflow-hidden">
        <CardHead title="Ledger Statement" action={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center w-full sm:w-auto mt-3 sm:mt-0">
            <button className="flex w-full sm:w-auto items-center justify-center gap-1 text-[13px] font-medium text-info hover:underline">Export PDF <Download size={14} /></button>
            <div className="w-full sm:w-auto">
              <ManualEntryForm retailers={retailers} />
            </div>
          </div>
        } />
        <div className="overflow-x-auto">
          <table className="w-full text-[13px]">
            <thead>
              <tr className="border-y border-border text-left text-[11px] uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">Date</th><th className="px-5 py-3 font-semibold">Party</th>
                <th className="px-5 py-3 font-semibold">Voucher</th><th className="px-5 py-3 font-semibold">Type</th>
                <th className="px-5 py-3 text-right font-semibold">Debit</th><th className="px-5 py-3 text-right font-semibold">Credit</th>
              </tr>
            </thead>
            <tbody>
              {ledger.map((l, i) => (
                <tr key={i} className="border-b border-border2 last:border-0 hover:bg-card2">
                  <td className="px-5 py-3">{l.date}</td>
                  <td className="px-5 py-3">{l.party}</td>
                  <td className="px-5 py-3 font-medium text-info">{l.vch}</td>
                  <td className="px-5 py-3"><Pill s={l.type === "Sale" ? "Placed" : "Approved"} /><span className="ml-2 text-[11px] text-faint">{l.type}</span></td>
                  <td className="tnum px-5 py-3 text-right text-brand">{l.debit ? inrFull(l.debit) : "—"}</td>
                  <td className="tnum px-5 py-3 text-right text-success">{l.credit ? inrFull(l.credit) : "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>

    </div>
  );
}
