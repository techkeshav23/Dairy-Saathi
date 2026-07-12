import { NextRequest, NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

// Reads a supplier bill (PDF or image) with Gemini and returns the product line items.
// Uses the key + model saved in admin_config (service_role only). If AI is disabled or no
// key is set, returns { aiUsed: false } so the client falls back to the basic parser.

/* eslint-disable @typescript-eslint/no-explicit-any */

const PROMPT = `You are reading a wholesale supplier purchase bill / invoice (Indian dairy / FMCG).
Extract EVERY product line item. Return a JSON array; each element must be:
{"name": string, "crates": number, "pieces": number, "rate": number, "amount": number}

Quantities on these bills often have TWO parts, e.g. "1.00 CRT / 60.00 EA", "5 CRA / 150 EA", "2 CASE / 48 PCS":
- "crates" = number of crates / cases / cartons / boxes (CRT, CRA, CASE, BOX, CTN).
             Use 0 if the item is sold loose, only in EA/PCS, or only one quantity is shown.
- "pieces" = TOTAL number of individual pieces (EA / PCS / NOS). This is the real sellable count.
             If the bill shows "1 CRT / 60 EA", pieces = 60 (NOT 1).
             If ONLY ONE quantity is shown (e.g. "7 TRAY", "2 EA", "12 PCS"), put that number in
             "pieces" and set "crates" to 0.
- "rate"   = the per-unit purchase rate shown on that line (number only).
- "amount" = the line total / amount (number only).

name = clean product name only (no ErpID, HSN, SKU, barcode numbers).
Ignore headers, totals, taxes, terms, bank details. If a value is missing use 0.
Return ONLY the JSON array — no markdown, no commentary.`;

function coerceItems(raw: any): { name: string; crates: number; pieces: number; rate: number; amount: number }[] {
  let arr: any = raw;
  if (arr && !Array.isArray(arr) && Array.isArray(arr.items)) arr = arr.items;
  if (!Array.isArray(arr)) return [];
  return arr
    .map((it: any) => {
      const crates = Number(it?.crates) || 0;
      // Back-compat: some responses may still use "qty"; treat it as pieces if pieces missing.
      let pieces = Number(it?.pieces) || 0;
      if (pieces <= 0) pieces = Number(it?.qty) || 0;
      return {
        name: String(it?.name ?? "").trim(),
        crates,
        pieces,
        rate: Number(it?.rate) || 0,
        amount: Number(it?.amount) || 0,
      };
    })
    .filter((it: any) => it.name.length > 0);
}

export async function POST(req: NextRequest) {
  if (!supabaseAdmin) return NextResponse.json({ aiUsed: false, error: "Admin not configured" });

  const { data: cfg } = await supabaseAdmin.from("admin_config").select("*").eq("id", 1).single();
  if (!cfg?.ai_enabled || !cfg?.gemini_api_key) {
    return NextResponse.json({ aiUsed: false });
  }

  const body = await req.json();
  const base64 = String(body?.fileBase64 ?? "");
  const mimeType = String(body?.mimeType ?? "application/pdf");
  if (!base64) return NextResponse.json({ aiUsed: false, error: "No file" });

  const model = cfg.gemini_model || "gemini-2.5-flash";
  try {
    const r = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${cfg.gemini_api_key}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [{ parts: [{ inline_data: { mime_type: mimeType, data: base64 } }, { text: PROMPT }] }],
          generationConfig: { response_mime_type: "application/json", temperature: 0 },
        }),
      },
    );
    const j = await r.json();
    if (!r.ok) {
      return NextResponse.json({ aiUsed: false, error: j?.error?.message || `Gemini HTTP ${r.status}` });
    }
    const text = j?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";
    let parsed: any = [];
    try {
      parsed = JSON.parse(text);
    } catch {
      // try to pull the JSON array out of any wrapping text
      const m = text.match(/\[[\s\S]*\]/);
      if (m) { try { parsed = JSON.parse(m[0]); } catch { parsed = []; } }
    }
    const items = coerceItems(parsed);
    if (items.length === 0) return NextResponse.json({ aiUsed: false, error: "AI found no items" });
    return NextResponse.json({ aiUsed: true, items });
  } catch (e) {
    return NextResponse.json({ aiUsed: false, error: e instanceof Error ? e.message : "Request failed" });
  }
}
