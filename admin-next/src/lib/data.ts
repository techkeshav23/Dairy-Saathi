/* MY ORDER PRO — admin fallback data (in-memory; swap for a real API later). */

export type Status =
  | "Delivered" | "Dispatched" | "Packed" | "Confirmed" | "Placed" | "Cancelled";

export type Order = {
  id: string; ref: string; retailer: string; owner: string; area: string;
  date: string; time: string; items: number; amount: number;
  payment: string; status: Status;
  payment_screenshot?: string | null;
  payment_status?: string | null;
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
  { name: "Groceries & Staples", value: 34, color: "#2b50d6" },
  { name: "Beverages", value: 22, color: "#0f9d63" },
  { name: "Snacks & Namkeen", value: 18, color: "#c07708" },
  { name: "Personal Care", value: 14, color: "#586172" },
  { name: "Home Care", value: 12, color: "#2b6cf0" },
];

export const topProducts = [
  { name: "India Gate Basmati Rice", qty: 4820, revenue: 2294320 },
  { name: "Aashirvaad Atta 10kg", qty: 3110, revenue: 1204990 },
  { name: "Fortune Sunflower Oil 1L", qty: 2680, revenue: 911200 },
  { name: "Tata Tea Premium 1kg", qty: 940, revenue: 664000 },
  { name: "Lay's Classic Salted", qty: 1210, revenue: 423500 },
];

const retailerNames: [string, string, string][] = [
  ["Royal Provision Store", "Mohd Janish", "Chandpur"],
  ["Sharma General Store", "Rakesh Sharma", "Bijnor"],
  ["Gupta Kirana", "Sunil Gupta", "Najibabad"],
  ["New Bharat Provision", "Imran Khan", "Dhampur"],
  ["Annapurna Stores", "Meena Devi", "Nagina"],
  ["Verma Trading Co.", "Anil Verma", "Bijnor"],
  ["Shree Balaji Mart", "Praveen Kumar", "Kiratpur"],
  ["Krishna Kirana Store", "Gopal Yadav", "Chandpur"],
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
  { name: "India Gate Basmati Rice 5kg", cat: "Groceries & Staples", mrp: 2200, rate: 1720, resale: 1980, moq: 2, stock: 140, pack: "1 BAG" },
  { name: "Aashirvaad Atta 10kg", cat: "Groceries & Staples", mrp: 520, rate: 410, resale: 470, moq: 4, stock: 210, pack: "1 BAG" },
  { name: "Fortune Sunflower Oil 1L", cat: "Groceries & Staples", mrp: 190, rate: 150, resale: 172, moq: 6, stock: 0, pack: "1 CRT = 12 EA" },
  { name: "Tata Salt 1kg", cat: "Groceries & Staples", mrp: 28, rate: 22, resale: 25, moq: 24, stock: 480, pack: "1 CRT = 24 EA" },
  { name: "Tata Tea Premium 1kg", cat: "Beverages", mrp: 540, rate: 440, resale: 495, moq: 4, stock: 70, pack: "1 CTN = 10 EA" },
  { name: "Coca-Cola 750ml", cat: "Beverages", mrp: 40, rate: 31, resale: 36, moq: 12, stock: 320, pack: "1 CRT = 24 EA" },
  { name: "Lay's Classic Salted", cat: "Snacks & Namkeen", mrp: 20, rate: 15, resale: 18, moq: 20, stock: 150, pack: "1 CRT = 48 EA" },
  { name: "Haldiram Aloo Bhujia 400g", cat: "Snacks & Namkeen", mrp: 95, rate: 76, resale: 86, moq: 10, stock: 22, pack: "1 CRT = 24 EA" },
  { name: "Parle-G Biscuits 800g", cat: "Packaged Food", mrp: 80, rate: 64, resale: 72, moq: 12, stock: 410, pack: "1 CRT = 24 EA" },
  { name: "Maggi Noodles 12-pack", cat: "Packaged Food", mrp: 168, rate: 138, resale: 155, moq: 6, stock: 96, pack: "1 CTN = 8 EA" },
  { name: "Colgate MaxFresh 150g", cat: "Personal Care", mrp: 99, rate: 78, resale: 90, moq: 12, stock: 88, pack: "1 CRT = 36 EA" },
  { name: "Lifebuoy Soap 4x125g", cat: "Personal Care", mrp: 108, rate: 86, resale: 98, moq: 8, stock: 12, pack: "1 CRT = 24 EA" },
  { name: "Surf Excel 1kg", cat: "Home Care", mrp: 140, rate: 112, resale: 128, moq: 6, stock: 64, pack: "1 CRT = 16 EA" },
  { name: "Amul Butter 500g", cat: "Dairy & Bakery", mrp: 290, rate: 250, resale: 272, moq: 4, stock: 54, pack: "1 CRT = 20 EA" },
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
  { date: "19-Jun-2026", retailer: "Royal Provision Store", amount: 15000, mode: "Cash", status: "Approved" },
  { date: "18-Jun-2026", retailer: "Gupta Kirana", amount: 25000, mode: "UPI", status: "Declined" },
];

export const banners: Banner[] = [
  { title: "Monsoon Bulk Sale", sub: "Up to 22% off on staples & oils", tag: "MEGA DEAL", active: true, color: "#e2231a" },
  { title: "Free Delivery", sub: "On every order above ₹5,000", tag: "NO CHARGE", active: true, color: "#f5a623" },
  { title: "Pay Later on Khata", sub: "15-day credit for trusted retailers", tag: "CREDIT", active: false, color: "#16a34a" },
];

export const purchases: Purchase[] = [
  { date: "21-Jun-2026", supplier: "Aggarwal Distributors", billNo: "2606-PUR-8841", items: 9, amount: 342850, file: "invoice_8841.pdf" },
  { date: "18-Jun-2026", supplier: "Ananda Foods Depot", billNo: "2606-PUR-8790", items: 6, amount: 184220, file: "depot_jun18.pdf" },
  { date: "14-Jun-2026", supplier: "Bijnor Cold Storage", billNo: "2606-PUR-8702", items: 11, amount: 271500, file: "cold_storage.pdf" },
];

export const stockStatus = (n: number) => (n === 0 ? "Out of Stock" : n < 40 ? "Low" : "In Stock");
