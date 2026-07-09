"use client";
import { useRef, useState } from "react";
import { Upload, Download, Loader2, CheckCircle2, AlertTriangle, X } from "lucide-react";

// Bulk product import from a CSV. Parses client-side, posts to /api/products/bulk which
// auto-creates missing categories. Columns (header row, case-insensitive):
//   name, category, brand, pack, mrp, rate, moq, stock, image
// Only `name` is required. `rate` is the wholesale price (falls back to mrp).

type Result = { created: number; skipped: number; categoriesCreated: number; errors: string[] };

const HEADERS = ["name", "category", "brand", "pack", "mrp", "rate", "moq", "stock", "image"];

const TEMPLATE =
  "name,category,brand,pack,mrp,rate,moq,stock,image\r\n" +
  "India Gate Basmati Rice 5kg,Groceries & Staples,India Gate,1 BAG,2200,1720,2,140,\r\n" +
  "Aashirvaad Atta 10kg,Groceries & Staples,Aashirvaad,1 BAG,520,410,4,210,\r\n" +
  "Tata Tea Premium 1kg,Beverages,Tata,1 CTN = 10 EA,540,440,4,70,\r\n";

// Minimal CSV parser: handles quoted fields, embedded commas, and escaped quotes ("").
function parseCsv(text: string): Record<string, string>[] {
  const rows: string[][] = [];
  let field = "", row: string[] = [], inQuotes = false;
  const s = text.replace(/\r\n/g, "\n").replace(/\r/g, "\n");
  for (let i = 0; i < s.length; i++) {
    const c = s[i];
    if (inQuotes) {
      if (c === '"') {
        if (s[i + 1] === '"') { field += '"'; i++; }
        else inQuotes = false;
      } else field += c;
    } else if (c === '"') inQuotes = true;
    else if (c === ",") { row.push(field); field = ""; }
    else if (c === "\n") { row.push(field); rows.push(row); field = ""; row = []; }
    else field += c;
  }
  if (field.length > 0 || row.length > 0) { row.push(field); rows.push(row); }

  const nonEmpty = rows.filter((r) => r.some((c) => c.trim() !== ""));
  if (nonEmpty.length < 2) return [];
  const header = nonEmpty[0].map((h) => h.trim().toLowerCase());
  return nonEmpty.slice(1).map((r) => {
    const obj: Record<string, string> = {};
    header.forEach((h, i) => { if (HEADERS.includes(h)) obj[h] = (r[i] ?? "").trim(); });
    return obj;
  });
}

function downloadTemplate() {
  const blob = new Blob(["﻿" + TEMPLATE], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url; a.download = "products-template.csv"; a.click();
  URL.revokeObjectURL(url);
}

export default function ProductImport({ onDone }: { onDone: () => void }) {
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [result, setResult] = useState<Result | null>(null);
  const [err, setErr] = useState("");
  const [fileName, setFileName] = useState("");
  const inputRef = useRef<HTMLInputElement>(null);

  const handleFile = async (file?: File) => {
    if (!file) return;
    setErr(""); setResult(null); setFileName(file.name);
    const text = await file.text();
    const rows = parseCsv(text);
    if (rows.length === 0) { setErr("No data rows found. Check the header row and format."); return; }
    setBusy(true);
    try {
      const res = await fetch("/api/products/bulk", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ rows }),
      });
      const j = await res.json();
      if (!res.ok) { setErr(j.error || "Import failed"); setBusy(false); return; }
      setResult(j as Result);
      onDone();
    } catch {
      setErr("Network error during import");
    } finally {
      setBusy(false);
      if (inputRef.current) inputRef.current.value = "";
    }
  };

  const close = () => { setOpen(false); setResult(null); setErr(""); setFileName(""); };

  return (
    <>
      <button onClick={() => setOpen(true)}
        className="w-full sm:w-auto flex items-center justify-center gap-2 rounded-lg border border-border bg-card px-4 py-2 text-[13px] font-semibold text-fg transition hover:bg-card2">
        <Upload size={16} />Import CSV
      </button>

      {open && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4" onClick={close}>
          <div className="w-full max-w-lg rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <h3 className="text-[15px] font-semibold text-fg">Import Products from CSV</h3>
              <button onClick={close} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>

            <div className="space-y-4 p-5">
              {!result ? (
                <>
                  <p className="text-[13px] text-muted">
                    Columns: <b className="text-fg">name, category, brand, pack, mrp, rate, moq, stock, image</b>.
                    Only <b className="text-fg">name</b> is required. Missing categories are created automatically.
                    <b className="text-fg"> rate</b> = your wholesale price.
                  </p>

                  <button onClick={downloadTemplate}
                    className="flex items-center gap-2 text-[13px] font-medium text-info hover:underline">
                    <Download size={15} />Download CSV template
                  </button>

                  <input ref={inputRef} type="file" accept=".csv,text/csv" hidden onChange={(e) => handleFile(e.target.files?.[0])} />
                  <div
                    onClick={() => !busy && inputRef.current?.click()}
                    onDragOver={(e) => { e.preventDefault(); }}
                    onDrop={(e) => { e.preventDefault(); if (!busy) handleFile(e.dataTransfer.files?.[0]); }}
                    className={`flex cursor-pointer flex-col items-center gap-2 rounded-xl border-2 border-dashed border-border bg-card2 px-6 py-10 text-center transition hover:border-brand ${busy ? "pointer-events-none opacity-60" : ""}`}
                  >
                    {busy ? <Loader2 size={26} className="spin text-brand" /> : <Upload size={26} className="text-brand" />}
                    <div className="text-[14px] font-semibold text-fg">{busy ? "Importing…" : "Click or drop your CSV here"}</div>
                    {fileName && <div className="text-[12px] text-faint">{fileName}</div>}
                  </div>

                  {err && <p className="flex items-center gap-1.5 text-[12.5px] font-medium text-danger"><AlertTriangle size={14} />{err}</p>}
                </>
              ) : (
                <div className="space-y-3">
                  <div className="flex items-center gap-2 text-success"><CheckCircle2 size={18} /><span className="text-[15px] font-semibold">Import complete</span></div>
                  <div className="grid grid-cols-3 gap-px overflow-hidden rounded-lg border border-border bg-border">
                    {([["Added", result.created], ["New categories", result.categoriesCreated], ["Skipped", result.skipped]] as const).map(([l, v]) => (
                      <div key={l} className="bg-card px-3 py-3 text-center">
                        <div className="tnum text-xl font-bold text-fg">{v}</div>
                        <div className="text-[11px] text-muted">{l}</div>
                      </div>
                    ))}
                  </div>
                  {result.errors.length > 0 && (
                    <div className="max-h-40 overflow-y-auto rounded-lg border border-warning-soft bg-warning-soft p-3 text-[12px] text-warning">
                      {result.errors.map((e, i) => <div key={i}>• {e}</div>)}
                    </div>
                  )}
                  <button onClick={close} className="w-full rounded-lg bg-brand py-2.5 text-sm font-semibold text-white hover:opacity-95">Done</button>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
