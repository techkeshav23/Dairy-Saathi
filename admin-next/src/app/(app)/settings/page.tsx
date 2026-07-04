"use client";
import { useState } from "react";
import { Card, CardHead } from "@/components/ui";

const FIELDS: [string, string][] = [
  ["Business Name", "DAIRY DEMO Wholesale"],
  ["GSTIN", "09ABCDE1234F1Z5"],
  ["Contact", "+91-82188 26414"],
  ["Email", "orders@dairydemo.in"],
  ["Address", "Main Bazaar, Bijnor, Uttar Pradesh, 246725"],
];
const PREFS: [string, boolean][] = [
  ["New order alerts", true],
  ["Low-stock warnings", true],
  ["Daily sales digest email", false],
  ["Auto-approve recharges < ₹10,000", false],
  ["Allow Khata (credit) orders", true],
];

function Switch({ on }: { on: boolean }) {
  const [v, setV] = useState(on);
  return (
    <button onClick={() => setV(!v)} className={`relative h-6 w-11 rounded-full transition ${v ? "bg-success" : "bg-border"}`}>
      <span className={`absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-all ${v ? "left-[22px]" : "left-0.5"}`} />
    </button>
  );
}

export default function SettingsPage() {
  return (
    <div className="grid grid-cols-1 gap-5 lg:grid-cols-3">
      <Card className="lg:col-span-2">
        <CardHead title="Business Profile" />
        <div className="space-y-4 p-5 pt-1">
          {FIELDS.map(([label, val]) => (
            <label key={label} className="block">
              <span className="mb-1.5 block text-[12px] font-medium text-muted">{label}</span>
              <input defaultValue={val} className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
            </label>
          ))}
          <button className="rounded-lg bg-brand px-5 py-2.5 text-sm font-semibold text-white shadow-[0_8px_18px_rgba(15,23,42,.12)]">Save Changes</button>
        </div>
      </Card>
      <Card>
        <CardHead title="Preferences" />
        <div className="divide-y divide-border2 px-5 pb-3">
          {PREFS.map(([label, on]) => (
            <div key={label} className="flex items-center justify-between py-3.5">
              <span className="text-[13.5px] font-medium">{label}</span>
              <Switch on={on} />
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}
