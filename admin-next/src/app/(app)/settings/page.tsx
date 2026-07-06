"use client";
import { useEffect, useState } from "react";
import { Card, CardHead } from "@/components/ui";
import { Loader2 } from "lucide-react";

export default function SettingsPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [msg, setMsg] = useState("");
  
  const [profile, setProfile] = useState({
    business_name: "",
    gstin: "",
    contact: "",
    email: "",
    address: "",
  });

  const [prefs, setPrefs] = useState({
    new_order_alerts: true,
    low_stock_warnings: true,
    daily_sales_digest: false,
    auto_approve_recharges: false,
    allow_khata: true,
  });

  useEffect(() => {
    const load = async () => {
      try {
        const res = await fetch("/api/settings");
        const data = await res.json();
        if (data.id) {
          setProfile({
            business_name: data.business_name || "",
            gstin: data.gstin || "",
            contact: data.contact || "",
            email: data.email || "",
            address: data.address || "",
          });
          if (data.preferences) {
            setPrefs({ ...prefs, ...data.preferences });
          }
        }
      } catch (e) {
        console.error(e);
      } finally {
        setLoading(false);
      }
    };
    load();
  }, []);

  const save = async () => {
    setSaving(true);
    setMsg("");
    try {
      const res = await fetch("/api/settings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ ...profile, preferences: prefs }),
      });
      if (!res.ok) throw new Error("Failed to save");
      setMsg("Settings saved successfully!");
      setTimeout(() => setMsg(""), 3000);
    } catch (e: any) {
      setMsg(e.message || "An error occurred");
    } finally {
      setSaving(false);
    }
  };

  const togglePref = (key: keyof typeof prefs) => {
    setPrefs({ ...prefs, [key]: !prefs[key] });
  };

  if (loading) {
    return <div className="flex h-40 items-center justify-center text-muted"><Loader2 size={24} className="spin" /></div>;
  }

  return (
    <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
      <Card className="lg:col-span-2">
        <CardHead title="Business Profile" />
        <div className="space-y-4 p-5 pt-1">
          <label className="block">
            <span className="mb-1.5 block text-[12px] font-medium text-muted">Business Name</span>
            <input value={profile.business_name} onChange={(e) => setProfile({ ...profile, business_name: e.target.value })} className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-[12px] font-medium text-muted">GSTIN</span>
            <input value={profile.gstin} onChange={(e) => setProfile({ ...profile, gstin: e.target.value })} className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-[12px] font-medium text-muted">Contact</span>
            <input value={profile.contact} onChange={(e) => setProfile({ ...profile, contact: e.target.value })} className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-[12px] font-medium text-muted">Email</span>
            <input value={profile.email} onChange={(e) => setProfile({ ...profile, email: e.target.value })} className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
          </label>
          <label className="block">
            <span className="mb-1.5 block text-[12px] font-medium text-muted">Address</span>
            <input value={profile.address} onChange={(e) => setProfile({ ...profile, address: e.target.value })} className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
          </label>
          
          <div className="flex items-center gap-4 pt-2">
            <button onClick={save} disabled={saving} className="flex items-center gap-2 rounded-lg bg-brand px-5 py-2.5 text-sm font-semibold text-white shadow-[0_8px_18px_rgba(15,23,42,.12)] disabled:opacity-70">
              {saving && <Loader2 size={16} className="spin" />}
              Save Changes
            </button>
            {msg && <span className={`text-sm font-medium ${msg.includes("Error") || msg.includes("Failed") ? "text-danger" : "text-success"}`}>{msg}</span>}
          </div>
        </div>
      </Card>
      
      <Card>
        <CardHead title="Preferences" />
        <div className="divide-y divide-border2 px-5 pb-3">
          {[
            { key: "new_order_alerts", label: "New order alerts" },
            { key: "low_stock_warnings", label: "Low-stock warnings" },
            { key: "daily_sales_digest", label: "Daily sales digest email" },
            { key: "auto_approve_recharges", label: "Auto-approve recharges < ₹10,000" },
            { key: "allow_khata", label: "Allow Khata (credit) orders" },
          ].map((item) => (
            <div key={item.key} className="flex items-center justify-between py-3.5">
              <span className="text-[13.5px] font-medium">{item.label}</span>
              <button onClick={() => togglePref(item.key as keyof typeof prefs)} className={`relative h-6 w-11 rounded-full transition ${prefs[item.key as keyof typeof prefs] ? "bg-success" : "bg-border"}`}>
                <span className={`absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-all ${prefs[item.key as keyof typeof prefs] ? "left-[22px]" : "left-0.5"}`} />
              </button>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}
