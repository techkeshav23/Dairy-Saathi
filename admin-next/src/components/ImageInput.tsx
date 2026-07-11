"use client";
import { useState, useRef, useCallback } from "react";
import { ImageIcon, UploadCloud, Loader2, Crop as CropIcon, X } from "lucide-react";
import Cropper from "react-easy-crop";
import { createClient } from "@/lib/supabase-browser";
import { getCroppedBlob, type CropArea } from "@/lib/crop-image";

export default function ImageInput({
  value,
  onChange,
  placeholder = "https://…/image.jpg",
  cropAspect,
}: {
  value: string;
  onChange: (url: string) => void;
  placeholder?: string;
  /** When set, the admin can crop the image to this width:height ratio before saving. */
  cropAspect?: number;
}) {
  const [mode, setMode] = useState<"url" | "upload">("url");
  const [uploading, setUploading] = useState(false);
  const [err, setErr] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);
  const supabase = createClient();

  // Crop state
  const [cropSrc, setCropSrc] = useState<string | null>(null);
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [areaPixels, setAreaPixels] = useState<CropArea | null>(null);
  const [objectUrl, setObjectUrl] = useState<string | null>(null); // to revoke later

  const onCropComplete = useCallback((_: unknown, areaPx: CropArea) => setAreaPixels(areaPx), []);

  const uploadBlob = async (blob: Blob | File, ext = "jpg"): Promise<void> => {
    setUploading(true);
    setErr("");
    try {
      const fileName = `${Math.random().toString(36).substring(2, 15)}_${Date.now()}.${ext}`;
      const filePath = `uploads/${fileName}`;
      const { error: uploadError } = await supabase.storage.from("public_images").upload(filePath, blob);
      if (uploadError) throw uploadError;
      const { data } = supabase.storage.from("public_images").getPublicUrl(filePath);
      onChange(data.publicUrl);
    } catch (error) {
      setErr(error instanceof Error ? error.message : "Failed to upload image");
    } finally {
      setUploading(false);
      if (fileInputRef.current) fileInputRef.current.value = "";
    }
  };

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (cropAspect) {
      // Open the cropper on the local file (no CORS issues).
      const url = URL.createObjectURL(file);
      setObjectUrl(url);
      setCropSrc(url);
      setCrop({ x: 0, y: 0 });
      setZoom(1);
    } else {
      const ext = file.name.split(".").pop() || "jpg";
      await uploadBlob(file, ext);
    }
  };

  const closeCropper = () => {
    setCropSrc(null);
    if (objectUrl) { URL.revokeObjectURL(objectUrl); setObjectUrl(null); }
  };

  const applyCrop = async () => {
    if (!cropSrc || !areaPixels) return;
    try {
      const blob = await getCroppedBlob(cropSrc, areaPixels);
      await uploadBlob(blob, "jpg");
      closeCropper();
    } catch (error) {
      setErr(error instanceof Error ? error.message : "Crop failed");
    }
  };

  const startCropFromValue = () => {
    if (!value) return;
    setObjectUrl(null); // remote URL, nothing to revoke
    setCropSrc(value);
    setCrop({ x: 0, y: 0 });
    setZoom(1);
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center gap-2">
        <span className="flex items-center gap-1.5 text-[12px] font-medium text-muted">
          <ImageIcon size={13} /> Image <span className="text-faint">(optional)</span>
        </span>
        <div className="ml-auto flex items-center rounded-md border border-border bg-card2 p-0.5 text-[11px] font-medium text-muted">
          <button type="button" onClick={() => setMode("url")}
            className={`rounded px-2.5 py-1 transition ${mode === "url" ? "bg-card text-fg shadow-sm" : "hover:text-fg"}`}>URL</button>
          <button type="button" onClick={() => setMode("upload")}
            className={`rounded px-2.5 py-1 transition ${mode === "upload" ? "bg-card text-fg shadow-sm" : "hover:text-fg"}`}>Upload</button>
        </div>
      </div>

      {mode === "url" ? (
        <input value={value} onChange={(e) => onChange(e.target.value)} placeholder={placeholder}
          className="w-full rounded-lg border border-border bg-card px-3 py-2 text-sm text-fg outline-none focus:border-brand focus:ring-2 focus:ring-brand-soft" />
      ) : (
        <div className="relative">
          <input type="file" accept="image/*" ref={fileInputRef} onChange={handleFileChange} className="hidden" />
          <div className="flex items-center gap-2">
            <button type="button" onClick={() => fileInputRef.current?.click()} disabled={uploading}
              className="flex w-full items-center justify-center gap-2 rounded-lg border border-dashed border-border bg-card px-3 py-2 text-sm text-fg transition hover:border-brand hover:bg-brand/5 disabled:opacity-50">
              {uploading ? <Loader2 size={16} className="spin" /> : <UploadCloud size={16} />}
              {uploading ? "Uploading..." : "Click to select a file"}
            </button>
            {value && !uploading && (
              <button type="button" onClick={() => onChange("")} className="px-3 py-2 text-[12px] text-faint hover:text-danger border border-border rounded-lg h-[38px]">Clear</button>
            )}
          </div>
        </div>
      )}

      {/* Crop the current image (works for uploaded or URL images) */}
      {cropAspect && value && !cropSrc && (
        <button type="button" onClick={startCropFromValue}
          className="flex items-center gap-1.5 text-[12px] font-medium text-info hover:underline">
          <CropIcon size={13} /> Crop image
        </button>
      )}

      {err && <p className="text-[11px] text-danger">{err}</p>}

      {/* Crop modal */}
      {cropSrc && cropAspect && (
        <div className="fixed inset-0 z-[60] grid place-items-center bg-black/60 p-4" onClick={closeCropper}>
          <div className="w-full max-w-md rounded-2xl border border-border bg-card shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-center justify-between border-b border-border px-5 py-4">
              <h3 className="text-[15px] font-semibold text-fg">Crop image</h3>
              <button onClick={closeCropper} className="grid h-8 w-8 place-items-center rounded-lg bg-card2 text-muted"><X size={16} /></button>
            </div>
            <div className="relative h-64 w-full bg-black">
              <Cropper image={cropSrc} crop={crop} zoom={zoom} aspect={cropAspect}
                onCropChange={setCrop} onZoomChange={setZoom} onCropComplete={onCropComplete} />
            </div>
            <div className="flex items-center gap-3 px-5 py-3">
              <span className="text-[12px] text-muted">Zoom</span>
              <input type="range" min={1} max={3} step={0.01} value={zoom}
                onChange={(e) => setZoom(Number(e.target.value))} className="flex-1 accent-brand" />
            </div>
            <div className="flex gap-3 px-5 pb-5">
              <button onClick={closeCropper} className="flex-1 rounded-lg border border-border py-2.5 text-sm font-semibold text-fg hover:bg-card2">Cancel</button>
              <button onClick={applyCrop} disabled={uploading}
                className="flex flex-1 items-center justify-center gap-2 rounded-lg bg-brand py-2.5 text-sm font-semibold text-white transition hover:opacity-95 disabled:opacity-60">
                {uploading ? <Loader2 size={15} className="spin" /> : <CropIcon size={15} />}{uploading ? "Saving…" : "Apply crop"}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
