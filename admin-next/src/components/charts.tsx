"use client";
import {
  Area, AreaChart, Bar, BarChart, CartesianGrid, Cell, Pie, PieChart,
  ResponsiveContainer, Tooltip, XAxis, YAxis,
} from "recharts";
import { salesTrend, categorySplit, topProducts } from "@/lib/data";
import { inr } from "@/lib/format";

const tip = {
  background: "var(--card)",
  border: "1px solid var(--border)",
  borderRadius: 8,
  fontSize: 12,
  color: "var(--fg)",
  boxShadow: "0 8px 24px rgba(15,23,42,.10)",
};

export function SalesArea() {
  return (
    <ResponsiveContainer width="100%" height={280}>
      <AreaChart data={salesTrend} margin={{ top: 8, right: 8, left: -8, bottom: 0 }}>
        <defs>
          <linearGradient id="g-sales" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="var(--brand)" stopOpacity={0.28} />
            <stop offset="100%" stopColor="var(--brand)" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="var(--border2)" vertical={false} />
        <XAxis dataKey="m" tick={{ fill: "var(--faint)", fontSize: 11 }} axisLine={false} tickLine={false} />
        <YAxis tick={{ fill: "var(--faint)", fontSize: 11 }} axisLine={false} tickLine={false}
          tickFormatter={(v) => "₹" + Math.round(Number(v) / 1000) + "k"} width={52} />
        <Tooltip contentStyle={tip} formatter={(v) => inr(Number(v))} />
        <Area type="monotone" dataKey="target" stroke="#c9cdd6" strokeWidth={2} strokeDasharray="5 5" fill="transparent" dot={false} />
        <Area type="monotone" dataKey="sales" stroke="var(--brand)" strokeWidth={3} fill="url(#g-sales)" dot={false} activeDot={{ r: 4 }} />
      </AreaChart>
    </ResponsiveContainer>
  );
}

export function CategoryDonut() {
  return (
    <ResponsiveContainer width="100%" height={220}>
      <PieChart>
        <Pie data={categorySplit} dataKey="value" nameKey="name" innerRadius={62} outerRadius={92} paddingAngle={2} stroke="none">
          {categorySplit.map((c) => <Cell key={c.name} fill={c.color} />)}
        </Pie>
        <Tooltip contentStyle={tip} formatter={(v, n) => [`${v}%`, n]} />
      </PieChart>
    </ResponsiveContainer>
  );
}

export function TopProductsBars() {
  const data = [...topProducts].reverse();
  return (
    <ResponsiveContainer width="100%" height={260}>
      <BarChart data={data} layout="vertical" margin={{ left: 8, right: 16, top: 4, bottom: 4 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="var(--border2)" horizontal={false} />
        <XAxis type="number" tick={{ fill: "var(--faint)", fontSize: 11 }} axisLine={false} tickLine={false} tickFormatter={(v) => Math.round(Number(v) / 1000) + "k"} />
        <YAxis type="category" dataKey="name" tick={{ fill: "var(--muted)", fontSize: 11 }} axisLine={false} tickLine={false} width={120}
          tickFormatter={(v) => { const s = String(v); return s.length > 18 ? s.slice(0, 17) + "…" : s; }} />
        <Tooltip contentStyle={tip} formatter={(v) => inr(Number(v))} cursor={{ fill: "var(--card2)" }} />
        <Bar dataKey="revenue" radius={[0, 6, 6, 0]} barSize={16} fill="var(--brand)" />
      </BarChart>
    </ResponsiveContainer>
  );
}
