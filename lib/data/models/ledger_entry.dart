/// A single line in the retailer's credit ledger (khata). [isDebit] true means
/// the retailer owes more (a purchase on credit); false means a repayment.
class LedgerEntry {
  final String id;
  final DateTime date;
  final String title;
  final double amount;
  final bool isDebit;

  const LedgerEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.amount,
    required this.isDebit,
  });
}
