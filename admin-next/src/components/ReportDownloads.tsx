"use client";
import { BarChart3, Download } from "lucide-react";
import type { Order, LedgerRow, Retailer, Product } from "@/lib/data";

// Client-side CSV export. Turns the live datasets already fetched on the server into
// downloadable CSVs — no fake "Filed" reports, only data that actually exists.

function toCsv(rows: (string | number)[][]): string {
  return rows
    .map((r) => r.map((c) => `"${String(c ?? "").replace(/"/g, '""')}"`).join(","))
    .join("\r\n");
}

function download(name: string, csv: string) {
  const blob = new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = name;
  a.click();
  URL.revokeObjectURL(url);
}

export default function ReportDownloads({
  orders, ledger, retailers, products,
}: {
  orders: Order[]; ledger: LedgerRow[]; retailers: Retailer[]; products: Product[];
}) {
  const reports: { label: string; disabled: boolean; run: () => void }[] = [
    {
      label: "Sales Day-wise",
      disabled: orders.length === 0,
      run: () => download("sales.csv", toCsv([
        ["Order", "Retailer", "Area", "Date", "Items", "Amount", "Payment", "Status"],
        ...orders.map((o) => [o.ref, o.retailer, o.area, o.date, o.items, o.amount, o.payment, o.status]),
      ])),
    },
    {
      label: "Retailer Outstanding",
      disabled: retailers.length === 0,
      run: () => download("outstanding.csv", toCsv([
        ["Code", "Retailer", "Owner", "Area", "Phone", "Credit Limit", "Outstanding", "Orders"],
        ...retailers.map((r) => [r.code, r.name, r.owner, r.area, r.phone, r.limit, r.outstanding, r.orders]),
      ])),
    },
    {
      label: "Stock Summary",
      disabled: products.length === 0,
      run: () => download("stock.csv", toCsv([
        ["Product", "Category", "MRP", "Rate", "MOQ", "Stock", "Pack"],
        ...products.map((p) => [p.name, p.cat, p.mrp, p.rate, p.moq, p.stock, p.pack]),
      ])),
    },
    {
      label: "Ledger Statement",
      disabled: ledger.length === 0,
      run: () => download("ledger.csv", toCsv([
        ["Date", "Party", "Voucher", "Type", "Debit", "Credit"],
        ...ledger.map((l) => [l.date, l.party, l.vch, l.type, l.debit, l.credit]),
      ])),
    },
  ];

  return (
    <div className="grid grid-cols-1 gap-2.5 p-5 pt-1 sm:grid-cols-2">
      {reports.map((r) => (
        <button
          key={r.label}
          onClick={r.run}
          disabled={r.disabled}
          className="flex items-center gap-2.5 rounded-lg border border-border bg-card px-3 py-3 text-left text-[12.5px] font-medium transition hover:border-brand hover:bg-brand-soft disabled:cursor-not-allowed disabled:opacity-40 disabled:hover:border-border disabled:hover:bg-card"
        >
          <BarChart3 size={16} className="text-brand" />
          <span className="flex-1">{r.label}</span>
          <Download size={14} className="text-faint" />
        </button>
      ))}
    </div>
  );
}
