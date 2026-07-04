import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

class AnalyticsService {
  Future<Map<String, double>> getSummary() async {
    final Map<String, double> defaultResult = {
      'totalSales': 0.0,
      'totalPurchases': 0.0,
      'paymentsIn': 0.0,
      'paymentsOut': 0.0,
      'totalExpenses': 0.0,
      'totalOutstanding': 0.0,
      'orderCount': 0.0,
    };

    if (!SupabaseConfig.useSupabase) {
      return defaultResult;
    }

    try {
      final supabase = Supabase.instance.client;

      final salesRes = await supabase.from('sale_invoices').select('total');
      double totalSales = 0.0;
      for (final row in salesRes) {
        totalSales += (row['total'] as num?)?.toDouble() ?? 0.0;
      }

      final purchasesRes = await supabase.from('purchases').select('total');
      double totalPurchases = 0.0;
      for (final row in purchasesRes) {
        totalPurchases += (row['total'] as num?)?.toDouble() ?? 0.0;
      }

      final paymentsRes = await supabase.from('payments').select('amount, direction');
      double paymentsIn = 0.0;
      double paymentsOut = 0.0;
      for (final row in paymentsRes) {
        final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
        if (row['direction'] == 'in') {
          paymentsIn += amount;
        } else if (row['direction'] == 'out') {
          paymentsOut += amount;
        }
      }

      final expensesRes = await supabase.from('expenses').select('amount');
      double totalExpenses = 0.0;
      for (final row in expensesRes) {
        totalExpenses += (row['amount'] as num?)?.toDouble() ?? 0.0;
      }

      final partiesRes = await supabase.from('parties').select('balance');
      double totalOutstanding = 0.0;
      for (final row in partiesRes) {
        totalOutstanding += (row['balance'] as num?)?.toDouble() ?? 0.0;
      }

      final ordersRes = await supabase.from('orders').select('id');
      double orderCount = ordersRes.length.toDouble();

      return {
        'totalSales': totalSales,
        'totalPurchases': totalPurchases,
        'paymentsIn': paymentsIn,
        'paymentsOut': paymentsOut,
        'totalExpenses': totalExpenses,
        'totalOutstanding': totalOutstanding,
        'orderCount': orderCount,
      };
    } catch (e) {
      return defaultResult;
    }
  }
}