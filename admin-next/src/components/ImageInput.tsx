"use client";
import { useState, useRef } from "react";
import { ImageIcon, UploadCloud, Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase-browser";

export default function ImageInput({
  value,
  onChange,
  placeholder = "https://…/image.jpg",
}: {
  value: string;
  onChange: (url: string) => void;
  placeholder?: string;
}) {
  const [mode, setMode] = useState<"url" | "upload">("url");
  const [uploading, setUploading] = useState(false);
  const [err, setErr] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);
  const supabase = createClient();

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setUploading(true);
    setErr("");
    
    try {
      const fileExt = file.name.split(".").pop();
      const fileName = `${Math.random().toString(36).substring(2, 15)}_${Date.now()}.${fileExt}`;
      const filePath = `uploads/${fileName}`;

      const { error: uploadError } = await supabase.storage
        .from("public_images")
        .upload(filePath, file);

      if (uploadError) {
        throw uploadError;
      }

      const { data } = supabase.storage.from("public_images").getPublicUrl(filePath);
      onChange(data.publicUrl);
    } catch (error: any) {
      setErr(error.message || "Failed to upload image");
    } finally {
      setUploading(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
    }
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2">
        <span className="flex items-center gap-1.5 text-[12px] font-medium text-muted">
          <ImageIcon size={13} /> Image <span className="text-faint">(optional)</span>
        </span>
        <div className="ml-auto flex items-center rounded-md border border-border bg-card2 p-0.5 text-[11px] font-medium text-muted">
          <button
            type="button"
            onClick={() => setMode("url")}
            className={`rounded px-2.5 py-1 transition ${
              mode === "url" ? "bg-card text-fg shadow-sm" : "hover:text-fg"
            }`}
          >
            URL
          </button>
          <button
            type="button"
            onClick={() => setMode("upload")}
            className={`rounded px-2.5 py-1 transition ${
              mode === "upload" ? "bg-card text-fg shadow-sm" : "hover:text-fg"
            }`}
          >
            Upload
          </button>
        </div>
      </div>

      {mode === "url" ? (
        <input
          value={value}
          onChange={(e) => onChange(e.target.value)}
          placeholder={placeholder}
          className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft"
        />
      ) : (
        <div className="relative">
          <input
            type="file"
            accept="image/*"
            ref={fileInputRef}
            onChange={handleFileChange}
            className="hidden"
          />
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              disabled={uploading}
              className="flex w-full items-center justify-center gap-2 rounded-lg border border-dashed border-border bg-card px-3 py-2 text-sm text-fg transition hover:border-brand hover:bg-brand/5 disabled:opacity-50"
            >
              {uploading ? <Loader2 size={16} className="spin" /> : <UploadCloud size={16} />}
              {uploading ? "Uploading..." : "Click to select a file"}
            </button>
            {value && !uploading && (
               <button type="button" onClick={() => onChange("")} className="px-3 py-2 text-[12px] text-faint hover:text-danger border border-border rounded-lg h-[38px]">Clear</button>
            )}
          </div>
        </div>
      )}
      {err && <p className="text-[11px] text-danger">{err}</p>}
    </div>
  );
}
