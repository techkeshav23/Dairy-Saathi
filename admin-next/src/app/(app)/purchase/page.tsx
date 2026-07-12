"use client";
import { useCallback, useEffect, useRef, useState } from "react";
import { UploadCloud, Check, Loader2, CheckCircle2, Sparkles, Trash2, Plus, Info } from "lucide-react";
import { Card, CardHead } from "@/components/ui";
import { extractBill, matchProduct, type Parsed } from "@/lib/pdf-extract";

type CatalogProduct = { id: string; name: string; displayName: string; cat: string; mrp: number; rate: number; cratePrice: number; eaPerCrate: number };

// One extracted bill line, in the shape the review table works with.
type BillLine = { name: string; crates: number; pieces: number; rate: number; amount: number };

type Row = {
  selected: boolean;
  name: string;             // internal / bill name
  displayName: string;      // customer-facing name (blank => hidden in app)
  productId: string | null; // matched existing product
  isNew: boolean;
  crates: number;           // crate count from the bill (reference only)
  stock: number;            // pieces (EA) — becomes stock
  eaPerCrate: number;       // pieces in one crate (0 = no crate option)
  billCostPiece: number;    // amount / pieces — reference
  billCostCrate: number;    // amount / crates — reference (0 if no crate)
  mrp: number;              // printed MRP (admin)
  rate: number;             // selling price PER PIECE (admin)
  cratePrice: number;       // selling price PER CRATE (admin)
  category: string;         // category name or "Uncategorized"
};

const UNCAT = "Uncategorized";
const r2 = (n: number) => Math.round(n * 100) / 100;

export default function BillImportPage() {
  const [busy, setBusy] = useState(false);
  const [saving, setSaving] = useState(false);
  const [fileName, setFileName] = useState("");
  const [rows, setRows] = useState<Row[] | null>(null);
  const [supplier, setSupplier] = useState("");
  const [toast, setToast] = useState("");
  const [notice, setNotice] = useState("");
  const [products, setProducts] = useState<CatalogProduct[]>([]);
  const [cats, setCats] = useState<string[]>([]);
  const inputRef = useRef<HTMLInputElement>(null);

  const loadData = useCallback(async () => {
    try {
      const [pRes, cRes] = await Promise.all([
        fetch("/api/products", { cache: "no-store" }),
        fetch("/api/categories", { cache: "no-store" }),
      ]);
      const pData = await pRes.json();
      const cData = await cRes.json();
      setProducts(Array.isArray(pData) ? pData.map((p: any) => ({ id: p.id, name: p.name, displayName: p.displayName || "", cat: p.cat, mrp: p.mrp, rate: p.rate, cratePrice: Number(p.cratePrice) || 0, eaPerCrate: Number(p.eaPerCrate) || 0 })) : []);
      setCats(Array.isArray(cData) ? cData.map((c: any) => c.name).filter(Boolean) : []);
    } catch { setProducts([]); setCats([]); }
  }, []);
  useEffect(() => { loadData(); }, [loadData]);

  // Build a review row from one bill line. Stock is in PIECES (EA); a crate is a bundle
  // of `eaPerCrate` pieces. Per-piece / per-crate bill cost are shown as a reference only.
  const buildRow = (line: BillLine): Row => {
    const idx = matchProduct(line.name, products);
    const p = idx >= 0 ? products[idx] : null;
    const stock = line.pieces > 0 ? line.pieces : line.crates;               // sellable count
    const eaFromBill = line.crates > 0 && line.pieces > 0 ? Math.round(line.pieces / line.crates) : 0;
    return {
      selected: true, name: line.name,
      displayName: p ? p.displayName : "",
      productId: p ? p.id : null, isNew: !p,
      crates: line.crates,
      stock,
      eaPerCrate: p && p.eaPerCrate > 0 ? p.eaPerCrate : eaFromBill,
      billCostPiece: stock > 0 ? r2(line.amount / stock) : 0,
      billCostCrate: line.crates > 0 ? r2(line.amount / line.crates) : 0,
      mrp: p ? p.mrp : 0,
      rate: p ? p.rate : 0,
      cratePrice: p ? p.cratePrice : 0,
      category: p ? (p.cat || UNCAT) : UNCAT,
    };
  };

  const fileToBase64 = (file: File) => new Promise<string>((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(String(reader.result).split(",")[1] || "");
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });

  const handleFile = async (file?: File) => {
    if (!file) return;
    setBusy(true); setFileName(file.name); setRows(null); setNotice(""); setSupplier("");
    let lines: BillLine[] | null = null;

    // 1) Try AI (Gemini) — reads any format + photos, and splits crate vs pieces.
    try {
      const base64 = await fileToBase64(file);
      const res = await fetch("/api/bill-extract", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ fileBase64: base64, mimeType: file.type || "application/pdf" }),
      });
      const j = await res.json();
      if (j.aiUsed && Array.isArray(j.items) && j.items.length) {
        lines = j.items.map((it: any) => ({
          name: it.name,
          crates: Number(it.crates) || 0,
          pieces: Number(it.pieces) || 0,
          rate: Number(it.rate) || 0,
          amount: Number(it.amount) || 0,
        }));
        setNotice("✨ Read by AI (Gemini) — crate & piece quantities split below. Review before saving.");
      }
    } catch { /* fall back */ }

    // 2) Fallback: basic parser (text PDFs only) or manual. It only gives a single qty,
    //    so we treat it as pieces (no crate split).
    if (!lines) {
      const isPdf = (file.type || "").includes("pdf") || file.name.toLowerCase().endsWith(".pdf");
      if (isPdf) {
        const parsed: Parsed = await extractBill(file, products);
        setSupplier(parsed.meta.supplier || "");
        lines = parsed.demo ? [] : parsed.items.map((it) => ({ name: it.name, crates: 0, pieces: it.qty, rate: it.rate, amount: it.qty * it.rate }));
        setNotice(parsed.demo
          ? "Couldn't auto-read this bill — turn on AI in Settings, or add products manually below."
          : "Read with the basic parser (piece qty only). Enable AI in Settings to split crates automatically.");
      } else {
        lines = [];
        setNotice("Enable AI in Settings to read photos, or add products manually below.");
      }
    }

    setRows(lines.map((l) => buildRow(l)));
    setBusy(false);
  };

  const addRow = () => setRows((r) => [...(r ?? []), buildRow({ name: "", crates: 0, pieces: 1, rate: 0, amount: 0 })]);

  const patch = (i: number, upd: Partial<Row>) =>
    setRows((r) => r ? r.map((row, idx) => (idx === i ? { ...row, ...upd } : row)) : r);

  const onName = (i: number, name: string) => {
    // re-match on name change
    const idx = matchProduct(name, products);
    const p = idx >= 0 ? products[idx] : null;
    patch(i, { name, productId: p ? p.id : null, isNew: !p,
      mrp: p ? p.mrp : rows![i].mrp, rate: p ? p.rate : rows![i].rate,
      cratePrice: p ? p.cratePrice : rows![i].cratePrice,
      eaPerCrate: p && p.eaPerCrate > 0 ? p.eaPerCrate : rows![i].eaPerCrate,
      category: p ? (p.cat || UNCAT) : rows![i].category });
  };

  const addNewCategory = (i: number) => {
    const name = window.prompt("New category name:");
    if (!name || !name.trim()) return;
    const n = name.trim();
    setCats((c) => c.includes(n) ? c : [...c, n].sort());
    patch(i, { category: n });
  };

  const removeRow = (i: number) => setRows((r) => r ? r.filter((_, idx) => idx !== i) : r);

  const confirm = async () => {
    if (!rows || saving) return;
    const chosen = rows.filter((r) => r.selected && r.name.trim());
    if (chosen.length === 0) { setToast("Select at least one product"); setTimeout(() => setToast(""), 3000); return; }
    setSaving(true);
    try {
      const res = await fetch("/api/products/bill-import", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          items: chosen.map((r) => ({
            productId: r.productId, name: r.name, displayName: r.displayName, category: r.category,
            mrp: r.mrp, rate: r.rate, cratePrice: r.cratePrice, eaPerCrate: r.eaPerCrate, stock: r.stock,
          })),
        }),
      });
      const j = await res.json();
      if (!res.ok) { setToast("Failed: " + (j.error || "unknown")); setSaving(false); setTimeout(() => setToast(""), 4000); return; }
      setRows(null); setFileName(""); setSupplier("");
      await loadData();
      setToast(`Done · ${j.created} new product${j.created === 1 ? "" : "s"} added, ${j.restocked} restocked`);
    } catch {
      setToast("Network error");
    } finally {
      setSaving(false);
      setTimeout(() => setToast(""), 4000);
    }
  };

  const selectedCount = rows ? rows.filter((r) => r.selected).length : 0;

  return (
    <div className="space-y-5">
      {toast && (
        <div className="flex items-center gap-2 rounded-xl border border-success-soft bg-success-soft px-4 py-3 text-[13px] font-medium text-success">
          <CheckCircle2 size={16} />{toast}
        </div>
      )}

      {!rows ? (
        busy ? (
          <Card className="flex flex-col items-center gap-2 py-16 text-center">
            <Loader2 size={28} className="spin text-brand" />
            <h3 className="mt-2 text-lg font-semibold">Reading bill…</h3>
            <p className="text-[13px] text-faint">{fileName}</p>
          </Card>
        ) : (
          <Card className="p-5">
            <CardHead title="Import from Bill" />
            <p className="px-1 pb-4 text-[13px] text-muted">Upload a supplier bill (PDF or photo) — AI reads the products <b>and splits crate vs pieces</b>, you set the piece &amp; crate selling price + category, then add them to your catalog with stock. <span className="text-faint">Turn on AI in Settings → AI Bill Reader.</span></p>
            <input ref={inputRef} type="file" accept="application/pdf,image/*" hidden onChange={(e) => handleFile(e.target.files?.[0])} />
            <div
              onClick={() => inputRef.current?.click()}
              onDragOver={(e) => { e.preventDefault(); e.currentTarget.classList.add("!border-brand", "bg-brand-soft"); }}
              onDragLeave={(e) => e.currentTarget.classList.remove("!border-brand", "bg-brand-soft")}
              onDrop={(e) => { e.preventDefault(); handleFile(e.dataTransfer.files?.[0]); }}
              className="flex cursor-pointer flex-col items-center gap-2 rounded-2xl border-2 border-dashed border-border bg-gradient-to-b from-card to-card2 px-6 py-14 text-center transition hover:border-brand hover:bg-brand-soft"
            >
              <div className="grid h-16 w-16 place-items-center rounded-2xl bg-brand-soft text-brand"><UploadCloud size={30} /></div>
              <h3 className="mt-2 text-lg font-semibold">Upload Supplier Bill (PDF or Photo)</h3>
              <p className="text-sm text-muted">Drag &amp; drop here, or <b className="text-brand">click to browse</b></p>
            </div>
          </Card>
        )
      ) : (
        <>
          {notice && (
            <div className="flex items-center gap-2 rounded-lg border border-border bg-card2 px-3 py-2 text-[12.5px] text-muted">
              <Info size={14} className="shrink-0 text-brand" />{notice}
            </div>
          )}
          <div className="flex flex-col gap-2 sm:flex-row sm:items-center">
            <div>
              <h2 className="text-[15px] font-semibold text-fg">Review bill items</h2>
              <p className="mt-0.5 text-[12px] text-faint">{fileName}{supplier ? ` · ${supplier}` : ""} — stock is in <b>pieces (EA)</b>; set piece &amp; crate selling price.</p>
            </div>
            <div className="sm:ml-auto flex gap-2">
              <button onClick={addRow} className="flex items-center gap-1.5 rounded-lg border border-border px-3 py-2 text-[13px] font-semibold hover:bg-card2"><Plus size={15} />Add row</button>
              <button onClick={() => { setRows(null); setFileName(""); setNotice(""); }} className="rounded-lg border border-border px-4 py-2 text-[13px] font-semibold hover:bg-card2">Discard</button>
              <button onClick={confirm} disabled={saving} className="flex items-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white hover:opacity-95 disabled:opacity-60">
                {saving ? <Loader2 size={15} className="spin" /> : <Check size={15} />}{saving ? "Saving…" : `Add ${selectedCount} to Catalog`}
              </button>
            </div>
          </div>

          <Card className="overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-[13px]">
                <thead>
                  <tr className="border-b border-border text-left text-[11px] uppercase tracking-wide text-faint">
                    <th className="px-3 py-3"><input type="checkbox" checked={rows.every((r) => r.selected)} onChange={(e) => setRows(rows.map((r) => ({ ...r, selected: e.target.checked })))} /></th>
                    <th className="px-3 py-3 font-semibold">Bill Name <span className="text-faint normal-case">(internal)</span></th>
                    <th className="px-3 py-3 font-semibold">Display Name <span className="text-brand normal-case">(app)</span></th>
                    <th className="px-3 py-3 font-semibold">Status</th>
                    <th className="px-3 py-3 text-right font-semibold">Stock <span className="text-faint normal-case">(pcs)</span></th>
                    <th className="px-3 py-3 text-right font-semibold">Pcs / Crate</th>
                    <th className="px-3 py-3 text-right font-semibold">Bill Cost</th>
                    <th className="px-3 py-3 text-right font-semibold">MRP</th>
                    <th className="px-3 py-3 text-right font-semibold">Piece ₹</th>
                    <th className="px-3 py-3 text-right font-semibold">Crate ₹</th>
                    <th className="px-3 py-3 font-semibold">Category</th>
                    <th className="px-3 py-3" />
                  </tr>
                </thead>
                <tbody>
                  {rows.map((r, i) => (
                    <tr key={i} className={`border-b border-border2 last:border-0 ${r.selected ? "" : "opacity-45"}`}>
                      <td className="px-3 py-2 align-top"><input type="checkbox" className="mt-2" checked={r.selected} onChange={(e) => patch(i, { selected: e.target.checked })} /></td>
                      <td className="px-3 py-2 align-top">
                        <input value={r.name} onChange={(e) => onName(i, e.target.value)} className="w-full min-w-[150px] rounded-md border border-border bg-card px-2 py-1.5 outline-none focus:border-brand" />
                      </td>
                      <td className="px-3 py-2 align-top">
                        <input value={r.displayName} onChange={(e) => patch(i, { displayName: e.target.value })} placeholder="app name…"
                          className={`w-full min-w-[150px] rounded-md border bg-card px-2 py-1.5 outline-none focus:border-brand ${r.displayName ? "border-border" : "border-warning"}`} />
                      </td>
                      <td className="px-3 py-2 align-top">
                        <span className={`inline-block rounded px-1.5 py-[2px] text-[10.5px] font-semibold ${r.isNew ? "bg-success-soft text-success" : "bg-brand-soft text-brand"}`}>
                          {r.isNew ? "NEW" : "IN CATALOG"}
                        </span>
                      </td>
                      <td className="px-3 py-2 align-top text-right">
                        <input type="number" value={r.stock} onChange={(e) => patch(i, { stock: Number(e.target.value) || 0 })} className="tnum w-16 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand" />
                        {r.crates > 0 && <div className="mt-0.5 text-[10px] text-faint">bill: {r.crates} crate</div>}
                      </td>
                      <td className="px-3 py-2 align-top text-right">
                        <input type="number" value={r.eaPerCrate} onChange={(e) => patch(i, { eaPerCrate: Number(e.target.value) || 0 })} placeholder="0" className="tnum w-16 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand" />
                        {r.eaPerCrate === 0 && <div className="mt-0.5 text-[10px] text-faint">no crate</div>}
                      </td>
                      <td className="tnum px-3 py-2 align-top text-right text-faint">
                        <div>₹{r.billCostPiece}/pc</div>
                        {r.billCostCrate > 0 && <div className="text-[11px]">₹{r.billCostCrate}/crate</div>}
                      </td>
                      <td className="px-3 py-2 align-top"><input type="number" value={r.mrp} onChange={(e) => patch(i, { mrp: Number(e.target.value) || 0 })} className="tnum w-20 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand" /></td>
                      <td className="px-3 py-2 align-top"><input type="number" value={r.rate} onChange={(e) => patch(i, { rate: Number(e.target.value) || 0 })} className="tnum w-20 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand" /></td>
                      <td className="px-3 py-2 align-top">
                        <input type="number" value={r.cratePrice} disabled={r.eaPerCrate === 0} onChange={(e) => patch(i, { cratePrice: Number(e.target.value) || 0 })}
                          className="tnum w-20 rounded-md border border-border bg-card px-2 py-1.5 text-right outline-none focus:border-brand disabled:opacity-40" />
                      </td>
                      <td className="px-3 py-2 align-top">
                        <select value={r.category} onChange={(e) => { if (e.target.value === "__new__") addNewCategory(i); else patch(i, { category: e.target.value }); }}
                          className="max-w-[160px] rounded-md border border-border bg-card px-2 py-1.5 text-[12.5px] outline-none focus:border-brand">
                          <option value={UNCAT}>{UNCAT}</option>
                          {cats.map((c) => <option key={c} value={c}>{c}</option>)}
                          <option value="__new__">+ New category…</option>
                        </select>
                      </td>
                      <td className="px-3 py-2 align-top text-right"><button onClick={() => removeRow(i)} className="mt-1.5 text-faint hover:text-danger"><Trash2 size={15} /></button></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <div className="flex items-center justify-between border-t border-border bg-card2 px-5 py-3 text-[12.5px] text-muted">
              <span><b className="text-fg">{selectedCount}</b> selected of {rows.length} · <b className="text-success">{rows.filter((r) => r.selected && r.isNew).length}</b> new, <b className="text-brand">{rows.filter((r) => r.selected && !r.isNew).length}</b> restock</span>
              <span className="flex items-center gap-1 text-faint"><Sparkles size={13} />Tip: Pcs/Crate = 0 means the product is sold in pieces only</span>
            </div>
          </Card>
        </>
      )}
    </div>
  );
}
