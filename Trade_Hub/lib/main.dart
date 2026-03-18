import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trade_hub/screens/onboarding/Splash%20Screen.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';
import 'providers/Localization Provider.dart';
import 'providers/Theme Provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize session manager
  final SessionManager sessionManager = SessionManager();

  // Check current session state
  final sessionData = await sessionManager.getUserSessionData();
  final isFirstLaunch = !sessionData['hasCompletedOnboarding'];

  // Keep backward compatibility with existing code
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('first_launch', isFirstLaunch);

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
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: MaterialApp(
            title: 'TradeHub',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),

            // Localization setup
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

            // Start with splash screen - this will handle the routing
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}