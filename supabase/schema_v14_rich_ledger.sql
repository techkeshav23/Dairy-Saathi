-- schema_v14_rich_ledger.sql
-- Fills the Statement / Khata screen with a rich, realistic running ledger for EVERY
-- logged-in user, so the redesigned statement looks full (like a real app) instead of
-- blank. Idempotent: it deletes previous demo ledger rows first, then re-inserts a fresh
-- set — so you can safely re-run it any time and it always ends at the same state.
--
-- Why per-user: ledger_entries is owner-only under RLS (user_id = auth.uid()), so data
-- MUST be tagged with the viewing user's id. This seeds ALL current auth users, so whoever
-- is logged in on the app sees a populated statement.
--
-- Run in the Supabase SQL Editor (Role: postgres). Safe to re-run.

DO $$
DECLARE
  v_uid  UUID;
  i      INT;
  v_amt  NUMERIC;
  v_date TIMESTAMPTZ;
BEGIN
  FOR v_uid IN SELECT id FROM auth.users LOOP

    -- Clear previous demo ledger rows for this user (idempotent reset).
    DELETE FROM public.ledger_entries
     WHERE user_id = v_uid
       AND ( note LIKE 'Purchase%' OR note LIKE 'Payment%' OR note LIKE 'Order SA%'
          OR note LIKE 'Sale%'     OR note = 'DEMO_SEED' OR note LIKE 'DEMO_SEED_%' );

    -- 14 fortnights of activity: each has a Purchase (debit) and a Payment Out (credit).
    FOR i IN 0..13 LOOP
      v_date := (DATE '2026-07-03' - (i * 5))::timestamptz;
      v_amt  := 8000 + ((i * 6131) % 42000);   -- varied, realistic amounts

      -- Purchase — you bought stock on khata (debit: increases what you owe)
      INSERT INTO public.ledger_entries (user_id, type, amount, note, created_at)
      VALUES (v_uid, 'debit', v_amt, 'Purchase — Bill ' || (61311000 + i * 373), v_date);

      -- Payment Out — you paid the wholesaler (credit: reduces what you owe)
      INSERT INTO public.ledger_entries (user_id, type, amount, note, created_at)
      VALUES (v_uid, 'credit', round(v_amt * 0.62), 'Payment Out', v_date + interval '2 days');
    END LOOP;

  END LOOP;
END $$;

-- Verify (as the logged-in user, via the app): the Statement should now show ~28 rows
-- with a running balance, red debit lane and green credit lane.
