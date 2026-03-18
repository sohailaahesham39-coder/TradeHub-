import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';

import 'package:trade_hub/providers/Theme%20Provider.dart';

import 'package:trade_hub/screens/onboarding/Splash%20Screen.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';


// Uncomment this function to reset all app state for testing
// Future<void> _resetAppState() async {
//   final SessionManager sessionManager = SessionManager();
//   await sessionManager.clearAll();
//   debugPrint("Reset all session data for testing!");
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    // Optionally handle the error (e.g., show an error screen)
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize session manager
  final SessionManager sessionManager = SessionManager();

  // Print session state in debug mode
  bool isDebugMode = false;
  assert(() {
    isDebugMode = true;
    return true;
  }());
  if (isDebugMode) {
    await _printSessionState(sessionManager);
  }

  // Get session data
  final sessionData = await sessionManager.getUserSessionData();
  final isFirstLaunch = !(sessionData['hasCompletedOnboarding'] as bool? ?? false);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(
          create: (_) => UserAuthProvider()
            ..setFirstLaunch(isFirstLaunch)
            ..initFromSessionData(sessionData),
        ),
      ],
      child: const TradeHubApp(),
    ),
  );
}

// Debug function to print current session state
Future<void> _printSessionState(SessionManager sessionManager) async {
  final data = await sessionManager.getUserSessionData();

  debugPrint('===== CURRENT SESSION STATE =====');
  debugPrint('hasCompletedOnboarding: ${data['hasCompletedOnboarding']}');
  debugPrint('isLoggedIn: ${data['isLoggedIn']}');
  debugPrint('hasCompletedBusinessSetup: ${data['hasCompletedBusinessSetup']}');
  debugPrint('Username: ${data['username']}');
  debugPrint('CompanyName: ${data['companyName']}');
  debugPrint('BusinessType: ${data['businessType']}');
  debugPrint('===============================');
}

class TradeHubApp extends StatelessWidget {
  const TradeHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: MaterialApp(
          title: 'TradeHub',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          locale: localizationProvider.locale,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ar', 'SA'),
          ],
          home: const SplashScreen(),
        ),
      ),
    );
  }
}