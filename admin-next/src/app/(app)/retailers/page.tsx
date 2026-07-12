"use client";
import { useCallback, useEffect, useMemo, useState } from "react";
import { Search, Plus, X, Pencil, Trash2, Loader2, Ban, CheckCircle2 } from "lucide-react";
import { Card } from "@/components/ui";
import ConfirmDialog from "@/components/ConfirmDialog";
import { inr } from "@/lib/format";
import Link from "next/link";

type R = {
  id: string; code: string; name: string; owner: string; area: string; phone: string;
  email: string; gst: string; idType: string; idNumber: string; accountType: string;
  limit: number; outstanding: number; status: string; orders: number;
};
type RForm = R & { password: string; confirmPassword: string };
const BLANK: RForm = { id: "", code: "", name: "", owner: "", area: "", phone: "", email: "", gst: "", idType: "gst", idNumber: "", accountType: "retailer", limit: 50000, outstanding: 0, status: "active", orders: 0, password: "", confirmPassword: "" };

// Standard password policy: 8+ chars with an uppercase, a lowercase and a number.
const PW_RE = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
const pwError = (pw: string) => (PW_RE.test(pw) ? "" : "Password must be 8+ characters with an uppercase, a lowercase and a number");
function idError(type: string, num: string): string {
  const s = (num || "").trim().toUpperCase();
  if (!s) return `Enter the retailer's ${type.toUpperCase()}`;
  if (type === "gst" && !/^[0-9A-Z]{15}$/.test(s)) return "GSTIN must be 15 characters";
  if (type === "pan" && !/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(s)) return "Invalid PAN (e.g. ABCDE1234F)";
  if (type === "aadhaar" && !/^[0-9]{12}$/.test(s)) return "Aadhaar must be 12 digits";
  return "";
}
const ID_HINT: Record<string, string> = { gst: "15-character GSTIN", pan: "10-character PAN", aadhaar: "12-digit Aadhaar" };

export default function RetailersPage() {
  const [q, setQ] = useState("");
  const [typeFilter, setTypeFilter] = useState<"all" | "retailer" | "firm">("all");
  const [list, setList] = useState<R[]>([]);
  const [loading, setLoading] = useState(true);
  const [modal, setModal] = useState<RForm | null>(null);
  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState("");
  const [actionConfirm, setActionConfirm] = useState<{ type: 'delete' | 'block', r: R } | null>(null);
  const [acting, setActing] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/retailers", { cache: "no-store" });
      const data = await res.json();
      setList(Array.isArray(data) ? data : []);
    } catch { setList([]); }
    setLoading(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  const rows = useMemo(() => list.filter((r) =>
    (typeFilter === "all" || (r.accountType || "retailer") === typeFilter) &&
    (r.name + r.owner + r.area + r.phone + r.email + r.code).toLowerCase().includes(q.toLowerCase())
  ), [q, list, typeFilter]);

  const firmCount = useMemo(() => list.filter((r) => r.accountType === "firm").length, [list]);

  const isEdit = !!modal?.id;

  const save = async () => {
    if (!modal) return;
    if (!modal.name.trim()) { setErr("Business name is required"); return; }
    if (!isEdit && !modal.email.trim()) { setErr("Email is required to create a login"); return; }
    // Phone mandatory (10 digits).
    if (modal.phone.replace(/\D/g, "").length < 10) { setErr("A valid 10-digit phone number is required"); return; }
    // ID proof mandatory (GST / PAN / Aadhaar).
    const idErr = idError(modal.idType, modal.idNumber);
    if (idErr) { setErr(idErr); return; }
    // Password: required on create, optional on edit — but must meet policy when provided.
    if (!isEdit || modal.password) {
      const pe = pwError(modal.password);
      if (pe) { setErr(pe); return; }
      if (modal.password !== modal.confirmPassword) { setErr("Passwords do not match"); return; }
    }
    setSaving(true); setErr("");
    try {
      const res = await fetch("/api/retailers", {
        method: isEdit ? "PATCH" : "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          id: modal.id, email: modal.email, password: modal.password || undefined,
          name: modal.name, owner: modal.owner, area: modal.area, phone: modal.phone,
          accountType: modal.accountType,
          idType: modal.idType, idNumber: modal.idNumber.trim().toUpperCase(),
          gst: modal.idType === "gst" ? modal.idNumber.trim().toUpperCase() : "",
          limit: modal.limit, status: modal.status,
        }),
      });
      const j = await res.json();
      if (!res.ok) { setErr(j.error || "Save failed"); setSaving(false); return; }
      setSaving(false); setModal(null); await load();
    } catch { setErr("Network error"); setSaving(false); }
  };

  const confirmAction = async () => {
    if (!actionConfirm) return;
    setActing(true);
    const { type, r } = actionConfirm;
    
    try {
      if (type === 'block') {
        const next = r.status === "blocked" ? "active" : "blocked";
        await fetch("/api/retailers", { method: "PATCH", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id: r.id, status: next }) });
      } else {
        await fetch("/api/retailers", { method: "DELETE", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id: r.id }) });
      }
      await load();
    } catch {
      // ignore
    } finally {
      setActing(false);
      setActionConfirm(null);
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:flex-wrap">
        <div className="flex w-full sm:w-auto items-center gap-2 rounded-lg border border-border bg-card px-3">
          <Search size={15} className="text-faint shrink-0" />
          <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search…" className="w-full sm:w-44 bg-transparent py-2 text-[13px] outline-none placeholder:text-faint" />
        </div>
        <div className="flex items-center rounded-lg border border-border bg-card2 p-0.5 text-[12.5px] font-medium">
          {([["all", `All (${list.length})`], ["retailer", `Retailers (${list.length - firmCount})`], ["firm", `Firms (${firmCount})`]] as const).map(([v, label]) => (
            <button key={v} onClick={() => setTypeFilter(v)}
              className={`rounded-md px-3 py-1.5 transition ${typeFilter === v ? "bg-brand text-white shadow-sm" : "text-muted hover:text-fg"}`}>
              {label}
            </button>
          ))}
        </div>
        <button onClick={() => { setErr(""); setModal({ ...BLANK }); }} className="w-full sm:w-auto sm:ml-auto flex items-center justify-center gap-2 rounded-lg bg-brand px-4 py-2 text-[13px] font-semibold text-white shadow-[0_8px_18px_rgba(43,80,214,.20)] transition hover:opacity-95">
          <Plus size={16} />Add Retailer
        </button>
      </div>

      <Card className="overflow-hidden">
        {loading ? (
          <div className="flex h-40 items-center justify-center text-muted"><Loader2 size={22} className="spin" /></div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-[13px]">
              <thead>
                <tr className="border-b border-border text-left text-[11px] uppercase tracking-wide text-faint">
                  <th className="px-5 py-3 font-semibold">Code</th><th className="px-5 py-3 font-semibold">Shop / Owner</th>
                  <th className="px-5 py-3 font-semibold">Contact</th><th className="px-5 py-3 font-semibold">Area</th>
                  <th className="px-5 py-3 text-right font-semibold">Credit</th><th className="px-5 py-3 text-right font-semibold">Outstanding</th>
                  <th className="px-5 py-3 font-semibold">Status</th><th className="px-5 py-3" />
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.id} className="group border-b border-border2 last:border-0 hover:bg-card2">
                    <td className="px-5 py-3 font-semibold">#{r.code}</td>
                    <td className="px-5 py-3">
                      <div className="flex items-center gap-2">
                        <Link href={`/retailers/${r.id}`} className="font-medium hover:text-brand hover:underline">{r.name}</Link>
                        <span className={`rounded px-1.5 py-[1px] text-[10px] font-semibold ${r.accountType === "firm" ? "bg-brand-soft text-brand" : "bg-card2 text-muted"}`}>
                          {r.accountType === "firm" ? "Firm" : "Retailer"}
                        </span>
                      </div>
                      <div className="text-[11px] text-faint">{r.owner}</div>
                    </td>
                    <td className="px-5 py-3 text-muted">{r.phone || "—"}<div className="text-[11px] text-faint">{r.email}</div></td>
                    <td className="px-5 py-3 text-muted">{r.area || "—"}</td>
                    <td className="tnum px-5 py-3 text-right">{inr(r.limit)}</td>
                    <td className={`tnum px-5 py-3 text-right font-medium ${r.outstanding > 0 ? "text-brand" : "text-success"}`}>{inr(r.outstanding)}</td>
                    <td className="px-5 py-3">
                      <span className={`inline-flex items-center gap-1.5 rounded-md px-2 py-[3px] text-[11px] font-medium ${r.status === "blocked" ? "bg-danger-soft text-danger" : "bg-success-soft text-success"}`}>
                        <span className={`h-1.5 w-1.5 rounded-full ${r.status === "blocked" ? "bg-danger" : "bg-success"}`} />{r.status === "blocked" ? "Blocked" : "Active"}
                      </span>
                    </td>
                    <td className="px-5 py-3">
                      <div className="flex justify-end gap-3 text-muted">
                        <button onClick={() => { setErr(""); setModal({ ...r, idType: r.idType || "gst", idNumber: r.idNumber || "", accountType: r.accountType || "retailer", password: "", confirmPassword: "" }); }} title="Edit"><Pencil size={15} className="hover:text-brand" /></button>
                        <button onClick={() => setActionConfirm({ type: 'block', r })} title={r.status === "blocked" ? "Unblock" : "Block"}>
                          {r.status === "blocked" ? <CheckCircle2 size={15} className="hover:text-success" /> : <Ban size={15} className="hover:text-warning" />}
                        </button>
                        <button onClick={() => setActionConfirm({ type: 'delete', r })} title="Delete"><Trash2 size={15} className="hover:text-danger" /></button>
                      </div>
                    </td>
                  </tr>
                ))}
                {rows.length === 0 && <tr><td colSpan={8} className="px-5 py-12 text-center text-muted">No retailers yet. Click “Add Retailer” to onboard one.</td></tr>}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {modal && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/50 p-4" onClick={() => setModal(null)}>
          <div className="w-full max-w-lg rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <div>
                <h3 className="text-[15px] font-semibold text-fg">{isEdit ? "Edit Retailer" : "Add Retailer"}</h3>
                {!isEdit && <p className="mt-0.5 text-[11px] text-faint">Creates a login the retailer uses in the mobile app.</p>}
              </div>
              <button onClick={() => setModal(null)} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>
            <div className="grid grid-cols-2 gap-4 p-5">
              <div className="col-span-2">
                <span className="mb-1 block text-[12px] font-medium text-muted">Account Type *</span>
                <div className="flex gap-2">
                  {(["retailer", "firm"] as const).map((t) => (
                    <button key={t} type="button"
                      onClick={() => setModal({ ...modal, accountType: t })}
                      className={`flex-1 rounded-lg border py-2 text-[13px] font-medium capitalize transition ${modal.accountType === t ? "border-brand bg-brand text-white" : "border-border bg-card text-muted hover:text-fg"}`}>
                      {t === "firm" ? "Firm / Business" : "Retailer"}
                    </button>
                  ))}
                </div>
              </div>
              <label className="col-span-2 block">
                <span className="mb-1 block text-[12px] font-medium text-muted">{modal.accountType === "firm" ? "Firm / Business Name *" : "Shop Name *"}</span>
                <input value={modal.name} onChange={(e) => setModal({ ...modal, name: e.target.value })}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Owner Name</span>
                <input value={modal.owner} onChange={(e) => setModal({ ...modal, owner: e.target.value })}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Area</span>
                <input value={modal.area} onChange={(e) => setModal({ ...modal, area: e.target.value })}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Email * {isEdit && <span className="text-faint">(login, fixed)</span>}</span>
                <input type="email" value={modal.email} disabled={isEdit} onChange={(e) => setModal({ ...modal, email: e.target.value })} placeholder="retailer@shop.com"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft disabled:bg-card2 disabled:text-muted" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Phone *</span>
                <input value={modal.phone} onChange={(e) => setModal({ ...modal, phone: e.target.value })} placeholder="10-digit mobile"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">{isEdit ? "Reset Password" : "Password *"}</span>
                <input type="text" value={modal.password} onChange={(e) => setModal({ ...modal, password: e.target.value })} placeholder={isEdit ? "leave blank to keep" : "min 8 chars"}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Confirm Password {!isEdit && "*"}</span>
                <input type="text" value={modal.confirmPassword} onChange={(e) => setModal({ ...modal, confirmPassword: e.target.value })} placeholder="re-enter password"
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <label className="col-span-2 block -mt-1">
                <span className="block text-[11px] text-faint">Use 8+ characters with an uppercase, a lowercase and a number.</span>
              </label>
              <label className="block">
                <span className="mb-1 block text-[12px] font-medium text-muted">Credit Limit (₹)</span>
                <input type="number" value={modal.limit} onChange={(e) => setModal({ ...modal, limit: Number(e.target.value) || 0 })}
                  className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </label>
              <div className="col-span-2">
                <span className="mb-1 block text-[12px] font-medium text-muted">ID Proof *</span>
                <div className="flex gap-2">
                  {(["gst", "pan", "aadhaar"] as const).map((t) => (
                    <button key={t} type="button"
                      onClick={() => setModal({ ...modal, idType: t, idNumber: "" })}
                      className={`flex-1 rounded-lg border py-2 text-[13px] font-medium capitalize transition ${modal.idType === t ? "border-brand bg-brand text-white" : "border-border bg-card text-muted hover:text-fg"}`}>
                      {t === "gst" ? "GST" : t === "pan" ? "PAN" : "Aadhaar"}
                    </button>
                  ))}
                </div>
                <input value={modal.idNumber} onChange={(e) => setModal({ ...modal, idNumber: e.target.value })} placeholder={ID_HINT[modal.idType]}
                  className="mt-2 w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg uppercase outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
              </div>
              {err && <p className="col-span-2 text-[12px] font-medium text-danger">{err}</p>}
            </div>
            <div className="flex gap-3 px-5 pb-5">
              <button onClick={() => setModal(null)} className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-fg hover:bg-card2">Cancel</button>
              <button onClick={save} disabled={saving} className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white transition hover:opacity-95 disabled:opacity-60">
                {saving && <Loader2 size={15} className="spin" />}{saving ? "Saving…" : isEdit ? "Save Changes" : "Create Retailer"}
              </button>
            </div>
          </div>
        </div>
      )}

      <ConfirmDialog
        open={!!actionConfirm}
        title={actionConfirm?.type === 'block' ? (actionConfirm?.r?.status === "blocked" ? "Unblock Retailer" : "Block Retailer") : "Delete Retailer"}
        desc={
          actionConfirm?.type === 'block' 
            ? (actionConfirm?.r?.status === "blocked" ? `Are you sure you want to unblock "${actionConfirm?.r?.name}"?` : `Are you sure you want to block "${actionConfirm?.r?.name}"? They won't be able to place orders.`) 
            : `Are you sure you want to delete "${actionConfirm?.r?.name}" and their login? This cannot be undone.`
        }
        confirmText={actionConfirm?.type === 'block' ? (actionConfirm?.r?.status === "blocked" ? "Unblock" : "Block") : "Delete"}
        danger={actionConfirm?.type === 'delete' || (actionConfirm?.type === 'block' && actionConfirm?.r?.status !== "blocked")}
        loading={acting}
        onConfirm={confirmAction}
        onCancel={() => setActionConfirm(null)}
      />
    </div>
  );
}
