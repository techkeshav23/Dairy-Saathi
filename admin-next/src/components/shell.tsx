"use client";
import { ReactNode, useEffect, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase-browser";
import {
  LayoutDashboard, ShoppingCart, Package, Tags, Truck, Store, BookOpen,
  BarChart3, Image as ImageIcon, Settings, Search, Bell, Menu, X, LogOut, ChevronRight,
} from "lucide-react";

const SECTIONS = [
  {
    label: "Overview",
    items: [{ href: "/dashboard", label: "Dashboard", icon: LayoutDashboard }],
  },
  {
    label: "Operations",
    items: [
      { href: "/orders", label: "Orders", icon: ShoppingCart },
      { href: "/products", label: "Products", icon: Package },
      { href: "/categories", label: "Categories", icon: Tags },
      { href: "/purchase", label: "Bill Import", icon: Truck },
      { href: "/retailers", label: "Retailers", icon: Store },
    ],
  },
  {
    label: "Finance",
    items: [
      { href: "/ledger", label: "Ledger & Payments", icon: BookOpen },
      { href: "/reports", label: "Reports", icon: BarChart3 },
    ],
  },
  {
    label: "Workspace",
    items: [
      { href: "/banners", label: "Banners", icon: ImageIcon },
      { href: "/settings", label: "Settings", icon: Settings },
    ],
  },
];

const ALL = SECTIONS.flatMap((s) => s.items);
function titleFor(path: string) {
  const n = ALL.find((x) => path.startsWith(x.href));
  return n ? n.label : "Dashboard";
}

export function Shell({ children }: { children: ReactNode }) {
  const path = usePathname();
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [email, setEmail] = useState("");

  useEffect(() => {
    const supabase = createClient();
    supabase.auth.getUser().then(({ data }) => setEmail(data.user?.email ?? ""));
  }, []);

  const signOut = async () => {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
    router.refresh();
  };

  const initials = email ? email.slice(0, 2).toUpperCase() : "MO";

  return (
    <div className="min-h-screen lg:grid lg:grid-cols-[248px_1fr]">
      {/* Sidebar */}
      <aside
        className={`fixed inset-y-0 left-0 z-50 w-64 bg-sidebar text-sidebar-fg transition-transform lg:static lg:w-auto lg:translate-x-0 ${
          open ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        <div className="flex h-full flex-col">
          {/* Brand */}
          <div className="flex items-center gap-3 px-5 py-[18px]">
            <Image src="/logo.jpeg" alt="MY ORDER PRO" width={36} height={36} className="rounded-[9px]" priority />
            <div className="leading-tight">
              <div className="text-[13.5px] font-semibold tracking-tight text-white">MY ORDER PRO</div>
              <div className="text-[11px] text-sidebar-muted">Distribution Console</div>
            </div>
            <button className="ml-auto text-sidebar-muted lg:hidden" onClick={() => setOpen(false)}><X size={20} /></button>
          </div>

          <div className="mx-4 h-px bg-white/[0.06]" />

          {/* Nav */}
          <nav className="flex-1 overflow-y-auto px-3 py-3">
            {SECTIONS.map((section) => (
              <div key={section.label} className="mb-4">
                <p className="px-3 pb-1.5 text-[10.5px] font-semibold uppercase tracking-[0.08em] text-sidebar-muted/80">{section.label}</p>
                <div className="space-y-0.5">
                  {section.items.map((item) => {
                    const active = path.startsWith(item.href);
                    const Icon = item.icon;
                    return (
                      <Link
                        key={item.href}
                        href={item.href}
                        onClick={() => setOpen(false)}
                        className={`group relative flex items-center gap-3 rounded-[8px] px-3 py-2 text-[13px] font-medium transition-colors ${
                          active
                            ? "bg-sidebar-active text-white"
                            : "text-sidebar-fg/85 hover:bg-sidebar-hover hover:text-white"
                        }`}
                      >
                        {active && <span className="absolute left-0 top-1/2 h-4 w-[3px] -translate-y-1/2 rounded-r bg-brand" />}
                        <Icon size={17} className={active ? "text-white" : "text-sidebar-muted group-hover:text-sidebar-fg"} strokeWidth={2} />
                        <span className="truncate">{item.label}</span>
                      </Link>
                    );
                  })}
                </div>
              </div>
            ))}
          </nav>

          {/* Footer */}
          <div className="border-t border-white/[0.06] p-3">
            <button
              onClick={signOut}
              className="flex w-full items-center gap-3 rounded-[8px] px-3 py-2 text-[13px] font-medium text-sidebar-muted transition-colors hover:bg-sidebar-hover hover:text-white"
            >
              <LogOut size={17} /> Sign out
            </button>
          </div>
        </div>
      </aside>

      {open && <div className="fixed inset-0 z-40 bg-black/50 lg:hidden" onClick={() => setOpen(false)} />}

      {/* Main */}
      <div className="flex min-w-0 flex-col">
        <header className="sticky top-0 z-30 flex items-center gap-4 border-b border-border bg-card/85 px-4 py-3 backdrop-blur-md md:px-6">
          <button className="grid h-9 w-9 place-items-center rounded-lg border border-border text-muted lg:hidden" onClick={() => setOpen(true)}>
            <Menu size={18} />
          </button>
          <div className="min-w-0">
            <div className="flex items-center gap-1.5 text-[11px] text-faint">
              MY ORDER PRO <ChevronRight size={11} /> <span className="font-medium text-muted">{titleFor(path)}</span>
            </div>
            <h1 className="truncate text-[17px] font-semibold tracking-tight text-fg">{titleFor(path)}</h1>
          </div>
          <div className="ml-auto flex items-center gap-2.5">
            <div className="hidden items-center gap-2 rounded-lg border border-border bg-card px-3 py-2 text-muted transition-colors focus-within:border-brand md:flex">
              <Search size={15} />
              <input placeholder="Search…" className="w-40 bg-transparent text-[13px] text-fg outline-none placeholder:text-faint" />
              <kbd className="rounded border border-border bg-card2 px-1.5 py-0.5 text-[10px] font-medium text-faint">⌘K</kbd>
            </div>
            <button className="relative grid h-9 w-9 place-items-center rounded-lg border border-border bg-card text-muted transition-colors hover:text-fg">
              <Bell size={16} />
              <span className="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-brand ring-2 ring-card" />
            </button>
            <div className="mx-0.5 hidden h-6 w-px bg-border sm:block" />
            <div className="flex items-center gap-2.5">
              <div className="grid h-9 w-9 place-items-center rounded-full bg-fg text-[11px] font-semibold tracking-wide text-white">{initials}</div>
              <div className="hidden leading-tight sm:block">
                <div className="max-w-[150px] truncate text-[13px] font-semibold text-fg">{email || "MY ORDER PRO"}</div>
                <div className="text-[11px] text-faint">Administrator</div>
              </div>
            </div>
          </div>
        </header>

        <main className="mx-auto w-full max-w-[1360px] flex-1 p-4 md:p-6 lg:p-7">{children}</main>
      </div>
    </div>
  );
}
