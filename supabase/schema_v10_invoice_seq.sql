-- MY ORDER PRO — Invoice sequence v10 (2026-07-02). Run after v9.
-- GST Rule 46(b): invoice number must be a CONSECUTIVE serial, max 16 chars.
-- Timestamp-based numbers (17 chars, non-sequential) are non-compliant.
-- Per-user atomic counter -> the client formats e.g. 'INV/2526/0001' (<=16 chars).

CREATE TABLE IF NOT EXISTS counters (
    user_id UUID NOT NULL,
    key     TEXT NOT NULL,          -- e.g. 'sale_invoice'
    value   BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, key)
);
ALTER TABLE counters ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS counters_owner ON counters;
CREATE POLICY counters_owner ON counters FOR ALL TO authenticated
  USING (user_id = (SELECT auth.uid())) WITH CHECK (user_id = (SELECT auth.uid()));

-- Atomically bump and return the next number for the caller's counter.
CREATE OR REPLACE FUNCTION next_counter(p_key TEXT)
RETURNS BIGINT
LANGUAGE plpgsql SECURITY DEFINER SET search_path = ''
AS $$
DECLARE v_uid UUID := auth.uid(); v_val BIGINT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'not authenticated'; END IF;
  INSERT INTO public.counters (user_id, key, value)
  VALUES (v_uid, p_key, 1)
  ON CONFLICT (user_id, key) DO UPDATE SET value = public.counters.value + 1
  RETURNING value INTO v_val;
  RETURN v_val;
END; $$;
GRANT EXECUTE ON FUNCTION next_counter(TEXT) TO authenticated;
