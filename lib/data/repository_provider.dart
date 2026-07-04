import 'package:my_order_pro/data/repository.dart';
import 'package:my_order_pro/data/supabase_config.dart';
import 'package:my_order_pro/data/supabase_repository.dart';

/// Single source for which [Repository] the app uses.
/// Supabase when configured (see [SupabaseConfig]); MockRepository otherwise.
class RepositoryProvider {
  RepositoryProvider._();

  static final Repository instance =
      SupabaseConfig.useSupabase ? SupabaseRepository() : MockRepository();
}
