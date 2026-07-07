"use client";
import { useState } from "react";
import { Loader2, CheckCircle2, XCircle, Eye } from "lucide-react";
import * as Dialog from "@radix-ui/react-dialog";

export default function PaymentVerification({
  id,
  paymentMode,
  paymentScreenshot,
  initialPaymentStatus,
}: {
  id: string;
  paymentMode: string;
  paymentScreenshot?: string | null;
  initialPaymentStatus?: string | null;
}) {
  const [status, setStatus] = useState(initialPaymentStatus || "verified");
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);

  if (paymentMode.toLowerCase() !== "qr") {
    return <span className="font-medium text-fg">{paymentMode}</span>;
  }

  const handleUpdate = async (newStatus: string) => {
    setLoading(true);
    try {
      const res = await fetch("/api/orders", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id, payment_status: newStatus }),
      });
      if (!res.ok) throw new Error("Failed to update payment status");
      setStatus(newStatus);
      setOpen(false);
    } catch (error) {
      console.error(error);
      alert("Failed to update payment status");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex items-center gap-2">
      <span className="font-medium text-fg">QR Pay</span>
      
      {status === "pending" && (
        <Dialog.Root open={open} onOpenChange={setOpen}>
          <Dialog.Trigger asChild>
            <button className="flex items-center gap-1 rounded bg-warning-soft px-2 py-0.5 text-[11px] font-medium text-warning hover:bg-warning/20">
              <Eye size={12} /> Verify
            </button>
          </Dialog.Trigger>
          <Dialog.Portal>
            <Dialog.Overlay className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm" />
            <Dialog.Content className="fixed left-[50%] top-[50%] z-50 w-full max-w-sm translate-x-[-50%] translate-y-[-50%] rounded-xl bg-card p-5 shadow-2xl">
              <Dialog.Title className="text-lg font-bold text-fg">Verify Payment</Dialog.Title>
              <Dialog.Description className="mt-1 text-sm text-muted">
                Review the screenshot uploaded by the retailer.
              </Dialog.Description>
              
              <div className="my-4 flex justify-center rounded-lg bg-card2 p-2 border border-border">
                {paymentScreenshot ? (
                  <img src={paymentScreenshot} alt="Payment Screenshot" className="max-h-64 rounded object-contain" />
                ) : (
                  <div className="py-10 text-muted">No screenshot provided</div>
                )}
              </div>

              <div className="flex justify-end gap-3">
                <button
                  onClick={() => handleUpdate("rejected")}
                  disabled={loading}
                  className="flex items-center gap-1.5 rounded-lg border border-danger text-danger px-4 py-2 text-sm font-medium hover:bg-danger-soft disabled:opacity-50"
                >
                  <XCircle size={16} /> Reject
                </button>
                <button
                  onClick={() => handleUpdate("verified")}
                  disabled={loading}
                  className="flex items-center gap-1.5 rounded-lg bg-success px-4 py-2 text-sm font-medium text-white hover:bg-success/90 disabled:opacity-50"
                >
                  {loading ? <Loader2 size={16} className="spin" /> : <CheckCircle2 size={16} />}
                  Approve
                </button>
              </div>
            </Dialog.Content>
          </Dialog.Portal>
        </Dialog.Root>
      )}

      {status === "verified" && (
        <span className="flex items-center gap-1 rounded bg-success-soft px-2 py-0.5 text-[11px] font-medium text-success">
          <CheckCircle2 size={12} /> Verified
        </span>
      )}

      {status === "rejected" && (
        <span className="flex items-center gap-1 rounded bg-danger-soft px-2 py-0.5 text-[11px] font-medium text-danger">
          <XCircle size={12} /> Rejected
        </span>
      )}
    </div>
  );
}
