import { ReactNode } from "react";

export function Card({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`rounded-xl border bg-card shadow-[0_1px_2px_rgba(16,24,40,.04),0_8px_24px_rgba(16,24,40,.05)] ${className}`}>
      {children}
    </div>
  );
}

export function CardHead({ title, action }: { title: string; action?: ReactNode }) {
  return (
    <div className="flex items-center justify-between px-5 pt-5 pb-3">
      <h3 className="text-[15px] font-semibold tracking-tight">{title}</h3>
      {action}
    </div>
  );
}

type Tone = "ok" | "info" | "warn" | "bad" | "muted";
const toneClass: Record<Tone, string> = {
  ok: "bg-success-soft text-success",
  info: "bg-info-soft text-info",
  warn: "bg-warning-soft text-warning",
  bad: "bg-brand-soft text-brand",
  muted: "bg-card2 text-muted border border-border",
};

export function statusTone(s: string): Tone {
  if (["Delivered", "Approved", "Verified", "In Stock", "Filed"].includes(s)) return "ok";
  if (["Dispatched", "Confirmed", "Online"].includes(s)) return "info";
  if (["Packed", "Placed", "Pending", "Low", "Khata"].includes(s)) return "warn";
  if (["Cancelled", "Rejected", "Out of Stock"].includes(s)) return "bad";
  return "muted";
}

export function Badge({ children, tone = "muted" }: { children: ReactNode; tone?: Tone }) {
  return (
    <span className={`inline-flex items-center rounded-full px-2.5 py-1 text-[11px] font-semibold leading-none ${toneClass[tone]}`}>
      {children}
    </span>
  );
}

export function Pill({ s }: { s: string }) {
  return <Badge tone={statusTone(s)}>{s}</Badge>;
}
