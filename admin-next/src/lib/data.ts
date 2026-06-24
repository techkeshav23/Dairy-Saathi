/* DAIRY DEMO — admin demo data (in-memory; swap for a real API later). */

export type Status =
  | "Delivered" | "Dispatched" | "Packed" | "Confirmed" | "Placed" | "Cancelled";

export type Order = {
  id: string; ref: string; retailer: string; owner: string; area: string;
  date: string; time: string; items: number; amount: number;
  payment: "COD" | "Online" | "Khata"; status: Status;
};

export type Product = {
  name: string; cat: string; mrp: number; rate: number; resale: number;
  moq: number; stock: number; pack: string;
};

export type Retailer = {
  code: number; name: string; owner: string; area: string; phone: string;
  limit: number; outstanding: number; kyc: "Verified" | "Pending" | "Rejected"; orders: number;
};

export type LedgerRow = { date: string; party: string; vch: string; type: "Sale" | "Receipt"; debit: number; credit: number };
export type Recharge = { date: string; retailer: string; amount: number; mode: string; status: "Pending" | "Approved" | "Declined" };
export type Banner = { title: string; sub: string; tag: string; active: boolean; color: string };
export type Purchase = { date: string; supplier: string; billNo: string; items: number; amount: number; file: string };

export const kpis = [
  { key: "revenue", label: "Total Revenue", value: 4842375, prefix: "₹", delta: 12.4, spark: [22, 28, 25, 33, 30, 38, 36, 44, 41, 48, 46, 52] },
  { key: "orders", label: "Total Orders", value: 1284, prefix: "", delta: 8.1, spark: [12, 14, 13, 16, 18, 17, 20, 19, 22, 24, 23, 26] },
  { key: "retailers", label: "Active Retailers", value: 318, prefix: "", delta: 3.6, spark: [8, 9, 9, 10, 11, 12, 12, 13, 14, 14, 15, 16] },
  { key: "outstanding", label: "Outstanding (Khata)", value: 874447, prefix: "₹", delta: -5.2, down: true, spark: [40, 38, 39, 36, 34, 33, 31, 30, 28, 27, 26, 24] },
];

export const salesTrend = ["Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun"].map((m, i) => ({
  m,
  sales: [312, 348, 326, 402, 388, 455, 432, 478, 461, 512, 498, 560][i] * 1000,
  target: [320, 340, 360, 380, 400, 420, 440, 460, 480, 500, 520, 540][i] * 1000,
}));

export const categorySplit = [
  { name: "Milk", value: 38, color: "#e2231a" },
  { name: "Curd / Dahi", value: 24, color: "#f5a623" },
  { name: "Paneer", value: 16, color: "#16a34a" },
  { name: "Ghee & Butter", value: 14, color: "#2563eb" },
  { name: "Beverages", value: 8, color: "#7c3aed" },
];

export const topProducts = [
  { name: "Cow Milk Value Pack 320ml", qty: 4820, revenue: 2294320 },
  { name: "Standard Milk 500ml", qty: 3110, revenue: 2204990 },
  { name: "Ananda Dahi Cup 400g", qty: 2680, revenue: 911200 },
  { name: "Pure Ghee 1L Tin", qty: 940, revenue: 1664000 },
  { name: "Fresh Paneer 1kg", qty: 1210, revenue: 423500 },
];

const retailerNames: [string, string, string][] = [
  ["Royal Dairy", "Mohd Janish", "Chandpur"],
  ["Sharma General Store", "Rakesh Sharma", "Bijnor"],
  ["Gupta Kirana", "Sunil Gupta", "Najibabad"],
  ["New Bharat Provision", "Imran Khan", "Dhampur"],
  ["Annapurna Stores", "Meena Devi", "Nagina"],
  ["Verma Trading Co.", "Anil Verma", "Bijnor"],
  ["Shree Balaji Mart", "Praveen Kumar", "Kiratpur"],
  ["Krishna Dairy Point", "Gopal Yadav", "Chandpur"],
  ["Maa Vaishno Store", "Deepak Saini", "Haldaur"],
  ["City Super Bazaar", "Faisal Ali", "Bijnor"],
];

const statuses: Status[] = ["Delivered", "Dispatched", "Packed", "Confirmed", "Placed", "Cancelled"];

export const orders: Order[] = Array.from({ length: 24 }).map((_, i) => {
  const r = retailerNames[i % retailerNames.length];
  return {
    id: "SOD-" + (1400 - i),
    ref: "#2606" + (21 - (i % 20)) + "-SOD-" + (1400 - i),
    retailer: r[0], owner: r[1], area: r[2],
    date: String(22 - (i % 22)).padStart(2, "0") + "-Jun-2026",
    time: ["09:12", "11:45", "13:30", "16:53", "18:07"][i % 5],
    items: 3 + (i % 9),
    amount: 8000 + ((i * 5731) % 92000),
    payment: (["COD", "Online", "Khata"] as const)[i % 3],
    status: statuses[i % statuses.length],
  };
});

export const products: Product[] = [
  { name: "Cow Milk Value Pack 320ml", cat: "Milk", mrp: 560, rate: 476, resale: 504, moq: 2, stock: 420, pack: "1 CRT = 28 EA" },
  { name: "Ananda Yo Kids Milk 380ml", cat: "Milk", mrp: 560, rate: 476, resale: 504, moq: 2, stock: 210, pack: "1 CRT = 28 EA" },
  { name: "Cow Milk Junior Pack 220ml", cat: "Milk", mrp: 400, rate: 320, resale: 340, moq: 2, stock: 36, pack: "1 CRT = 40 EA" },
  { name: "Standard Milk 500ml", cat: "Milk", mrp: 858, rate: 709, resale: 722, moq: 1, stock: 180, pack: "1 CRT = 20 EA" },
  { name: "Toned Milk 1L Pouch", cat: "Milk", mrp: 660, rate: 560, resale: 600, moq: 4, stock: 0, pack: "1 CRT = 12 EA" },
  { name: "Ananda Dahi Cup 400g", cat: "Curd / Dahi", mrp: 480, rate: 360, resale: 408, moq: 2, stock: 96, pack: "1 CRT = 24 EA" },
  { name: "Dahi Matka 1kg", cat: "Curd / Dahi", mrp: 1100, rate: 880, resale: 980, moq: 1, stock: 54, pack: "1 CRT = 8 EA" },
  { name: "Chaach 200ml", cat: "Beverages", mrp: 240, rate: 180, resale: 204, moq: 5, stock: 320, pack: "1 CRT = 30 EA" },
  { name: "Lassi 200ml", cat: "Beverages", mrp: 360, rate: 280, resale: 312, moq: 5, stock: 22, pack: "1 CRT = 30 EA" },
  { name: "Fresh Paneer 1kg", cat: "Paneer", mrp: 420, rate: 350, resale: 380, moq: 2, stock: 140, pack: "1 EA" },
  { name: "Malai Paneer 200g", cat: "Paneer", mrp: 96, rate: 78, resale: 86, moq: 10, stock: 410, pack: "1 CRT = 40 EA" },
  { name: "Pure Ghee 1L Tin", cat: "Ghee & Butter", mrp: 1850, rate: 1620, resale: 1720, moq: 2, stock: 88, pack: "1 CTN = 12 EA" },
  { name: "Table Butter 500g", cat: "Ghee & Butter", mrp: 305, rate: 256, resale: 280, moq: 4, stock: 12, pack: "1 CRT = 20 EA" },
  { name: "Skimmed Milk Powder 1kg", cat: "Milk", mrp: 480, rate: 410, resale: 445, moq: 2, stock: 64, pack: "1 EA" },
];

export const retailers: Retailer[] = retailerNames.map((r, i) => ({
  code: 13710 + i * 7,
  name: r[0], owner: r[1], area: r[2],
  phone: "+91-82188" + (20000 + i * 137),
  limit: [50000, 100000, 75000, 60000, 40000, 120000, 80000, 45000, 55000, 200000][i],
  outstanding: [10, 12480, 0, 8740, 0, 43860, 9320, 0, 6200, 84217][i],
  kyc: (["Verified", "Verified", "Pending", "Verified", "Rejected", "Verified", "Pending", "Verified", "Verified", "Verified"] as const)[i],
  orders: 18 + ((i * 11) % 60),
}));

export const ledger: LedgerRow[] = orders.slice(0, 14).flatMap((o, i) => {
  const rows: LedgerRow[] = [{ date: o.date, party: o.retailer, vch: "61311" + (29438 - i * 415), type: "Sale", debit: o.amount, credit: 0 }];
  if (i % 2 === 1) rows.push({ date: o.date, party: o.retailer, vch: "R-2606" + (21 - i) + "-" + (1733 - i), type: "Receipt", debit: 0, credit: o.amount });
  return rows;
});

export const recharges: Recharge[] = [
  { date: "21-Jun-2026", retailer: "Verma Trading Co.", amount: 50000, mode: "NEFT", status: "Pending" },
  { date: "20-Jun-2026", retailer: "City Super Bazaar", amount: 100000, mode: "UPI", status: "Pending" },
  { date: "19-Jun-2026", retailer: "Royal Dairy", amount: 15000, mode: "Cash", status: "Approved" },
  { date: "18-Jun-2026", retailer: "Gupta Kirana", amount: 25000, mode: "UPI", status: "Declined" },
];

export const banners: Banner[] = [
  { title: "Monsoon Bulk Sale", sub: "Up to 22% off on staples & oils", tag: "MEGA DEAL", active: true, color: "#e2231a" },
  { title: "Free Delivery", sub: "On every order above ₹5,000", tag: "NO CHARGE", active: true, color: "#f5a623" },
  { title: "Pay Later on Khata", sub: "15-day credit for trusted retailers", tag: "CREDIT", active: false, color: "#16a34a" },
];

export const purchases: Purchase[] = [
  { date: "21-Jun-2026", supplier: "Dairy India Pvt Ltd", billNo: "2606-PUR-8841", items: 9, amount: 342850, file: "invoice_8841.pdf" },
  { date: "18-Jun-2026", supplier: "Ananda Foods Depot", billNo: "2606-PUR-8790", items: 6, amount: 184220, file: "depot_jun18.pdf" },
  { date: "14-Jun-2026", supplier: "Bijnor Cold Storage", billNo: "2606-PUR-8702", items: 11, amount: 271500, file: "cold_storage.pdf" },
];

export const stockStatus = (n: number) => (n === 0 ? "Out of Stock" : n < 40 ? "Low" : "In Stock");
