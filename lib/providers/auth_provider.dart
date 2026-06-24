import 'package:flutter/material.dart';
import 'package:saathi/data/models/user.dart';
import 'package:saathi/data/repository.dart';
import 'package:saathi/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool get isLoggedIn => prefs.getString(AppConstants.token) != null;

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

  Future<void> requestOtp(String phone) async {
    _loading = true;
    notifyListeners();
    _lastOtp = await repository.requestOtp(phone);
    _loading = false;
    notifyListeners();
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _loading = true;
    notifyListeners();
    final ok = await repository.verifyOtp(phone, otp);
    if (ok) {
      await prefs.setString(AppConstants.token, 'demo_token_$phone');
      await prefs.setString(AppConstants.userPhone, phone);
      if (prefs.getString(AppConstants.userName) == null) {
        await prefs.setString(AppConstants.userName, 'Retailer');
        await prefs.setString(AppConstants.shopName, 'My Kirana Store');
      }
      loadUser();
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
  }

  Future<void> logout() async {
    await prefs.remove(AppConstants.token);
    _user = null;
    notifyListeners();
  }
}
