export const inr = (n: number) => "₹" + Math.round(n).toLocaleString("en-IN");
export const inrFull = (n: number) =>
  "₹" + n.toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
