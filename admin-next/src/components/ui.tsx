import { ReactNode } from "react";

export function Card({ children, className = "" }: { children: ReactNode; className?: string }) {
  return (
    <div className={`rounded-xl border border-border bg-card elev-1 ${className}`}>
      {children}
    </div>
  );
}

export function CardHead({ title, sub, action }: { title: string; sub?: string; action?: ReactNode }) {
  return (
    <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-border2 px-5 py-4">
      <div>
        <h3 className="text-[14.5px] font-semibold tracking-tight text-fg">{title}</h3>
        {sub && <p className="mt-0.5 text-[12px] text-faint">{sub}</p>}
      </div>
      {action && <div className="w-full sm:w-auto">{action}</div>}
    </div>
  );
}

type Tone = "ok" | "info" | "warn" | "bad" | "muted";

const toneClass: Record<Tone, string> = {
  ok: "bg-success-soft text-success",
  info: "bg-info-soft text-info",
  warn: "bg-warning-soft text-warning",
  bad: "bg-danger-soft text-danger",
  muted: "border border-border bg-card2 text-muted",
};

const dotClass: Record<Tone, string> = {
  ok: "bg-success",
  info: "bg-info",
  warn: "bg-warning",
  bad: "bg-danger",
  muted: "bg-faint",
};

export function statusTone(s: string): Tone {
  if (["Delivered", "Approved", "Verified", "In Stock", "Filed", "Paid", "Online"].includes(s)) return "ok";
  if (["Dispatched", "Confirmed"].includes(s)) return "info";
  if (["Packed", "Placed", "Pending", "Low", "Khata"].includes(s)) return "warn";
  if (["Cancelled", "Rejected", "Out of Stock", "COD"].includes(s)) return "bad";
  return "muted";
}

export function Badge({ children, tone = "muted", dot = true }: { children: ReactNode; tone?: Tone; dot?: boolean }) {
  return (
    <span className={`inline-flex items-center gap-1.5 rounded-md px-2 py-[3px] text-[11px] font-medium leading-none ${toneClass[tone]}`}>
      {dot && <span className={`h-1.5 w-1.5 rounded-full ${dotClass[tone]}`} />}
      {children}
    </span>
  );
}

export function Pill({ s }: { s: string }) {
  return <Badge tone={statusTone(s)}>{s}</Badge>;
}
