"use client";
import { useRef, useState } from "react";
import { UploadCloud, FileText, Trash2, Plus, Check, Sparkles, CheckCircle2 } from "lucide-react";
import { Card, CardHead } from "@/components/ui";
import { products, purchases } from "@/lib/data";
import { extractBill, matchProduct, type Parsed } from "@/lib/pdf-extract";
import { inr } from "@/lib/format";

export default function PurchasePage() {
  const [busy, setBusy] = useState(false);
  const [fileName, setFileName] = useState("");
  const [parsed, setParsed] = useState<Parsed | null>(null);
  const [, force] = useState(0);
  const [toast, setToast] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);

  const handleFile = async (file?: File) => {
    if (!file) return;
    setBusy(true); setFileName(file.name); setParsed(null);
    const res = await extractBill(file);
    setParsed(res); setBusy(false);
  };

  const edit = (i: number, key: keyof Parsed["items"][number], val: string) => {
    if (!parsed) return;
    const it = parsed.items[i];
    if (key === "name") { it.name = val; it.match = matchProduct(val); }
    else if (key === "unit") it.unit = val;
    else if (key === "match") it.match = Number(val);
    else if (key === "qty") it.qty = Number(val) || 0;
    else if (key === "rate") it.rate = Number(val) || 0;
    else if (key === "amount") it.amount = Number(val) || 0;
    if (key === "qty" || key === "rate") it.amount = +(it.qty * it.rate).toFixed(2);
    force((v) => v + 1);
  };
  const del = (i: number) => { parsed!.items.splice(i, 1); force((v) => v + 1); };
  const addRow = () => { parsed!.items.push({ name: "", qty: 1, unit: "EA", rate: 0, amount: 0, match: -1 }); force((v) => v + 1); };

  const commit = () => {
    if (!parsed) return;
    let updated = 0, added = 0, total = 0;
    parsed.items.forEach((it) => {
      const qty = +it.qty || 0; total += +it.amount || 0;
      if (it.match >= 0) { products[it.match].stock += qty; updated++; }
      else { products.unshift({ name: it.name, cat: "Uncategorised", mrp: Math.round(it.rate * 1.2), rate: it.rate, resale: Math.round(it.rate * 1.1), moq: 1, stock: qty, pack: "1 " + (it.unit || "EA") }); added++; }
    });
    purchases.unshift({ date: parsed.meta.date, supplier: parsed.meta.supplier, billNo: parsed.meta.billNo, items: parsed.items.length, amount: total, file: fileName });
    setParsed(null); setFileName("");
    setToast(`Stock updated · ${updated} restocked, ${added} new added`);
    setTimeout(() => setToast(""), 3200);
  };

  const totQty = parsed?.items.reduce((s, x) => s + (+x.qty || 0), 0) ?? 0;
  const totAmt = parsed?.items.reduce((s, x) => s + (+x.amount || 0), 0) ?? 0;
  const matched = parsed?.items.filter((x) => x.match >= 0).length ?? 0;

  return (
    <div className="space-y-5">
      {toast && (
        <div className="flex items-center gap-2 rounded-xl border border-success-soft bg-success-soft px-4 py-3 text-[13px] font-medium text-success">
          <CheckCircle2 size={16} />{toast}
        </div>
      )}

      {busy ? (
        <Card className="flex flex-col items-center gap-2 py-16 text-center">
          <div className="spin h-11 w-11 rounded-full border-4 border-brand-soft border-t-brand" />
          <h3 className="mt-2 text-lg font-semibold">Reading bill…</h3>
          <p className="text-sm font-medium">{fileName}</p>
          <p className="text-[13px] text-faint">Extracting line items from your PDF</p>
        </Card>
      ) : parsed ? (
        <>
          <div className={`flex items-start gap-2.5 rounded-xl border px-4 py-3 text-[13px] ${parsed.demo ? "border-warning-soft bg-warning-soft text-warning" : "border-success-soft bg-success-soft text-success"}`}>
            {parsed.demo ? <Sparkles size={16} className="mt-0.5 shrink-0" /> : <Check size={16} className="mt-0.5 shrink-0" />}
            <span>{parsed.demo
              ? <>Couldn&apos;t auto-read this PDF&apos;s layout, so a <b>sample extraction</b> is shown. Edit the rows, then add to inventory. (Text-based invoices parse automatically.)</>
              : <>Extracted <b>{parsed.items.length}</b> line items from <b>{fileName}</b>. Review &amp; edit, then add to inventory.</>}</span>
          </div>

          <Card>
            <CardHead title="Bill Details" />
            <div className="grid grid-cols-1 gap-4 px-5 pb-5 sm:grid-cols-3">
              {([["Supplier", "supplier"], ["Bill / Invoice No", "billNo"], ["Bill Date", "date"]] as const).map(([label, key]) => (
                <label key={key} className="block">
                  <span className="mb-1.5 block text-[12px] font-medium text-muted">{label}</span>
                  <input value={parsed.meta[key]} onChange={(e) => { parsed.meta[key] = e.target.value; force((v) => v + 1); }}
                    className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
                </label>
              ))}
            </div>
          </Card>

          <Card className="overflow-hidden">
            <CardHead title="Extracted Items" action={<button onClick={addRow} className="flex items-center gap-1.5 rounded-lg border border-border px-3 py-1.5 text-[12.5px] font-medium hover:bg-card2"><Plus size={14} />Add row</button>} />
            <div className="overflow-x-auto">
              <table className="w-full text-[13px]">
                <thead>
                  <tr className="border-y border-border text-left text-[11px] uppercase tracking-wide text-faint">
                    <th className="px-4 py-3 font-semibold">Product</th><th className="px-4 py-3 text-right font-semibold">Qty</th>
                    <th className="px-4 py-3 font-semibold">Unit</th><th className="px-4 py-3 text-right font-semibold">Rate</th>
                    <th className="px-4 py-3 text-right font-semibold">Amount</th><th className="px-4 py-3 font-semibold">Match in catalog</th><th className="px-4 py-3" />
                  </tr>
                </thead>
                <tbody>
                  {parsed.items.map((it, i) => (
                    <tr key={i} className="border-b border-border2 last:border-0">
                      <td className="px-4 py-2"><input value={it.name} onChange={(e) => edit(i, "name", e.target.value)} className="w-full min-w-[180px] rounded-md border border-border bg-card px-2.5 py-1.5 outline-none focus:border-brand" /></td>
                      <td className="px-4 py-2"><input value={it.qty} onChange={(e) => edit(i, "qty", e.target.value)} className="tnum w-16 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand" /></td>
                      <td className="px-4 py-2"><input value={it.unit} onChange={(e) => edit(i, "unit", e.target.value)} className="w-16 rounded-md border border-border bg-card px-2 py-1.5 outline-none focus:border-brand" /></td>
                      <td className="px-4 py-2"><input value={it.rate} onChange={(e) => edit(i, "rate", e.target.value)} className="tnum w-20 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand" /></td>
                      <td className="px-4 py-2"><input value={it.amount} onChange={(e) => edit(i, "amount", e.target.value)} className="tnum w-24 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand" /></td>
                      <td className="px-4 py-2">
                        <select value={it.match} onChange={(e) => edit(i, "match", e.target.value)}
                          className={`max-w-[190px] rounded-md border px-2 py-1.5 text-[12.5px] font-medium outline-none ${it.match < 0 ? "border-warning-soft bg-warning-soft text-warning" : "border-success-soft bg-success-soft text-success"}`}>
                          <option value={-1}>+ New product</option>
                          {products.map((p, idx) => <option key={idx} value={idx}>{p.name}</option>)}
                        </select>
                      </td>
                      <td className="px-4 py-2 text-right"><button onClick={() => del(i)} className="text-faint hover:text-brand"><Trash2 size={16} /></button></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="flex flex-wrap items-center justify-between gap-3 border-t border-border bg-card2 px-5 py-3 text-[13px] text-muted">
              <div><b className="text-fg">{parsed.items.length}</b> items · <b className="text-fg">{totQty}</b> qty · <b className="text-fg">{matched}</b> matched / <b className="text-fg">{parsed.items.length - matched}</b> new</div>
              <div className="text-[15px] font-semibold">Total: <b className="text-brand">{inr(totAmt)}</b></div>
            </div>
            <div className="flex gap-3 px-5 py-4">
              <button onClick={() => { setParsed(null); setFileName(""); }} className="rounded-lg border border-border px-4 py-2.5 text-sm font-semibold">Discard</button>
              <button onClick={commit} className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white shadow-[0_8px_18px_rgba(15,23,42,.12)]"><Check size={16} />Add {parsed.items.length} items to Inventory</button>
            </div>
          </Card>
        </>
      ) : (
        <Card className="p-5">
          <input ref={inputRef} type="file" accept="application/pdf" hidden onChange={(e) => handleFile(e.target.files?.[0])} />
          <div
            onClick={() => inputRef.current?.click()}
            onDragOver={(e) => { e.preventDefault(); e.currentTarget.classList.add("!border-brand", "bg-brand-soft"); }}
            onDragLeave={(e) => e.currentTarget.classList.remove("!border-brand", "bg-brand-soft")}
            onDrop={(e) => { e.preventDefault(); handleFile(e.dataTransfer.files?.[0]); }}
            className="flex cursor-pointer flex-col items-center gap-2 rounded-2xl border-2 border-dashed border-border bg-gradient-to-b from-card to-card2 px-6 py-14 text-center transition hover:border-brand hover:bg-brand-soft"
          >
            <div className="grid h-16 w-16 place-items-center rounded-2xl bg-brand-soft text-brand"><UploadCloud size={30} /></div>
            <h3 className="mt-2 text-lg font-semibold">Upload Purchase Bill (PDF)</h3>
            <p className="text-sm text-muted">Drag &amp; drop your supplier invoice here, or <b className="text-brand">click to browse</b></p>
            <p className="text-[12.5px] text-faint">We read the line items automatically so you don&apos;t add stock one by one.</p>
          </div>
          <div className="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-3">
            {[["1", "Upload supplier PDF bill"], ["2", "Review auto-extracted items"], ["3", "One click → stock updated"]].map(([n, t]) => (
              <div key={n} className="flex items-center gap-3 rounded-xl bg-card2 px-4 py-3 text-[13px] font-medium text-muted">
                <span className="grid h-6 w-6 place-items-center rounded-full bg-brand text-[12px] font-bold text-white">{n}</span>{t}
              </div>
            ))}
          </div>
        </Card>
      )}

      <Card className="overflow-hidden">
        <CardHead title="Recent Purchases (GRN)" />
        <div className="overflow-x-auto">
          <table className="w-full text-[13px]">
            <thead>
              <tr className="border-y border-border text-left text-[11px] uppercase tracking-wide text-faint">
                <th className="px-5 py-3 font-semibold">Date</th><th className="px-5 py-3 font-semibold">Supplier</th>
                <th className="px-5 py-3 font-semibold">Bill No</th><th className="px-5 py-3 text-right font-semibold">Items</th>
                <th className="px-5 py-3 text-right font-semibold">Amount</th><th className="px-5 py-3 font-semibold">Source</th>
              </tr>
            </thead>
            <tbody>
              {purchases.map((p, i) => (
                <tr key={i} className="border-b border-border2 last:border-0 hover:bg-card2">
                  <td className="px-5 py-3">{p.date}</td><td className="px-5 py-3">{p.supplier}</td>
                  <td className="px-5 py-3 font-medium text-info">{p.billNo}</td>
                  <td className="tnum px-5 py-3 text-right">{p.items}</td>
                  <td className="tnum px-5 py-3 text-right font-medium">{inr(p.amount)}</td>
                  <td className="px-5 py-3"><span className="inline-flex items-center gap-1.5 text-muted"><FileText size={14} className="text-faint" />{p.file}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  );
}
