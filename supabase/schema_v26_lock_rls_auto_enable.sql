-- MY ORDER PRO — Schema v26
-- Lock the internal rls_auto_enable() utility. It is a SECURITY DEFINER helper that was
-- callable by anon/authenticated via the REST RPC endpoint — no app flow needs it, so
-- revoke EXECUTE from everyone except service_role/owner.
REVOKE EXECUTE ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;
