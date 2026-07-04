"use client";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { ArrowRight, Lock, Mail } from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const submit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => router.push("/dashboard"), 500);
  };

  return (
    <div className="grid min-h-screen bg-white lg:grid-cols-2">
      {/* Cover */}
      <div className="relative hidden overflow-hidden lg:block">
        <Image src="/login-cover.jpg" alt="" fill priority className="object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-zinc-950/80 via-zinc-900/45 to-zinc-900/25" />
        <div className="relative z-10 flex h-full flex-col justify-between p-12 text-white">
          <div className="flex items-center gap-3">
            <div className="grid h-11 w-11 place-items-center rounded-2xl bg-white/15 text-xl font-bold backdrop-blur ring-1 ring-white/30">D</div>
            <span className="text-lg font-semibold tracking-tight">DAIRY DEMO</span>
          </div>
          <div>
            <h1 className="max-w-md text-4xl font-bold leading-tight tracking-tight">
              Run your dairy distribution from one console.
            </h1>
            <p className="mt-4 max-w-md text-white/80">
              Orders, stock, retailers, khata and reports - add inventory straight from a supplier PDF bill.
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
          <span className="text-[12px] text-white/60">Powered by DIAL ERP &middot; v1.0 (demo)</span>
        </div>
      </div>

      {/* Form - fixed white regardless of theme */}
      <div className="flex items-center justify-center bg-white p-6">
        <form onSubmit={submit} className="w-full max-w-sm">
          <div className="mb-1 text-[12px] font-semibold uppercase tracking-widest text-red-600">Welcome back</div>
          <h2 className="text-2xl font-bold tracking-tight text-zinc-900">Sign in to Admin</h2>
          <p className="mt-1 text-sm text-zinc-500">Use any credentials - this is a demo console.</p>

          <div className="mt-7 space-y-4">
            <label className="block">
              <span className="mb-1.5 block text-[12px] font-medium text-zinc-500">Email</span>
              <div className="flex items-center gap-2 rounded-lg border border-zinc-200 bg-white px-3 focus-within:border-red-500 focus-within:ring-2 focus-within:ring-red-100">
                <Mail size={16} className="text-zinc-400" />
                <input defaultValue="admin@dairydemo.in" className="w-full bg-transparent py-2.5 text-sm text-zinc-900 outline-none" />
              </div>
            </label>
            <label className="block">
              <span className="mb-1.5 block text-[12px] font-medium text-zinc-500">Password</span>
              <div className="flex items-center gap-2 rounded-lg border border-zinc-200 bg-white px-3 focus-within:border-red-500 focus-within:ring-2 focus-within:ring-red-100">
                <Lock size={16} className="text-zinc-400" />
                <input type="password" defaultValue="demo1234" className="w-full bg-transparent py-2.5 text-sm text-zinc-900 outline-none" />
              </div>
            </label>
          </div>

          <div className="mt-3 flex items-center justify-between text-[13px]">
            <label className="flex items-center gap-2 text-zinc-500"><input type="checkbox" defaultChecked className="accent-red-600" /> Remember me</label>
            <a className="font-medium text-red-600">Forgot password?</a>
          </div>

          <button disabled={loading} className="mt-6 flex w-full items-center justify-center gap-2 rounded-lg bg-red-600 py-3 text-sm font-semibold text-white shadow-[0_8px_18px_rgba(226,35,26,.28)] transition hover:bg-red-700 disabled:opacity-70">
            {loading ? "Signing in..." : <>Sign In to Console <ArrowRight size={16} /></>}
          </button>
          <p className="mt-4 text-center text-[12px] text-zinc-400">Demo login &middot; no real authentication</p>
        </form>
      </div>
    <p className="mt-8 text-center text-xs text-slate-500">Powered by <a href="https://codeblimp.com" target="_blank" rel="noopener noreferrer" className="font-semibold text-blue-700 hover:underline">CodeBlimp</a></p>
      </div>
  );
}