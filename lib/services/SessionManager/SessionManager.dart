import 'package:shared_preferences/shared_preferences.dart';

/// A service class that manages user authentication state and session persistence
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  // Session state keys
  static const String _keyIsUserLoggedIn = 'isUserLoggedIn';
  static const String _keyUsername = 'username';
  static const String _keyCompanyName = 'companyName';
  static const String _keyBusinessType = 'businessType';
  static const String _keyHasCompletedOnboarding = 'hasCompletedOnboarding';
  static const String _keyHasCompletedBusinessSetup = 'hasCompletedBusinessSetup';
  static const String _keyUserProfileImage = 'userProfileImage';
  static const String _keyLastLoginTime = 'lastLoginTime';
  static const String _keyEmail = 'email';
  static const String _keyPhone = 'phone';
  static const String _keyLocation = 'location';
  static const String _keyHasSignedUp = 'hasSignedUp';
  static const String _keyMemberSince = 'memberSince';
  static const String _keyIsPremium = 'isPremium';
  static const String _keyBookedEvents = 'bookedEvents';

  /// Saves user session data to persist login state with additional fields
  Future<bool> saveUserSession({
    required String username,
    required String companyName,
    required String businessType,
    String? profileImage,
    String email = '',
    String phone = '',
    String location = '',
    bool hasSignedUp = false,
    String memberSince = '',
    required bool isPremium,
    required List<String> bookedEvents,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(_keyIsUserLoggedIn, true); // دائماً يكون مسجل الدخول عند حفظ الجلسة
      await prefs.setString(_keyUsername, username);
      await prefs.setString(_keyCompanyName, companyName);
      await prefs.setString(_keyBusinessType, businessType);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyPhone, phone);
      await prefs.setString(_keyLocation, location);
      await prefs.setBool(_keyHasSignedUp, hasSignedUp);
      await prefs.setBool(_keyIsPremium, isPremium);

      // حفظ الفعاليات المحجوزة
      await prefs.setStringList(_keyBookedEvents, bookedEvents);

      if (memberSince.isNotEmpty) {
        await prefs.setString(_keyMemberSince, memberSince);
      }

      if (profileImage != null) {
        await prefs.setString(_keyUserProfileImage, profileImage);
      }

      // Set login timestamp
      await prefs.setString(_keyLastLoginTime, DateTime.now().toIso8601String());

      return true;
    } catch (e) {
      print('Error saving user session: $e');
      return false;
    }
  }

  /// Marks that onboarding has been completed
  Future<bool> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasCompletedOnboarding, true);

      // For backward compatibility with your first_launch logic
      await prefs.setBool('first_launch', false);

      return true;
    } catch (e) {
      print('Error marking onboarding as completed: $e');
      return false;
    }
  }

  /// Marks that business setup has been completed
  Future<bool> completeBusinessSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasCompletedBusinessSetup, true);
      return true;
    } catch (e) {
      print('Error marking business setup as completed: $e');
      return false;
    }
  }

  /// Checks if user is logged in
  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsUserLoggedIn) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  /// Checks if user has signed up
  Future<bool> hasSignedUp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSignedUp) ?? false;
    } catch (e) {
      print('Error checking signup status: $e');
      return false;
    }
  }

  /// Checks if onboarding has been completed
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check both new and legacy flags
      final newFlag = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
      final legacyFlag = !(prefs.getBool('first_launch') ?? true);

      return newFlag || legacyFlag;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Checks if business setup has been completed
  Future<bool> hasCompletedBusinessSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasCompletedBusinessSetup) ?? false;
    } catch (e) {
      print('Error checking business setup status: $e');
      return false;
    }
  }

  /// Gets user session data
  Future<Map<String, dynamic>> getUserSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check both new and legacy onboarding flags
      final hasCompletedOnboarding = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
      final firstLaunch = prefs.getBool('first_launch') ?? true;

      return {
        'isLoggedIn': prefs.getBool(_keyIsUserLoggedIn) ?? false,
        'username': prefs.getString(_keyUsername) ?? '',
        'companyName': prefs.getString(_keyCompanyName) ?? '',
        'businessType': prefs.getString(_keyBusinessType) ?? '',
        'hasCompletedOnboarding': hasCompletedOnboarding || !firstLaunch,
        'hasCompletedBusinessSetup': prefs.getBool(_keyHasCompletedBusinessSetup) ?? false,
        'profileImage': prefs.getString(_keyUserProfileImage) ?? '',
        'lastLoginTime': prefs.getString(_keyLastLoginTime) ?? '',
        'email': prefs.getString(_keyEmail) ?? '',
        'phone': prefs.getString(_keyPhone) ?? '',
        'location': prefs.getString(_keyLocation) ?? '',
        'hasSignedUp': prefs.getBool(_keyHasSignedUp) ?? false,
        'memberSince': prefs.getString(_keyMemberSince) ?? '',
        'isPremium': prefs.getBool(_keyIsPremium) ?? false,
        'bookedEvents': prefs.getStringList(_keyBookedEvents) ?? [],
      };
    } catch (e) {
      print('Error getting user session data: $e');
      return {
        'isLoggedIn': false,
        'username': '',
        'companyName': '',
        'businessType': '',
        'hasCompletedOnboarding': false,
        'hasCompletedBusinessSetup': false,
        'profileImage': '',
        'lastLoginTime': '',
        'email': '',
        'phone': '',
        'location': '',
        'hasSignedUp': false,
        'memberSince': '',
        'isPremium': false,
        'bookedEvents': [],
      };
    }
  }

  /// Logs out user by clearing session data
  Future<bool> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear login status but keep user data
      await prefs.setBool(_keyIsUserLoggedIn, false);
      await prefs.remove(_keyLastLoginTime);

      return true;
    } catch (e) {
      print('Error logging out user: $e');
      return false;
    }
  }

  /// Clear all preferences (for testing or account deletion)
  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing preferences: $e');
      return false;
    }
  }
}