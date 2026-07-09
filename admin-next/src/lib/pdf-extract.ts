export type PItem = { name: string; qty: number; unit: string; rate: number; amount: number; match: number };
export type Parsed = { meta: { supplier: string; billNo: string; date: string }; items: PItem[]; demo: boolean };

// Matching is done against the LIVE catalog passed in (id + name), not a hardcoded list.
export type MatchProduct = { name: string };

function norm(s: string) { return (s || "").toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim(); }

export function matchProduct(name: string, products: MatchProduct[]): number {
  const a = norm(name).split(" ").filter((w) => w.length >= 3);
  let best = -1, score = 0;
  products.forEach((p, idx) => {
    const b = norm(p.name).split(" ").filter((w) => w.length >= 3);
    let s = a.filter((w) => b.includes(w)).length;
    if (norm(p.name).includes(norm(name)) || norm(name).includes(norm(p.name))) s += 2;
    if (s > score) { score = s; best = idx; }
  });
  return score >= 2 ? best : -1;
}

function todayStr() {
  const m = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const d = new Date();
  return String(d.getDate()).padStart(2, "0") + "-" + m[d.getMonth()] + "-" + d.getFullYear();
}

function demoItems(): PItem[] {
  return [
    { name: "Cow Milk Value Pack 320ml", qty: 20, unit: "CRT", rate: 476, amount: 9520, match: -1 },
    { name: "Standard Milk 500ml", qty: 10, unit: "CRT", rate: 709, amount: 7090, match: -1 },
    { name: "Ananda Dahi Cup 400g", qty: 15, unit: "CRT", rate: 360, amount: 5400, match: -1 },
    { name: "Pure Ghee 1L Tin", qty: 5, unit: "CTN", rate: 1620, amount: 8100, match: -1 },
    { name: "Fresh Paneer 1kg", qty: 12, unit: "EA", rate: 350, amount: 4200, match: -1 },
    { name: "Table Butter 500g", qty: 8, unit: "CRT", rate: 256, amount: 2048, match: -1 },
  ];
}

function parseItems(lines: string[]): PItem[] {
  const out: PItem[] = [];
  const header = /(total|grand|sub\s?total|amount in words|gstin|cgst|sgst|igst|invoice|bill no|hsn|qty|rate|terms|bank|page \d)/i;
  for (const raw of lines) {
    const line = raw.trim();
    if (line.length < 5) continue;
    const firstNum = line.search(/\d/);
    if (firstNum < 3) continue;
    const name = line.slice(0, firstNum).replace(/[|*#:]/g, " ").replace(/\s+/g, " ").trim();
    if (name.length < 3 || !/[a-z]{3,}/i.test(name) || header.test(name)) continue;
    const nums = (line.slice(firstNum).match(/\d[\d,]*\.?\d*/g) || []).map((n) => parseFloat(n.replace(/,/g, ""))).filter((n) => !isNaN(n) && n > 0);
    if (nums.length < 2) continue;
    const amount = nums[nums.length - 1];
    const rate = nums.length >= 3 ? nums[nums.length - 2] : 0;
    let qty = nums.length >= 3 ? nums[0] : rate ? Math.round(amount / rate) : 1;
    if (!qty || qty > 100000) qty = 1;
    const unitMatch = line.match(/crt|ctn|case|box|pkt|bag/i);
    out.push({ name, qty, unit: unitMatch ? unitMatch[0].toUpperCase() : "EA", rate: rate || (qty ? +(amount / qty).toFixed(2) : amount), amount, match: -1 });
  }
  return out;
}

function parseMeta(lines: string[]) {
  const text = lines.join("\n");
  const bill = (text.match(/(?:invoice|bill)\s*(?:no\.?|#|number)?\s*[:\-]?\s*([A-Z0-9][A-Z0-9\-/]{2,})/i) || [])[1] || "";
  const date = (text.match(/\b(\d{1,2}[-/][A-Za-z0-9]{2,4}[-/]\d{2,4})\b/) || [])[1] || "";
  let supplier = "";
  for (const l of lines.slice(0, 8)) {
    if (l.length > 5 && /[a-z]{4,}/i.test(l) && !/\d{4,}/.test(l) && !/invoice|tax|gst/i.test(l)) { supplier = l; break; }
  }
  return { supplier: supplier || "Supplier", billNo: bill || "PUR-" + (1000 + (lines.length % 9000)), date: date || todayStr() };
}

export async function extractBill(file: File, products: MatchProduct[]): Promise<Parsed> {
  try {
    if (/\.pdf$/i.test(file.name)) {
      const pdfjs = await import("pdfjs-dist");
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      (pdfjs as any).GlobalWorkerOptions.workerSrc = "/pdf.worker.min.mjs";
      const buf = await file.arrayBuffer();
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      const doc = await (pdfjs as any).getDocument({ data: buf }).promise;
      const lines: string[] = [];
      for (let p = 1; p <= doc.numPages; p++) {
        const page = await doc.getPage(p);
        const tc = await page.getTextContent();
        const rows: Record<number, { x: number; s: string }[]> = {};
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (tc.items as any[]).forEach((it) => {
          if (!it.str) return;
          const y = Math.round(it.transform[5]);
          (rows[y] = rows[y] || []).push({ x: it.transform[4], s: it.str });
        });
        Object.keys(rows).map(Number).sort((a, b) => b - a).forEach((y) => {
          const line = rows[y].sort((a, b) => a.x - b.x).map((o) => o.s).join(" ").replace(/\s+/g, " ").trim();
          if (line) lines.push(line);
        });
      }
      const items = parseItems(lines);
      if (items.length >= 2) {
        items.forEach((it) => (it.match = matchProduct(it.name, products)));
        return { meta: parseMeta(lines), items, demo: false };
      }
    }
  } catch { /* fall through */ }
  const items = demoItems();
  items.forEach((it) => (it.match = matchProduct(it.name, products)));
  return { meta: { supplier: "Aggarwal Distributors", billNo: "PUR-" + (1000 + (Date.now() % 9000)), date: todayStr() }, items, demo: true };
}
