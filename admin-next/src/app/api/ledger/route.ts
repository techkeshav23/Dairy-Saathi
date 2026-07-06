import { NextResponse } from "next/server";
import { supabaseAdmin } from "@/lib/supabase-admin";

export async function POST(req: Request) {
  try {
    const { user_id, amount, type, note } = await req.json();

    if (!user_id || !amount || !type || !note) {
      return NextResponse.json({ error: "Missing required fields" }, { status: 400 });
    }

    const amt = Number(amount);
    if (isNaN(amt) || amt <= 0) {
      return NextResponse.json({ error: "Invalid amount" }, { status: 400 });
    }

    // 1. Insert ledger entry
    const { error: ledgerError } = await supabaseAdmin.from("ledger_entries").insert({
      user_id,
      amount: amt,
      type,
      note,
    });

    if (ledgerError) throw ledgerError;

    // 2. Update outstanding balance
    // First fetch current balance
    const { data: user, error: userError } = await supabaseAdmin
      .from("app_users")
      .select("outstanding_balance")
      .eq("id", user_id)
      .single();

    if (userError) throw userError;

    const currentBalance = Number(user.outstanding_balance) || 0;
    const newBalance = type === "debit" ? currentBalance + amt : Math.max(0, currentBalance - amt);

    const { error: updateError } = await supabaseAdmin
      .from("app_users")
      .update({ outstanding_balance: newBalance })
      .eq("id", user_id);

    if (updateError) throw updateError;

    return NextResponse.json({ ok: true });
  } catch (err: any) {
    console.error("Manual ledger entry error:", err);
    return NextResponse.json({ error: err.message }, { status: 500 });
  }
}
