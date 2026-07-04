import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:my_order_pro/data/supabase_config.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PartyService {
  Database? _db;

  Future<Database> _getDatabase() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_order_pro_parties.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE parties(id TEXT PRIMARY KEY, name TEXT, phone TEXT, type TEXT, address TEXT, gstin TEXT, balance REAL DEFAULT 0.0)',
        );
      },
    );
    return _db!;
  }

  Future<bool> addParty({
    required String name,
    required String phone,
    required String type,
    String address = '',
    String gstin = '',
  }) async {
    try {
      if (SupabaseConfig.useSupabase) {
        await Supabase.instance.client.from('parties').insert({
          'id': 'party_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'phone': phone,
          'type': type,
          'address': address,
          'gstin': gstin,
          'balance': 0.0,
          'user_id': Supabase.instance.client.auth.currentUser?.id,
        });
      } else {
        final String id = DateTime.now().millisecondsSinceEpoch.toString();
        final Map<String, dynamic> partyData = {
          'id': id,
          'name': name,
          'phone': phone,
          'type': type,
          'address': address,
          'gstin': gstin,
          'balance': 0.0,
        };
        final db = await _getDatabase();
        await db.insert(
          'parties',
          partyData,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      return true;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> listParties() async {
    try {
      if (SupabaseConfig.useSupabase) {
        final response = await Supabase.instance.client.from('parties').select();
        return List<Map<String, dynamic>>.from(response);
      } else {
        final db = await _getDatabase();
        final List<Map<String, dynamic>> maps = await db.query('parties');
        return List<Map<String, dynamic>>.from(maps);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updateBalance(String partyId, double amount) async {
    try {
      if (SupabaseConfig.useSupabase) {
        // Atomic server-side increment — no client read-modify-write race (v9).
        await Supabase.instance.client.rpc('increment_party_balance', params: {
          'p_id': partyId,
          'delta': amount,
        });
      } else {
        final db = await _getDatabase();
        await db.rawUpdate(
          'UPDATE parties SET balance = COALESCE(balance, 0.0) + ? WHERE id = ?',
          [amount, partyId],
        );
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}