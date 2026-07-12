"use client";
import { useEffect, useState } from "react";
import { Card, CardHead } from "@/components/ui";
import { Loader2, Sparkles, CheckCircle2, XCircle } from "lucide-react";

const MODELS = [
  { id: "gemini-2.5-flash", label: "Gemini 2.5 Flash (recommended)" },
  { id: "gemini-2.5-flash-lite", label: "Gemini 2.5 Flash Lite" },
  { id: "gemini-3.5-flash", label: "Gemini 3.5 Flash" },
  { id: "gemini-3-flash", label: "Gemini 3 Flash" },
  { id: "gemini-3.1-flash-lite", label: "Gemini 3.1 Flash Lite (high quota)" },
];

export default function AiBillReaderCard() {
  const [loading, setLoading] = useState(true);
  const [model, setModel] = useState("gemini-2.5-flash");
  const [enabled, setEnabled] = useState(false);
  const [hasKey, setHasKey] = useState(false);
  const [apiKey, setApiKey] = useState("");
  const [saving, setSaving] = useState(false);
  const [testing, setTesting] = useState(false);
  const [msg, setMsg] = useState<{ ok: boolean; text: string } | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const r = await fetch("/api/ai-config", { cache: "no-store" });
        const j = await r.json();
        setModel(j.model || "gemini-2.5-flash");
        setEnabled(!!j.enabled);
        setHasKey(!!j.hasKey);
      } catch { /* ignore */ }
      setLoading(false);
    })();
  }, []);

  const save = async () => {
    setSaving(true); setMsg(null);
    try {
      const r = await fetch("/api/ai-config", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ model, enabled, gemini_api_key: apiKey || undefined }),
      });
      if (!r.ok) throw new Error();
      if (apiKey) setHasKey(true);
      setApiKey("");
      setMsg({ ok: true, text: "Saved" });
    } catch { setMsg({ ok: false, text: "Save failed" }); }
    setSaving(false);
    setTimeout(() => setMsg(null), 3000);
  };

  const test = async () => {
    setTesting(true); setMsg(null);
    try {
      const r = await fetch("/api/ai-config", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ test: true, gemini_api_key: apiKey || undefined, gemini_model: model }),
      });
      const j = await r.json();
      setMsg(j.ok ? { ok: true, text: `Connected ✓ (${j.reply || "OK"})` } : { ok: false, text: j.error || "Test failed" });
    } catch { setMsg({ ok: false, text: "Test failed" }); }
    setTesting(false);
    setTimeout(() => setMsg(null), 5000);
  };

  if (loading) return <Card className="lg:col-span-2 p-5"><Loader2 size={20} className="spin text-muted" /></Card>;

  return (
    <Card className="lg:col-span-2">
      <CardHead title="AI Bill Reader (Gemini)" />
      <div className="space-y-4 p-5 pt-1">
        <p className="text-[12.5px] text-muted">
          Reads any supplier bill (PDF or photo) and extracts products in <b className="text-fg">Bill Import</b>.
          Get a free key at <a href="https://aistudio.google.com/apikey" target="_blank" rel="noreferrer" className="text-info hover:underline">aistudio.google.com</a>.
          The key is stored securely (server-only) — retailers can never see it.
        </p>

        <div className="flex items-center justify-between rounded-lg border border-border bg-card2 px-3 py-2.5">
          <div>
            <div className="text-[12.5px] font-medium text-fg">Enable AI reading</div>
            <div className="text-[11px] text-faint">Off = manual/basic parsing only</div>
          </div>
          <button type="button" onClick={() => setEnabled((v) => !v)}
            className={`relative h-5 w-9 shrink-0 rounded-full transition ${enabled ? "bg-success" : "bg-border"}`}>
            <span className={`absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition-all ${enabled ? "left-[18px]" : "left-0.5"}`} />
          </button>
        </div>

        <label className="block">
          <span className="mb-1.5 block text-[12px] font-medium text-muted">Gemini API Key {hasKey && <span className="text-success">(saved)</span>}</span>
          <input type="password" value={apiKey} onChange={(e) => setApiKey(e.target.value)}
            placeholder={hasKey ? "•••••••• (leave blank to keep)" : "AIza…"}
            className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
        </label>

        <label className="block">
          <span className="mb-1.5 block text-[12px] font-medium text-muted">Model</span>
          <select value={model} onChange={(e) => setModel(e.target.value)}
            className="w-full rounded-lg border border-border bg-card px-3 py-2.5 text-sm outline-none focus:border-brand">
            {MODELS.map((m) => <option key={m.id} value={m.id}>{m.label}</option>)}
          </select>
          <span className="mt-1 block text-[11px] text-faint">Ek model busy/fail ho toh dusra chuno — no code change.</span>
        </label>

        <div className="flex items-center gap-3 pt-1">
          <button onClick={save} disabled={saving} className="flex items-center gap-2 rounded-lg bg-brand px-5 py-2.5 text-sm font-semibold text-white disabled:opacity-70">
            {saving && <Loader2 size={16} className="spin" />}Save
          </button>
          <button onClick={test} disabled={testing} className="flex items-center gap-2 rounded-lg border border-border px-4 py-2.5 text-sm font-semibold text-fg hover:bg-card2 disabled:opacity-70">
            {testing ? <Loader2 size={16} className="spin" /> : <Sparkles size={16} />}Test Connection
          </button>
          {msg && (
            <span className={`flex items-center gap-1.5 text-sm font-medium ${msg.ok ? "text-success" : "text-danger"}`}>
              {msg.ok ? <CheckCircle2 size={15} /> : <XCircle size={15} />}{msg.text}
            </span>
          )}
        </div>
      </div>
    </Card>
  );
}
