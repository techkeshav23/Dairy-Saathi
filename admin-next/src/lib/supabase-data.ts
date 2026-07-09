import { supabase } from "./supabase";
import { supabaseAdmin } from "./supabase-admin";
import type { Order, Product, Retailer, LedgerRow, Banner, Status } from "./data";
import {
  orders as mockOrders,
  products as mockProducts,
  retailers as mockRetailers,
  ledger as mockLedger,
  banners as mockBanners,
  salesTrend as mockSalesTrend,
  categorySplit as mockCategorySplit,
  topProducts as mockTopProducts,
} from "./data";

// This data layer maps the ACTUAL Supabase schema (see /supabase/*.sql) to the admin's
// view types. User-scoped tables (orders, app_users, ledger_entries) are owner-only under
// RLS, so they are read with the SERVER-ONLY service_role client (supabaseAdmin) which
// bypasses RLS. Public catalog (products, banners) works with the anon client too.
// Every fetcher falls back to the in-memory mock data when Supabase isn't configured.

// DB order status is lowercase ('placed'...); the admin UI uses Capitalized labels.
const STATUS_MAP: Record<string, Status> = {
  placed: "Placed",
  confirmed: "Confirmed",
  packed: "Packed",
  dispatched: "Dispatched",
  delivered: "Delivered",
  cancelled: "Cancelled",
};

/* eslint-disable @typescript-eslint/no-explicit-any */

function firstOf<T>(v: T | T[] | null | undefined): T | null {
  if (!v) return null;
  return Array.isArray(v) ? (v[0] ?? null) : v;
}

// ---------------------------------------------------------------- Products (catalog)
export async function getProducts(): Promise<Product[]> {
  const src = supabaseAdmin ?? supabase;
  if (!src) return mockProducts;
  try {
    const { data, error } = await src
      .from("products")
      .select("name, unit, mrp, moq, stock, categories(name), price_slabs(price_per_unit)");
    if (error) throw error;

    return (data as any[]).map((p) => {
      const cat = firstOf<{ name: string }>(p.categories)?.name;
      const prices = (p.price_slabs ?? [])
        .map((s: any) => Number(s.price_per_unit))
        .filter((n: number) => n > 0);
      const rate = prices.length ? Math.min(...prices) : Number(p.mrp);
      return {
        name: p.name || "",
        cat: cat || "Uncategorized",
        mrp: Number(p.mrp) || 0,
        rate: rate || 0,
        resale: Number(p.mrp) || 0,
        moq: p.moq || 1,
        stock: p.stock || 0,
        pack: p.unit || "1 unit",
      };
    });
  } catch (err) {
    console.error("getProducts:", err);
    return mockProducts;
  }
}

// ---------------------------------------------------------------- Orders
export async function getOrders(): Promise<Order[]> {
  if (!supabaseAdmin) return mockOrders;
  try {
    const { data, error } = await supabaseAdmin
      .from("orders")
      .select("id, status, total, payment_mode, payment_screenshot, payment_status, created_at, app_users(name, shop_name), order_items(id)")
      .order("created_at", { ascending: false });
    if (error) throw error;

    return (data as any[]).map((o) => {
      const u = firstOf<{ name: string; shop_name: string }>(o.app_users);
      const d = o.created_at ? new Date(o.created_at) : new Date();
      return {
        id: o.id,
        ref: "ORD-" + String(o.id).slice(0, 6).toUpperCase(),
        retailer: u?.shop_name || u?.name || "Retailer",
        owner: u?.name || "—",
        area: "—",
        date: d.toISOString().split("T")[0],
        time: d.toTimeString().slice(0, 5),
        items: o.order_items?.length ?? 0,
        amount: Number(o.total) || 0,
        payment: (o.payment_mode || "COD").toUpperCase(),
        payment_screenshot: o.payment_screenshot,
        payment_status: o.payment_status,
        status: STATUS_MAP[String(o.status).toLowerCase()] ?? "Placed",
      };
    });
  } catch (err) {
    console.error("getOrders:", err);
    return mockOrders;
  }
}

// ---------------------------------------------------------------- Retailers
export async function getRetailers(): Promise<Retailer[]> {
  if (!supabaseAdmin) return mockRetailers;
  try {
    const [uRes, lRes] = await Promise.all([
      supabaseAdmin.from("app_users").select("id, phone, name, shop_name, orders(id)").eq("role", "retailer"),
      supabaseAdmin.from("ledger_entries").select("user_id, type, amount"),
    ]);
    if (uRes.error) throw uRes.error;
    if (lRes.error) throw lRes.error;

    // outstanding per user = sum(debits) - sum(credits)
    const outMap = new Map<string, number>();
    for (const l of (lRes.data as any[]) ?? []) {
      const cur = outMap.get(l.user_id) ?? 0;
      outMap.set(l.user_id, cur + (l.type === "debit" ? Number(l.amount) : -Number(l.amount)));
    }

    return (uRes.data as any[]).map((u, i) => ({
      code: 1001 + i,
      name: u.shop_name || u.name || "Retailer",
      owner: u.name || "—",
      area: "—",
      phone: u.phone || "",
      limit: 50000,
      outstanding: Math.max(0, Math.round(outMap.get(u.id) ?? 0)),
      kyc: "Verified" as const,
      orders: u.orders?.length ?? 0,
    }));
  } catch (err) {
    console.error("getRetailers:", err);
    return mockRetailers;
  }
}

// ---------------------------------------------------------------- Ledger
export async function getLedger(): Promise<LedgerRow[]> {
  if (!supabaseAdmin) return mockLedger;
  try {
    const { data, error } = await supabaseAdmin
      .from("ledger_entries")
      .select("id, type, amount, note, created_at, app_users(name, shop_name)")
      .order("created_at", { ascending: false });
    if (error) throw error;

    return (data as any[]).map((l) => {
      const u = firstOf<{ name: string; shop_name: string }>(l.app_users);
      const isDebit = l.type === "debit";
      return {
        date: l.created_at ? new Date(l.created_at).toISOString().split("T")[0] : "",
        party: u?.shop_name || u?.name || l.note || "—",
        vch: "L-" + String(l.id),
        type: isDebit ? "Sale" : "Receipt",
        debit: isDebit ? Number(l.amount) : 0,
        credit: isDebit ? 0 : Number(l.amount),
      };
    });
  } catch (err) {
    console.error("getLedger:", err);
    return mockLedger;
  }
}

// ---------------------------------------------------------------- Banners (catalog)
export async function getBanners(): Promise<Banner[]> {
  const src = supabaseAdmin ?? supabase;
  if (!src) return mockBanners;
  try {
    const { data, error } = await src
      .from("banners")
      .select("title, subtitle, tag, image, accent_hex, active");
    if (error) throw error;

    return (data as any[]).map((b) => ({
      title: b.title || "",
      sub: b.subtitle || "",
      tag: b.tag || "",
      active: b.active !== false,
      color: b.accent_hex || "#e2231a",
    }));
  } catch (err) {
    console.error("getBanners:", err);
    return mockBanners;
  }
}

// ---------------------------------------------------------------- Dashboard KPIs
export type KpiTrend = { spark: number[]; delta: number; down: boolean } | null;
export type DashboardKpis = {
  revenue: number;
  orders: number;
  retailers: number;
  outstanding: number;
  trend: { revenue: KpiTrend; orders: KpiTrend; retailers: KpiTrend };
};

// Build an 8-month key list ending at the current month.
function last8MonthKeys(now: Date): string[] {
  const keys: string[] = [];
  for (let i = 7; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    keys.push(`${d.getFullYear()}-${d.getMonth()}`);
  }
  return keys;
}

// Turn a monthly series into a spark + last-vs-previous-month delta.
function seriesToTrend(series: number[]): KpiTrend {
  if (series.length < 2 || series.every((v) => v === 0)) return null;
  const last = series[series.length - 1];
  const prev = series[series.length - 2];
  let delta = 0;
  if (prev > 0) delta = ((last - prev) / prev) * 100;
  else if (last > 0) delta = 100;
  return { spark: series, delta: Math.round(delta * 10) / 10, down: delta < 0 };
}

export async function getDashboardKpis(): Promise<DashboardKpis> {
  const fallback: DashboardKpis = {
    revenue: 0, orders: 0, retailers: 0, outstanding: 0,
    trend: { revenue: null, orders: null, retailers: null },
  };
  if (!supabaseAdmin) return fallback;
  try {
    const [oRes, uRes, lRes] = await Promise.all([
      supabaseAdmin.from("orders").select("total, status, created_at"),
      supabaseAdmin.from("app_users").select("id, created_at").eq("role", "retailer"),
      supabaseAdmin.from("ledger_entries").select("type, amount"),
    ]);
    if (oRes.error) throw oRes.error;
    if (uRes.error) throw uRes.error;
    if (lRes.error) throw lRes.error;

    const od = (oRes.data as any[]) ?? [];
    const live = od.filter((o) => String(o.status).toLowerCase() !== "cancelled");
    const revenue = live.reduce((s, o) => s + (Number(o.total) || 0), 0);

    const outstanding = ((lRes.data as any[]) ?? []).reduce(
      (s, l) => s + (l.type === "debit" ? Number(l.amount) : -Number(l.amount)),
      0,
    );

    // ---- real monthly trend series
    const now = new Date();
    const keys = last8MonthKeys(now);
    const revBucket = new Map(keys.map((k) => [k, 0]));
    const ordBucket = new Map(keys.map((k) => [k, 0]));
    for (const o of live) {
      const d = o.created_at ? new Date(o.created_at) : null;
      if (!d) continue;
      const k = `${d.getFullYear()}-${d.getMonth()}`;
      if (revBucket.has(k)) {
        revBucket.set(k, (revBucket.get(k) || 0) + (Number(o.total) || 0));
        ordBucket.set(k, (ordBucket.get(k) || 0) + 1);
      }
    }
    // retailers: cumulative signup count at the end of each month
    const users = (uRes.data as any[]) ?? [];
    const retSeries = keys.map((k) => {
      const [y, m] = k.split("-").map(Number);
      const end = new Date(y, m + 1, 1).getTime();
      return users.filter((u) => u.created_at && new Date(u.created_at).getTime() < end).length;
    });

    return {
      revenue,
      orders: od.length,
      retailers: users.length,
      outstanding: Math.max(0, Math.round(outstanding)),
      trend: {
        revenue: seriesToTrend(keys.map((k) => revBucket.get(k) || 0)),
        orders: seriesToTrend(keys.map((k) => ordBucket.get(k) || 0)),
        retailers: seriesToTrend(retSeries),
      },
    };
  } catch (err) {
    console.error("getDashboardKpis:", err);
    return fallback;
  }
}

// ---------------------------------------------------------------- Sales trend (chart)
export async function getSalesTrend(): Promise<typeof mockSalesTrend> {
  if (!supabaseAdmin) return [];
  try {
    const { data, error } = await supabaseAdmin.from("orders").select("total, status, created_at");
    if (error) throw error;
    const rows = ((data as any[]) ?? []).filter((o) => String(o.status).toLowerCase() !== "cancelled");
    if (rows.length === 0) return [];

    const now = new Date();
    const months: { key: string; m: string }[] = [];
    const bucket = new Map<string, number>();
    for (let i = 7; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      const key = `${d.getFullYear()}-${d.getMonth()}`;
      bucket.set(key, 0);
      months.push({ key, m: d.toLocaleString("en-US", { month: "short" }) });
    }
    for (const o of rows) {
      const d = new Date(o.created_at);
      const key = `${d.getFullYear()}-${d.getMonth()}`;
      if (bucket.has(key)) bucket.set(key, (bucket.get(key) || 0) + (Number(o.total) || 0));
    }
    const vals = months.map((mm) => bucket.get(mm.key) || 0);
    const target = Math.round(Math.max(...vals, 1) * 0.85);
    return months.map((mm, i) => ({ m: mm.m, sales: vals[i], target }));
  } catch (err) {
    console.error("getSalesTrend:", err);
    return [];
  }
}

// ---------------------------------------------------------------- Category split (chart)
export async function getCategorySplit(): Promise<typeof mockCategorySplit> {
  if (!supabaseAdmin) return [];
  try {
    const { data, error } = await supabaseAdmin.from("order_items").select("qty, unit_price, products(categories(name))");
    if (error) throw error;
    const map = new Map<string, number>();
    for (const it of (data as any[]) ?? []) {
      const catObj = it.products?.categories;
      const name = (Array.isArray(catObj) ? catObj[0]?.name : catObj?.name) || "Other";
      map.set(name, (map.get(name) || 0) + Number(it.qty) * Number(it.unit_price));
    }
    if (map.size === 0) return [];
    const total = [...map.values()].reduce((a, b) => a + b, 0) || 1;
    const colors = ["#2b50d6", "#0f9d63", "#c07708", "#586172", "#2b6cf0", "#dc4249"];
    return [...map.entries()]
      .sort((a, b) => b[1] - a[1])
      .slice(0, 6)
      .map(([name, val], i) => ({ name, value: Math.round((val / total) * 100), color: colors[i % colors.length] }));
  } catch (err) {
    console.error("getCategorySplit:", err);
    return [];
  }
}

// ---------------------------------------------------------------- Top products (chart)
export async function getTopProducts(): Promise<typeof mockTopProducts> {
  if (!supabaseAdmin) return [];
  try {
    const { data, error } = await supabaseAdmin.from("order_items").select("qty, unit_price, products(name)");
    if (error) throw error;
    const map = new Map<string, { qty: number; revenue: number }>();
    for (const it of (data as any[]) ?? []) {
      const name = (Array.isArray(it.products) ? it.products[0]?.name : it.products?.name) || "Unknown";
      const cur = map.get(name) || { qty: 0, revenue: 0 };
      map.set(name, { qty: cur.qty + Number(it.qty), revenue: cur.revenue + Number(it.qty) * Number(it.unit_price) });
    }
    if (map.size === 0) return [];
    return [...map.entries()]
      .sort((a, b) => b[1].revenue - a[1].revenue)
      .slice(0, 5)
      .map(([name, v]) => ({ name, qty: v.qty, revenue: Math.round(v.revenue) }));
  } catch (err) {
    console.error("getTopProducts:", err);
    return [];
  }
}
