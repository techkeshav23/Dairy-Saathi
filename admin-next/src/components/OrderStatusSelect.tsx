"use client";
import { useState } from "react";
import { Loader2 } from "lucide-react";
import { statusTone } from "./ui";

const OPTIONS = ["Placed", "Confirmed", "Packed", "Dispatched", "Delivered", "Cancelled"];

export default function OrderStatusSelect({ id, currentStatus }: { id: string; currentStatus: string }) {
  const [status, setStatus] = useState(currentStatus);
  const [loading, setLoading] = useState(false);

  const handleChange = async (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newStatus = e.target.value;
    setStatus(newStatus);
    setLoading(true);
    try {
      const res = await fetch("/api/orders", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, status: newStatus }),
      });
      if (!res.ok) throw new Error("Failed to update status");
    } catch (error) {
      console.error(error);
      setStatus(currentStatus); // Revert optimistic update
      alert("Failed to update order status");
    } finally {
      setLoading(false);
    }
  };

  const tone = statusTone(status);
  
  const bg = tone === "ok" ? "bg-success-soft text-success" :
             tone === "info" ? "bg-info-soft text-info" :
             tone === "warn" ? "bg-warning-soft text-warning" :
             tone === "bad" ? "bg-danger-soft text-danger" :
             "bg-card2 text-muted border border-border";

  return (
    <div className="relative inline-flex items-center">
      <select 
        value={status} 
        onChange={handleChange} 
        disabled={loading}
        className={`appearance-none rounded-md px-2.5 py-1 text-[11px] font-medium leading-none outline-none cursor-pointer pr-5 ${bg} ${loading ? "opacity-60" : ""}`}
      >
        {OPTIONS.map(opt => (
          <option key={opt} value={opt} className="bg-card text-fg py-1">
            {opt}
          </option>
        ))}
      </select>
      {loading ? (
        <Loader2 size={10} className="absolute right-1.5 spin" />
      ) : (
        <svg className="absolute right-1.5 pointer-events-none opacity-60" width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="m6 9 6 6 6-6"/></svg>
      )}
    </div>
  );
}
