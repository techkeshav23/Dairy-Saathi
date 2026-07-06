"use client";
import { useState } from "react";
import { Card, CardHead } from "@/components/ui";
import { Loader2, MessageSquare, Phone, StickyNote } from "lucide-react";

export default function RetailerNotes({ retailerId, initialNotes }: { retailerId: string, initialNotes: any[] }) {
  const [notes, setNotes] = useState(initialNotes);
  const [note, setNote] = useState("");
  const [type, setType] = useState("note");
  const [saving, setSaving] = useState(false);

  const save = async () => {
    if (!note.trim()) return;
    setSaving(true);
    try {
      const res = await fetch(`/api/retailers/${retailerId}/notes`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ note, type }),
      });
      if (res.ok) {
        setNotes([{ id: Date.now(), note, type, created_at: new Date().toISOString() }, ...notes]);
        setNote("");
      }
    } catch (e) {
      console.error(e);
    } finally {
      setSaving(false);
    }
  };

  const IconMap: any = {
    note: <StickyNote size={14} className="text-muted" />,
    call: <Phone size={14} className="text-brand" />,
    whatsapp: <MessageSquare size={14} className="text-success" />,
  };

  return (
    <Card className="flex h-full flex-col">
      <CardHead title="Interaction Log" />
      
      <div className="border-b border-border p-4 bg-card2">
        <textarea
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder="Log a call, message, or general note..."
          className="w-full resize-none rounded-lg border border-border bg-card p-3 text-[13px] text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft"
          rows={3}
        />
        <div className="mt-3 flex items-center justify-between">
          <div className="flex gap-2">
            {["note", "call", "whatsapp"].map((t) => (
              <button
                key={t}
                onClick={() => setType(t)}
                className={`flex items-center gap-1.5 rounded-md border px-2.5 py-1 text-[11px] font-medium uppercase tracking-wide transition ${type === t ? "border-brand bg-brand-soft text-brand" : "border-border bg-card text-muted hover:bg-card2"}`}
              >
                {IconMap[t]} {t}
              </button>
            ))}
          </div>
          <button onClick={save} disabled={saving || !note.trim()} className="flex h-7 items-center gap-1.5 rounded-md bg-brand px-3 text-[12px] font-semibold text-white transition hover:opacity-95 disabled:opacity-60">
            {saving ? <Loader2 size={13} className="spin" /> : "Save"}
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 max-h-[600px] space-y-4">
        {notes.length === 0 ? (
          <div className="text-center text-sm text-faint py-8">No interactions logged yet.</div>
        ) : (
          notes.map((n) => (
            <div key={n.id} className="relative pl-6">
              <span className="absolute left-0 top-1 flex h-4 w-4 items-center justify-center rounded-full bg-card2">
                {IconMap[n.type] || IconMap.note}
              </span>
              <div className="rounded-lg border border-border bg-card p-3">
                <p className="text-[13px] text-fg whitespace-pre-wrap">{n.note}</p>
                <div className="mt-2 text-[11px] font-medium text-faint">
                  {new Date(n.created_at).toLocaleString('en-GB', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })}
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </Card>
  );
}
