-- schema_v20_stock_ledger_triggers.sql
-- Adds automatic stock deduction when an order is marked as confirmed.
-- Also manages adding stock back if the order is cancelled.
--
-- Run in the Supabase SQL Editor (Role: postgres). Safe to re-run.

CREATE OR REPLACE FUNCTION update_stock_on_order_confirm()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- When order is confirmed for the first time
  IF NEW.status = 'confirmed' AND OLD.status != 'confirmed' THEN
    UPDATE products p
    SET stock = p.stock - oi.qty
    FROM order_items oi
    WHERE p.id = oi.product_id AND oi.order_id = NEW.id;
  END IF;

  -- If a confirmed/dispatched order is cancelled, add stock back
  IF NEW.status = 'cancelled' AND OLD.status IN ('confirmed', 'packed', 'dispatched') THEN
    UPDATE products p
    SET stock = p.stock + oi.qty
    FROM order_items oi
    WHERE p.id = oi.product_id AND oi.order_id = NEW.id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_stock_update ON orders;
CREATE TRIGGER trg_stock_update
AFTER UPDATE OF status ON orders
FOR EACH ROW EXECUTE FUNCTION update_stock_on_order_confirm();
