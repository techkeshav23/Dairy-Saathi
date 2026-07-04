"use client";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { ArrowRight, Lock, Mail, Loader2 } from "lucide-react";
import { createClient } from "@/lib/supabase-browser";

export default function LoginPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [err, setErr] = useState("");

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password) { setErr("Enter your email and password"); return; }
    setLoading(true); setErr("");
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password });
    if (error) { setErr(error.message); setLoading(false); return; }
    router.push("/dashboard");
    router.refresh();
  };

  return (
    <div className="flex min-h-screen bg-white">
      {/* Cover - full-height left side */}
      <div className="relative hidden w-1/2 overflow-hidden lg:block">
        <Image src="/login-cover.jpg" alt="" fill priority sizes="50vw" className="object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-zinc-950/80 via-zinc-900/45 to-zinc-900/25" />
        <div className="relative z-10 flex h-full flex-col justify-between p-12 text-white">
          <div className="flex items-center gap-3">
            <Image src="/logo.jpeg" alt="MY ORDER PRO" width={44} height={44} className="rounded-2xl ring-1 ring-white/30" />
            <span className="text-lg font-semibold tracking-tight">MY ORDER PRO</span>
          </div>
          <div>
            <h1 className="max-w-md text-4xl font-bold leading-tight tracking-tight">
              Run your wholesale distribution from one console.
            </h1>
            <p className="mt-4 max-w-md text-white/80">
              Orders, stock, retailers, khata and reports — manage your entire B2B business in one place.
            </p>
            <div className="mt-10 flex gap-10">
              {[["Rs 48.4L", "Revenue this FY"], ["1,284", "Orders processed"], ["318", "Active retailers"]].map(([a, b]) => (
                <div key={b}>
                  <div className="text-2xl font-bold">{a}</div>
                  <div className="text-[12px] text-white/70">{b}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* Form */}
      <div className="flex w-full flex-col items-center justify-center bg-white p-6 lg:w-1/2">
        <form onSubmit={submit} className="w-full max-w-sm">
          <div className="mb-1 text-[12px] font-semibold uppercase tracking-widest text-brand">Welcome back</div>
          <h2 className="text-2xl font-bold tracking-tight text-zinc-900">Sign in to Admin</h2>
          <p className="mt-1 text-sm text-zinc-500">Sign in to manage your distribution business.</p>

          <div className="mt-7 space-y-4">
            <label className="block">
              <span className="mb-1.5 block text-[12px] font-medium text-zinc-500">Email</span>
              <div className="flex items-center gap-2 rounded-lg border border-zinc-200 bg-white px-3 focus-within:border-brand focus-within:ring-2 focus-within:ring-brand-soft">
                <Mail size={16} className="text-zinc-400" />
                <input type="email" autoComplete="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="admin@admin.com"
                  className="w-full bg-transparent py-2.5 text-sm text-zinc-900 outline-none placeholder:text-zinc-300" />
              </div>
            </label>
            <label className="block">
              <span className="mb-1.5 block text-[12px] font-medium text-zinc-500">Password</span>
              <div className="flex items-center gap-2 rounded-lg border border-zinc-200 bg-white px-3 focus-within:border-brand focus-within:ring-2 focus-within:ring-brand-soft">
                <Lock size={16} className="text-zinc-400" />
                <input type="password" autoComplete="current-password" value={password} onChange={(e) => setPassword(e.target.value)} placeholder="••••••••"
                  className="w-full bg-transparent py-2.5 text-sm text-zinc-900 outline-none placeholder:text-zinc-300" />
              </div>
            </label>
          </div>

          {err && <p className="mt-3 rounded-lg bg-red-50 px-3 py-2 text-[13px] font-medium text-red-600">{err}</p>}

          <div className="mt-3 flex items-center justify-between text-[13px]">
            <label className="flex items-center gap-2 text-zinc-500"><input type="checkbox" defaultChecked className="accent-brand" /> Remember me</label>
            <a className="font-medium text-brand">Forgot password?</a>
          </div>

          <button disabled={loading} className="mt-6 flex w-full items-center justify-center gap-2 rounded-lg bg-brand py-3 text-sm font-semibold text-white shadow-[0_8px_18px_rgba(43,80,214,.22)] transition hover:opacity-95 disabled:opacity-70">
            {loading ? <><Loader2 size={16} className="spin" /> Signing in…</> : <>Sign In to Console <ArrowRight size={16} /></>}
          </button>
        </form>
        <p className="mt-8 text-center text-xs text-slate-500">Powered by <a href="https://codeblimp.com" target="_blank" rel="noopener noreferrer" className="font-semibold text-blue-700 hover:underline">CodeBlimp</a></p>
      </div>
    </div>
  );
}
