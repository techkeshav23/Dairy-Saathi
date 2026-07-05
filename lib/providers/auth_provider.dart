import 'package:flutter/material.dart';
import 'package:my_order_pro/data/models/user.dart';
import 'package:my_order_pro/data/repository.dart';
import 'package:my_order_pro/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Email + password authentication for retailers.
/// Retailers can self sign-up (instant, no approval) or use a login the distributor
/// created for them in the admin console. On sign-up we also create the app_users
/// profile so the retailer shows up in the distributor's Retailers list.
class AuthProvider extends ChangeNotifier {
  final Repository repository;
  final SharedPreferences prefs;

  AuthProvider({required this.repository, required this.prefs});

  bool _loading = false;
  bool get loading => _loading;

  UserModel? _user;
  UserModel? get user => _user;

  // 'retailer' (default) sees the lean ordering app; 'distributor' sees the full
  // accounting/admin shell. A user is a distributor if their email is the configured
  // owner email OR their app_users.role is 'distributor' in Supabase (so extra
  // distributors can be added later without a rebuild).
  static const String distributorEmail = 'admin@admin.com';

  String _role = 'retailer';
  String get role => _role;
  bool get isDistributor => _role == 'distributor';

  SupabaseClient get _sb => Supabase.instance.client;
  bool get isLoggedIn => _sb.auth.currentSession != null;

  void loadUser() {
    if (isLoggedIn) {
      _role = prefs.getString('saathi_role') ?? 'retailer';
      _user = UserModel(
        name: prefs.getString(AppConstants.userName) ?? 'Retailer',
        shopName: prefs.getString(AppConstants.shopName) ?? 'My Shop',
        phone: prefs.getString(AppConstants.userPhone) ?? '',
        address: prefs.getString('saathi_address') ?? '',
        gstin: prefs.getString('saathi_gstin') ?? '',
      );
      notifyListeners();
    }
  }

  /// Re-fetch the role from the backend (used on app boot so a role change made in
  /// Supabase takes effect on next launch even for an already-logged-in user).
  Future<void> refreshRole() async {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return;
    await _syncProfileFromServer(uid);
    notifyListeners();
  }

  /// Email + password sign in. Returns null on success, else an error message.
  Future<String?> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _sb.auth.signInWithPassword(email: email.trim(), password: password);
      if (res.session == null) return 'Sign in failed. Please try again.';
      await prefs.setString('saathi_email', email.trim());
      await _syncProfileFromServer(res.user!.id);
      loadUser();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not sign in. Check your internet connection and try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Self sign-up — creates the login + retailer profile (instant, active).
  /// Returns null on success, or an error/notice message.
  Future<String?> signUp({
    required String email,
    required String password,
    required String shopName,
    required String ownerName,
    String phone = '',
    String gstin = '',
    String area = '',
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _sb.auth.signUp(email: email.trim(), password: password);
      final user = res.user;
      if (user == null) return 'Sign up failed. Please try again.';

      await prefs.setString(AppConstants.userName, ownerName);
      await prefs.setString(AppConstants.shopName, shopName);
      await prefs.setString(AppConstants.userPhone, phone);
      await prefs.setString('saathi_gstin', gstin);
      await prefs.setString('saathi_email', email.trim());

      // Needs an active session (email-confirmation OFF) to write the profile under RLS.
      if (_sb.auth.currentSession == null) {
        return 'Account created. Please confirm your email, then sign in.';
      }

      try {
        await _sb.from('app_users').upsert({
          'id': user.id,
          'email': email.trim(),
          'phone': phone.isEmpty ? null : phone,
          'business_name': shopName,
          'owner_name': ownerName,
          'shop_name': shopName,
          'name': ownerName,
          'gst': gstin,
          'area': area,
          'status': 'active',
          'created_by': 'self',
          'code': 'R${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        });
      } catch (_) {
        // Profile write is best-effort — never block onboarding on it.
      }

      loadUser();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not sign up. Check your internet connection and try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Pull the user's saved profile into local prefs and resolve their role
  /// (distributor if the owner email or DB role says so; otherwise retailer).
  Future<void> _syncProfileFromServer(String uid) async {
    Map<String, dynamic>? row;
    try {
      row = await _sb.from('app_users').select().eq('id', uid).maybeSingle();
    } catch (_) {
      row = null;
    }
    if (row != null) {
      await prefs.setString(AppConstants.userName, (row['owner_name'] ?? row['name'] ?? 'Retailer').toString());
      await prefs.setString(AppConstants.shopName, (row['business_name'] ?? row['shop_name'] ?? 'My Shop').toString());
      await prefs.setString('saathi_gstin', (row['gst'] ?? '').toString());
      if (row['phone'] != null) await prefs.setString(AppConstants.userPhone, row['phone'].toString());
    }
    final email = _sb.auth.currentUser?.email?.toLowerCase() ?? '';
    final dbRole = (row?['role'] ?? 'retailer').toString();
    _role = (email == distributorEmail.toLowerCase() || dbRole == 'distributor') ? 'distributor' : 'retailer';
    await prefs.setString('saathi_role', _role);
  }

  Future<void> updateProfile(UserModel updated) async {
    await prefs.setString(AppConstants.userName, updated.name);
    await prefs.setString(AppConstants.shopName, updated.shopName);
    await prefs.setString('saathi_address', updated.address);
    await prefs.setString('saathi_gstin', updated.gstin);
    _user = updated;
    notifyListeners();

    final uid = _sb.auth.currentUser?.id;
    if (uid != null) {
      await _sb.from('app_users').upsert({
        'id': uid,
        'phone': prefs.getString(AppConstants.userPhone) ?? updated.phone,
        'business_name': updated.shopName,
        'owner_name': updated.name,
        'shop_name': updated.shopName,
        'name': updated.name,
        'gst': updated.gstin,
      });
    }
  }

  Future<void> logout() async {
    await _sb.auth.signOut();
    for (final k in [
      AppConstants.userName,
      AppConstants.shopName,
      AppConstants.userPhone,
      'saathi_address',
      'saathi_gstin',
      'saathi_email',
      'saathi_role',
    ]) {
      await prefs.remove(k);
    }
    _role = 'retailer';
    _user = null;
    notifyListeners();
  }
}
