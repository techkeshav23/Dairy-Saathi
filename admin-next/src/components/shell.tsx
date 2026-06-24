"use client";
import { ReactNode, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import {
  LayoutDashboard, ShoppingCart, Package, Truck, Store, BookOpen,
  BarChart3, Image as ImageIcon, Settings, Search, Bell, Menu, X, LogOut, ChevronRight,
} from "lucide-react";


const NAV = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/orders", label: "Orders", icon: ShoppingCart },
  { href: "/products", label: "Products", icon: Package },
  { href: "/purchase", label: "Purchase / Stock-In", icon: Truck },
  { href: "/retailers", label: "Retailers", icon: Store },
  { href: "/ledger", label: "Ledger & Payments", icon: BookOpen },
  { href: "/reports", label: "Reports", icon: BarChart3 },
  { href: "/banners", label: "Banners", icon: ImageIcon },
  { href: "/settings", label: "Settings", icon: Settings },
];

function titleFor(path: string) {
  const n = NAV.find((x) => path.startsWith(x.href));
  return n ? n.label : "Dashboard";
}

export function Shell({ children }: { children: ReactNode }) {
  const path = usePathname();
  const router = useRouter();
  const [open, setOpen] = useState(false);

  return (
    <div className="min-h-screen lg:grid lg:grid-cols-[256px_1fr]">
      {/* Sidebar */}
      <aside
        className={`fixed inset-y-0 left-0 z-50 w-64 border-r border-border bg-sidebar transition-transform lg:static lg:translate-x-0 ${
          open ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="flex h-full flex-col">
          <div className="flex items-center gap-3 px-5 py-4">
            <div className="grid h-10 w-10 place-items-center rounded-xl bg-brand font-bold text-white shadow-[0_6px_16px_rgba(226,35,26,.35)]">D</div>
            <div className="leading-tight">
              <div className="text-sm font-semibold tracking-tight">DAIRY DEMO</div>
              <div className="text-[11px] text-faint">Admin Console</div>
            </div>
            <button className="ml-auto text-muted lg:hidden" onClick={() => setOpen(false)}><X size={20} /></button>
          </div>

          <nav className="flex-1 space-y-1 overflow-y-auto px-3 py-2">
            <p className="px-3 pb-1 pt-3 text-[10px] font-semibold uppercase tracking-wider text-faint">Main</p>
            {NAV.map((item) => {
              const active = path.startsWith(item.href);
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={() => setOpen(false)}
                  className={`group flex items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-medium transition ${
                    active ? "bg-brand text-white shadow-[0_8px_18px_rgba(226,35,26,.28)]" : "text-muted hover:bg-card2 hover:text-fg"
                  }`}
                >
                  <Icon size={18} className={active ? "text-white" : ""} />
                  <span>{item.label}</span>
                </Link>
              );
            })}
          </nav>

          <div className="border-t border-border p-3">
            <button
              onClick={() => router.push("/login")}
              className="flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-[13.5px] font-medium text-muted transition hover:bg-card2 hover:text-brand"
            >
              <LogOut size={18} /> Log out
            </button>
          </div>
        </div>
      </aside>

      {open && <div className="fixed inset-0 z-40 bg-black/40 lg:hidden" onClick={() => setOpen(false)} />}

      {/* Main */}
      <div className="flex min-w-0 flex-col">
        <header className="sticky top-0 z-30 flex items-center gap-4 border-b border-border bg-bg/80 px-4 py-3 backdrop-blur md:px-6">
          <button className="grid h-9 w-9 place-items-center rounded-lg border border-border text-muted lg:hidden" onClick={() => setOpen(true)}>
            <Menu size={18} />
          </button>
          <div className="min-w-0">
            <h1 className="truncate text-lg font-semibold tracking-tight">{titleFor(path)}</h1>
            <div className="flex items-center gap-1 text-[11px] text-faint">
              DAIRY DEMO <ChevronRight size={11} /> <span className="text-muted">{titleFor(path)}</span>
            </div>
          </div>
          <div className="ml-auto flex items-center gap-3">
            <div className="hidden items-center gap-2 rounded-lg border border-border bg-card px-3 py-2 text-muted md:flex">
              <Search size={16} />
              <input placeholder="Search…" className="w-40 bg-transparent text-[13px] text-fg outline-none placeholder:text-faint" />
              <kbd className="rounded border border-border px-1.5 text-[10px] text-faint">⌘K</kbd>
            </div>
            
            <button className="relative grid h-9 w-9 place-items-center rounded-lg border border-border bg-card text-muted hover:text-fg">
              <Bell size={17} />
              <span className="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-brand" />
            </button>
            <div className="flex items-center gap-2 pl-1">
              <div className="grid h-9 w-9 place-items-center rounded-lg bg-gradient-to-br from-zinc-700 to-zinc-900 text-xs font-bold text-white">RD</div>
              <div className="hidden leading-tight sm:block">
                <div className="text-[13px] font-semibold">Royal Dairy</div>
                <div className="text-[11px] text-faint">Super Admin</div>
              </div>
            </div>
          </div>
        </header>

        <main className="mx-auto w-full max-w-[1320px] flex-1 p-4 md:p-6">{children}</main>
      </div>
    </div>
  );
}
