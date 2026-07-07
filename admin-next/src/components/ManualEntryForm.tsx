"use client";

import { useState } from "react";
import { Plus, X, Loader2 } from "lucide-react";

type Retailer = { id: string; name: string; owner: string };

export default function ManualEntryForm({ retailers }: { retailers: Retailer[] }) {
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState("");
  
  const [userId, setUserId] = useState("");
  const [amount, setAmount] = useState("");
  const [type, setType] = useState("credit"); // credit by default (receiving money)
  const [note, setNote] = useState("");

  const save = async () => {
    if (!userId) return setErr("Please select a retailer");
    if (!amount || Number(amount) <= 0) return setErr("Enter a valid amount");
    if (!note.trim()) return setErr("Enter a note/description");

    setSaving(true);
    setErr("");
    
    try {
      const res = await fetch("/api/ledger", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user_id: userId, amount: Number(amount), type, note }),
      });
      const j = await res.json();
      if (!res.ok) throw new Error(j.error || "Save failed");
      
      setOpen(false);
      window.location.reload();
    } catch (e: any) {
      setErr(e.message);
    } finally {
      setSaving(false);
    }
  };

  return (
    <>
      <button 
        onClick={() => { setOpen(true); setUserId(""); setAmount(""); setNote(""); setType("credit"); setErr(""); }}
        className="flex w-full sm:w-auto justify-center items-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(43,80,214,.20)] transition hover:opacity-95"
      >
        <Plus size={16} />Add Manual Entry
      </button>

      {open && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4" onClick={() => setOpen(false)}>
          <div className="w-full max-w-sm rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <h3 className="text-[15px] font-semibold text-fg">New Ledger Entry</h3>
              <button onClick={() => setOpen(false)} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>
            
            <div className="grid gap-4 p-5">
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Retailer *</span>
                <select value={userId} onChange={(e) => setUserId(e.target.value)}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand">
                  <option value="">Select a retailer...</option>
                  {retailers.map(r => (
                    <option key={r.id} value={r.id}>{r.name} {r.owner ? `(${r.owner})` : ""}</option>
                  ))}
                </select>
              </label>
              
              <div className="grid grid-cols-2 gap-4">
                <label className="block">
                  <span className="mb-1 block text-[12px] font-medium text-muted">Amount (₹) *</span>
                  <input type="number" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="0.00"
                    className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
                </label>
                <label className="block">
                  <span className="mb-1 block text-[12px] font-medium text-muted">Entry Type</span>
                  <select value={type} onChange={(e) => setType(e.target.value)}
                    className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand">
                    <option value="credit">Credit (Received ₹)</option>
                    <option value="debit">Debit (Given ₹/Stock)</option>
                  </select>
                </label>
              </div>

              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Note / Description *</span>
                <input type="text" value={note} onChange={(e) => setNote(e.target.value)} placeholder="e.g. Cash payment received"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              
              {err && <p className="text-[12px] font-medium text-danger">{err}</p>}
            </div>
            
            <div className="flex gap-3 px-5 pb-5">
              <button onClick={() => setOpen(false)} className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-fg hover:bg-card2">Cancel</button>
              <button onClick={save} disabled={saving} className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white transition hover:opacity-95 disabled:opacity-60">
                {saving && <Loader2 size={15} className="spin" />}{saving ? "Saving…" : "Add Entry"}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
