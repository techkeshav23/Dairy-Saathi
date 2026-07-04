import 'package:flutter/material.dart';
import 'package:my_order_pro/data/models/user.dart';
import 'package:my_order_pro/data/repository.dart';
import 'package:my_order_pro/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final Repository repository;
  final SharedPreferences prefs;

  AuthProvider({required this.repository, required this.prefs});

  bool _loading = false;
  bool get loading => _loading;

  String? _lastOtp; // demo helper to surface the OTP
  String? get lastOtp => _lastOtp;

  UserModel? _user;
  UserModel? get user => _user;

  bool get isLoggedIn => Supabase.instance.client.auth.currentSession != null;

  void loadUser() {
    if (isLoggedIn) {
      _user = UserModel(
        name: prefs.getString(AppConstants.userName) ?? 'Retailer',
        shopName: prefs.getString(AppConstants.shopName) ?? 'My Shop',
        phone: prefs.getString(AppConstants.userPhone) ?? '',
        address: prefs.getString('saathi_address') ?? '',
        gstin: prefs.getString('saathi_gstin') ?? '',
      );
    }
  }

  /// Normalise a raw 10-digit Indian number to E.164 (+91XXXXXXXXXX).
  /// Supabase auth requires E.164; the sign-in screen collects only the 10 digits.
  String _e164(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (phone.trim().startsWith('+')) return '+$digits';
    if (digits.length == 10) return '+91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    return '+$digits';
  }

  /// Requests an OTP. Returns null on success, or an error message on failure.
  /// Always resets loading (finally) so the UI can never get stuck spinning.
  Future<String?> requestOtp(String phone) async {
    _loading = true;
    notifyListeners();
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: _e164(phone));
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Could not send OTP. Check your internet connection and try again.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _loading = true;
    notifyListeners();
    bool ok = false;

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        phone: _e164(phone),
        token: otp,
        type: OtpType.sms,
      );
      
      if (response.session != null) {
        final uid = response.session!.user.id;
        await prefs.setString(AppConstants.userPhone, phone);

        // Sync profile with the backend: a returning user (or new device) gets
        // their saved details; a brand-new user gets a persisted app_users row.
        try {
          final existing = await Supabase.instance.client
              .from('app_users')
              .select()
              .eq('id', uid)
              .maybeSingle();
          if (existing != null) {
            await prefs.setString(AppConstants.userName, (existing['name'] ?? 'Retailer').toString());
            await prefs.setString(AppConstants.shopName, (existing['shop_name'] ?? 'My Shop').toString());
            await prefs.setString('saathi_gstin', (existing['gst'] ?? '').toString());
          } else {
            if (prefs.getString(AppConstants.userName) == null) {
              await prefs.setString(AppConstants.userName, 'Retailer');
              await prefs.setString(AppConstants.shopName, 'My Kirana Store');
            }
            await Supabase.instance.client.from('app_users').upsert({
              'id': uid,
              'phone': phone,
              'name': prefs.getString(AppConstants.userName),
              'shop_name': prefs.getString(AppConstants.shopName),
            });
          }
        } catch (_) {
          // Profile sync is best-effort — never block login on it.
          if (prefs.getString(AppConstants.userName) == null) {
            await prefs.setString(AppConstants.userName, 'Retailer');
            await prefs.setString(AppConstants.shopName, 'My Kirana Store');
          }
        }
        loadUser();
        ok = true;
      }
    } catch (e) {
      ok = false;
    }
    
    _loading = false;
    notifyListeners();
    return ok;
  }

  Future<void> updateProfile(UserModel updated) async {
    await prefs.setString(AppConstants.userName, updated.name);
    await prefs.setString(AppConstants.shopName, updated.shopName);
    await prefs.setString('saathi_address', updated.address);
    await prefs.setString('saathi_gstin', updated.gstin);
    _user = updated;
    notifyListeners();

    // Persist to the backend so the profile survives reinstall / new device.
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      // Removed the empty catch block. If this fails (e.g., offline), 
      // the error will propagate so the UI can catch it, show a SnackBar, 
      // and optionally revert the optimistic local update.
      await Supabase.instance.client.from('app_users').upsert({
        'id': uid,
        'phone': prefs.getString(AppConstants.userPhone) ?? updated.phone,
        'name': updated.name,
        'shop_name': updated.shopName,
        'gst': updated.gstin,
      });
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    // Clear ALL user PII so the next account on this device never inherits it.
    for (final k in [
      AppConstants.userName,
      AppConstants.shopName,
      AppConstants.userPhone,
      'saathi_address',
      'saathi_gstin',
    ]) {
      await prefs.remove(k);
    }
    _user = null;
    notifyListeners();
  }
}