import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';

class UserAuthProvider extends ChangeNotifier {
  // User data (nullable types)
  String? _username = '';
  String? _companyName = '';
  String? _businessType = '';
  String? _profileImage = '';
  bool _isLoggedIn = false;
  bool _isFirstLaunch = true;
  bool _hasCompletedBusinessSetup = false;

  // Session manager instance
  final SessionManager _sessionManager = SessionManager();

  // Getters with null safety
  String get username => _username ?? '';
  String get companyName => _companyName ?? '';
  String get businessType => _businessType ?? '';
  String get profileImage => _profileImage ?? '';
  bool get isLoggedIn => _isLoggedIn;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedBusinessSetup => _hasCompletedBusinessSetup;

  // Initialize auth provider with session data
  void initFromSessionData(Map<String, dynamic> sessionData) {
    _username = sessionData['username'] as String? ?? '';
    _companyName = sessionData['companyName'] as String? ?? '';
    _businessType = sessionData['businessType'] as String? ?? '';
    _profileImage = sessionData['profileImage'] as String? ?? '';
    _isLoggedIn = sessionData['isLoggedIn'] as bool? ?? false;
    _isFirstLaunch = !(sessionData['hasCompletedOnboarding'] as bool? ?? false);
    _hasCompletedBusinessSetup = sessionData['hasCompletedBusinessSetup'] as bool? ?? false;
    notifyListeners();
  }

  // Set first launch state
  void setFirstLaunch(bool isFirstLaunch) {
    _isFirstLaunch = isFirstLaunch;
    notifyListeners();
  }

  // Set user data and save to session
  Future<void> setUserData({
    required String username,
    required String companyName,
    String businessType = '',
  }) async {
    _username = username;
    _companyName = companyName;
    _businessType = businessType;
    _isLoggedIn = true;

    await _sessionManager.saveUserSession(
      username: username,
      companyName: companyName,
      businessType: businessType,
      profileImage: _profileImage ?? '',
    );

    notifyListeners();
  }

  // Complete business setup
  Future<void> completeBusinessSetup({
    required String businessType,
    required String companyName,
  }) async {
    _businessType = businessType;
    _companyName = companyName;
    _hasCompletedBusinessSetup = true;

    await _sessionManager.saveUserSession(
      username: _username ?? '',
      companyName: companyName,
      businessType: businessType,
      profileImage: _profileImage ?? '',
    );
    await _sessionManager.completeBusinessSetup();

    notifyListeners();
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    await _sessionManager.completeOnboarding();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);

    notifyListeners();
  }

  // Login user
  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final username = email.split('@')[0];

    await setUserData(
      username: username,
      companyName: _companyName ?? '',
      businessType: _businessType ?? '',
    );

    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', true);
    }

    notifyListeners();
  }

  // Logout user - Improved implementation
  Future<void> logout() async {
    // First call session manager's logout method
    await _sessionManager.logoutUser();

    // Reset all user data
    _username = '';
    _companyName = '';
    _businessType = '';
    _profileImage = '';
    _isLoggedIn = false;
    _hasCompletedBusinessSetup = false;

    // Clear remember me preference if set
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', false);

    notifyListeners();
  }

  // Update profile
  Future<void> updateProfile({
    String? username,
    String? companyName,
    String? businessType,
    String? profileImage,
  }) async {
    if (username != null) _username = username;
    if (companyName != null) _companyName = companyName;
    if (businessType != null) _businessType = businessType;
    if (profileImage != null) _profileImage = profileImage;

    await _sessionManager.saveUserSession(
      username: _username ?? '',
      companyName: _companyName ?? '',
      businessType: _businessType ?? '',
      profileImage: _profileImage ?? '',
    );

    notifyListeners();
  }
}