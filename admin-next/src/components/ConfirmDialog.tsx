import { Loader2, AlertTriangle } from "lucide-react";

type Props = {
  open: boolean;
  title: string;
  desc: string;
  confirmText?: string;
  danger?: boolean;
  loading?: boolean;
  onConfirm: () => void;
  onCancel: () => void;
};

export default function ConfirmDialog({ open, title, desc, confirmText = "Confirm", danger = true, loading = false, onConfirm, onCancel }: Props) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[100] grid place-items-center bg-black/50 p-4" onClick={!loading ? onCancel : undefined}>
      <div className="w-full max-w-[360px] rounded-2xl border border-border bg-card shadow-2xl overflow-hidden" onClick={(e) => e.stopPropagation()}>
        <div className="p-6">
          <div className="mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-danger-soft">
            <AlertTriangle className="text-danger" size={24} />
          </div>
          <h3 className="text-lg font-bold text-fg mb-1">{title}</h3>
          <p className="text-sm text-muted">{desc}</p>
        </div>
        <div className="flex gap-3 bg-card2 px-6 py-4">
          <button 
            onClick={onCancel} 
            disabled={loading}
            className="flex-1 rounded-lg border border-border bg-card py-2.5 text-sm font-semibold text-fg hover:bg-card2 disabled:opacity-50"
          >
            Cancel
          </button>
          <button 
            onClick={onConfirm} 
            disabled={loading}
            className={`flex flex-1 items-center justify-center gap-2 rounded-lg py-2.5 text-sm font-semibold text-white transition hover:opacity-95 disabled:opacity-60 ${danger ? "bg-danger" : "bg-brand"}`}
          >
            {loading && <Loader2 size={15} className="spin" />}
            {loading ? "Deleting..." : confirmText}
          </button>
        </div>
      </div>
    </div>
  );
}
