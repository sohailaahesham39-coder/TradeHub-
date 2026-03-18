import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';

class UserAuthProvider extends ChangeNotifier {
  String? _username = '';
  String? _companyName = '';
  String? _businessType = '';
  String? _profileImage = '';
  String? _email = '';
  String? _phone = '';
  String? _location = '';
  bool _isLoggedIn = false;
  bool _isFirstLaunch = true;
  bool _hasCompletedBusinessSetup = false;
  bool _hasSignedUp = false;
  bool _isPremium = false;
  DateTime? _memberSince;
  List<String> _bookedEvents = [];

  final SessionManager _sessionManager = SessionManager();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get username => _username ?? '';
  String get companyName => _companyName ?? '';
  String get businessType => _businessType ?? '';
  String get profileImage => _profileImage ?? '';
  String get email => _email ?? '';
  String get phone => _phone ?? '';
  String get location => _location ?? '';
  bool get isLoggedIn => _isLoggedIn;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get hasCompletedBusinessSetup => _hasCompletedBusinessSetup;
  bool get hasSignedUp => _hasSignedUp;
  bool get isPremium => _isPremium;
  DateTime get memberSince => _memberSince ?? DateTime.now();
  List<String> get bookedEvents => _bookedEvents;

  UserAuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _isLoggedIn = user != null;
      if (user != null) {
        _email = user.email;
        _username = user.displayName ?? user.email?.split('@')[0] ?? '';
        _loadSessionData();
      } else {
        _clearUserData();
      }
      notifyListeners();
    });
  }

  void _loadSessionData() async {
    final sessionData = await _sessionManager.getUserSessionData();
    _username = sessionData['username'] as String? ?? _username;
    _companyName = sessionData['companyName'] as String? ?? '';
    _businessType = sessionData['businessType'] as String? ?? '';
    _profileImage = sessionData['profileImage'] as String? ?? '';
    _phone = sessionData['phone'] as String? ?? '';
    _location = sessionData['location'] as String? ?? '';
    _hasSignedUp = sessionData['hasSignedUp'] as bool? ?? false;
    _isPremium = sessionData['isPremium'] as bool? ?? false;
    _bookedEvents = List<String>.from(sessionData['bookedEvents'] as List? ?? []);
    _isFirstLaunch = !(sessionData['hasCompletedOnboarding'] as bool? ?? false);
    _hasCompletedBusinessSetup = sessionData['hasCompletedBusinessSetup'] as bool? ?? false;

    if (sessionData['memberSince'] != null && sessionData['memberSince'].toString().isNotEmpty) {
      try {
        _memberSince = DateTime.parse(sessionData['memberSince'] as String);
      } catch (e) {
        debugPrint('Error parsing memberSince date: $e');
        _memberSince = DateTime.now();
      }
    } else {
      _memberSince = DateTime.now();
    }

    notifyListeners();
  }

  void _clearUserData() {
    _username = '';
    _companyName = '';
    _businessType = '';
    _profileImage = '';
    _email = '';
    _phone = '';
    _location = '';
    _hasSignedUp = false;
    _isPremium = false;
    _bookedEvents = [];
    _memberSince = null;
    _isLoggedIn = false;
  }

  Future<void> signup({
    required String username,
    required String email,
    required String password,
    String companyName = '',
    String businessType = '',
    String phone = '',
    String location = '',
    bool isPremium = false,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(username);

      _username = username;
      _email = email;
      _companyName = companyName;
      _businessType = businessType;
      _phone = phone;
      _location = location;
      _hasSignedUp = true;
      _isLoggedIn = true;
      _isPremium = isPremium;
      _memberSince = DateTime.now();
      _bookedEvents = [];

      await _sessionManager.saveUserSession(
        username: username,
        companyName: companyName,
        businessType: businessType,
        profileImage: _profileImage ?? '',
        email: email,
        phone: phone,
        location: location,
        hasSignedUp: true,
        isPremium: isPremium,
        memberSince: _memberSince!.toIso8601String(),
        bookedEvents: _bookedEvents,
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Signup error: $e');
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final sessionData = await _sessionManager.getUserSessionData();
      final hasSignedUp = sessionData['hasSignedUp'] as bool? ?? false;

      if (!hasSignedUp) {
        throw Exception('Please sign up first before logging in');
      }

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', true);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _sessionManager.logoutUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', false);
    notifyListeners();
  }

  Future<void> setUserData({
    required String username,
    required String companyName,
    String businessType = '',
    String email = '',
    String phone = '',
    String location = '',
    String profileImage = '',
    bool? isPremium,
  }) async {
    _username = username;
    _companyName = companyName;
    _businessType = businessType;
    if (email.isNotEmpty) _email = email;
    if (phone.isNotEmpty) _phone = phone;
    if (location.isNotEmpty) _location = location;
    if (profileImage.isNotEmpty) _profileImage = profileImage;
    if (isPremium != null) _isPremium = isPremium;

    await _sessionManager.saveUserSession(
      username: username,
      companyName: companyName,
      businessType: businessType,
      profileImage: _profileImage ?? '',
      email: _email ?? '',
      phone: _phone ?? '',
      location: _location ?? '',
      hasSignedUp: _hasSignedUp,
      isPremium: _isPremium,
      memberSince: _memberSince?.toIso8601String() ?? DateTime.now().toIso8601String(),
      bookedEvents: _bookedEvents,
    );

    if (_auth.currentUser != null && username != _auth.currentUser!.displayName) {
      await _auth.currentUser!.updateDisplayName(username);
    }

    notifyListeners();
  }

  Future<void> completeBusinessSetup({
    required String businessType,
    required String companyName,
    bool? isPremium,
  }) async {
    _businessType = businessType;
    _companyName = companyName;
    _hasCompletedBusinessSetup = true;
    if (isPremium != null) _isPremium = isPremium;

    await _sessionManager.saveUserSession(
      username: _username ?? '',
      companyName: companyName,
      businessType: businessType,
      profileImage: _profileImage ?? '',
      email: _email ?? '',
      phone: _phone ?? '',
      location: _location ?? '',
      hasSignedUp: _hasSignedUp,
      isPremium: _isPremium,
      memberSince: _memberSince?.toIso8601String() ?? DateTime.now().toIso8601String(),
      bookedEvents: _bookedEvents,
    );
    await _sessionManager.completeBusinessSetup();

    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isFirstLaunch = false;
    await _sessionManager.completeOnboarding();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? username,
    String? companyName,
    String? businessType,
    String? profileImage,
    String? email,
    String? phone,
    String? location,
    bool? isPremium,
  }) async {
    if (username != null) _username = username;
    if (companyName != null) _companyName = companyName;
    if (businessType != null) _businessType = businessType;
    if (profileImage != null) _profileImage = profileImage;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (location != null) _location = location;
    if (isPremium != null) _isPremium = isPremium;

    await _sessionManager.saveUserSession(
      username: _username ?? '',
      companyName: _companyName ?? '',
      businessType: _businessType ?? '',
      profileImage: _profileImage ?? '',
      email: _email ?? '',
      phone: _phone ?? '',
      location: _location ?? '',
      hasSignedUp: _hasSignedUp,
      isPremium: _isPremium,
      memberSince: _memberSince?.toIso8601String() ?? DateTime.now().toIso8601String(),
      bookedEvents: _bookedEvents,
    );

    if (_auth.currentUser != null) {
      if (username != null && username != _auth.currentUser!.displayName) {
        await _auth.currentUser!.updateDisplayName(username);
      }
      if (email != null && email != _auth.currentUser!.email) {
        await _auth.currentUser!.updateEmail(email);
      }
    }

    notifyListeners();
  }

  Future<void> bookEvent(String eventId) async {
    if (eventId.isEmpty) {
      debugPrint('Error: Attempted to book event with empty eventId');
      return;
    }
    if (!_bookedEvents.contains(eventId)) {
      _bookedEvents.add(eventId);
      await _sessionManager.saveUserSession(
        username: _username ?? '',
        companyName: _companyName ?? '',
        businessType: _businessType ?? '',
        profileImage: _profileImage ?? '',
        email: _email ?? '',
        phone: _phone ?? '',
        location: _location ?? '',
        hasSignedUp: _hasSignedUp,
        isPremium: _isPremium,
        memberSince: _memberSince?.toIso8601String() ?? DateTime.now().toIso8601String(),
        bookedEvents: _bookedEvents,
      );
      debugPrint('Booked event: $eventId, Total booked: ${_bookedEvents.length}');
      notifyListeners();
    }
  }

  Future<void> unbookEvent(String eventId) async {
    if (eventId.isEmpty) {
      debugPrint('Error: Attempted to unbook event with empty eventId');
      return;
    }
    if (_bookedEvents.contains(eventId)) {
      _bookedEvents.remove(eventId);
      await _sessionManager.saveUserSession(
        username: _username ?? '',
        companyName: _companyName ?? '',
        businessType: _businessType ?? '',
        profileImage: _profileImage ?? '',
        email: _email ?? '',
        phone: _phone ?? '',
        location: _location ?? '',
        hasSignedUp: _hasSignedUp,
        isPremium: _isPremium,
        memberSince: _memberSince?.toIso8601String() ?? DateTime.now().toIso8601String(),
        bookedEvents: _bookedEvents,
      );
      debugPrint('Unbooked event: $eventId, Total booked: ${_bookedEvents.length}');
      notifyListeners();
    }
  }
}