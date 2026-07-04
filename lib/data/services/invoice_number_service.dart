import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';

class InvoiceNumberService {
  Future<String> nextNumber({
    required String key,
    required String prefix,
  }) async {
    String result;

    try {
      if (!SupabaseConfig.useSupabase) {
        result = _getFallback(prefix);
      } else {
        final response = await Supabase.instance.client.rpc(
          'next_counter',
          params: {'p_key': key},
        );

        final int n = int.parse(response.toString());
        final String counterPart = '/${n.toString().padLeft(5, '0')}';
        
        String safePrefix = prefix;
        // GST rules mandate a maximum of 16 characters.
        // Truncate the prefix if necessary, but NEVER the sequential digits.
        if (safePrefix.length + counterPart.length > 16) {
          int allowedLength = 16 - counterPart.length;
          if (allowedLength < 0) allowedLength = 0;
          safePrefix = safePrefix.substring(0, allowedLength);
        }
        
        result = '$safePrefix$counterPart';
      }
    } catch (e) {
      result = _getFallback(prefix);
    }

    return result;
  }

  String _getFallback(String prefix) {
    final int timestampPart = DateTime.now().millisecondsSinceEpoch % 100000000;
    final String counterPart = '-$timestampPart';
    
    String safePrefix = prefix;
    if (safePrefix.length + counterPart.length > 16) {
      int allowedLength = 16 - counterPart.length;
      if (allowedLength < 0) allowedLength = 0;
      safePrefix = safePrefix.substring(0, allowedLength);
    }
    
    return '$safePrefix$counterPart';
  }
}