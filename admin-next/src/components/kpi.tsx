"use client";
import { useEffect, useRef, useState } from "react";
import { ArrowDownRight, ArrowUpRight } from "lucide-react";

function Spark({ data, up }: { data: number[]; up: boolean }) {
  const w = 120, h = 34, max = Math.max(...data), min = Math.min(...data), rng = max - min || 1;
  const pts = data.map((v, i) => [(i / (data.length - 1)) * w, h - 3 - ((v - min) / rng) * (h - 7)]);
  const d = pts.map((p, i) => (i ? "L" : "M") + p[0].toFixed(1) + " " + p[1].toFixed(1)).join(" ");
  const stroke = up ? "var(--success)" : "var(--danger)";
  return (
    <svg viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none" className="h-8 w-full">
      <path d={`${d} L ${w} ${h} L 0 ${h} Z`} fill={stroke} opacity={0.08} />
      <path d={d} fill="none" stroke={stroke} strokeWidth={1.75} strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export function KpiCard({ label, value, prefix = "", delta, down, spark, delay = 0 }: {
  label: string; value: number; prefix?: string; delta: number; down?: boolean; spark: number[]; delay?: number;
}) {
  const [n, setN] = useState(0);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const dur = 800, t0 = performance.now();
    let raf = 0;
    const step = (t: number) => {
      const p = Math.min((t - t0) / dur, 1), e = 1 - Math.pow(1 - p, 3);
      setN(Math.round(value * e));
      if (p < 1) raf = requestAnimationFrame(step);
    };
    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, [value]);

  return (
    <div ref={ref} className="fade-up rounded-xl border border-border bg-card p-5 elev-1" style={{ animationDelay: `${delay}ms` }}>
      <div className="flex items-center justify-between">
        <span className="text-[11px] font-semibold uppercase tracking-[0.06em] text-faint">{label}</span>
        <span className={`inline-flex items-center gap-0.5 rounded-md px-1.5 py-0.5 text-[11px] font-semibold ${down ? "bg-danger-soft text-danger" : "bg-success-soft text-success"}`}>
          {down ? <ArrowDownRight size={12} /> : <ArrowUpRight size={12} />}{Math.abs(delta)}%
        </span>
      </div>
      <div className="tnum mt-2.5 text-[27px] font-semibold leading-none tracking-tight text-fg">{prefix}{n.toLocaleString("en-IN")}</div>
      <div className="mt-3"><Spark data={spark} up={!down} /></div>
    </div>
  );
}
