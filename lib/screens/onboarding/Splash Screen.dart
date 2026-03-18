import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';
import '../../providers/AuthProvider.dart';
import '../../providers/Localization Provider.dart';
import '../../providers/Theme Provider.dart';
import '../home/Home Screen.dart';
import '../auth/Login Screen.dart';
import '../Business Setup Screen.dart';
import 'Onboarding Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final SessionManager _sessionManager = SessionManager();
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Check user status and navigate accordingly
    _checkUserStatusAndNavigate();
  }

  Future<void> _checkUserStatusAndNavigate() async {
    // Allow splash screen to display for a minimum time
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      // Get session data from the session manager
      final sessionData = await _sessionManager.getUserSessionData();

      print('DEBUG: Session Data retrieved:');
      print('hasCompletedOnboarding: ${sessionData['hasCompletedOnboarding']}');
      print('isLoggedIn: ${sessionData['isLoggedIn']}');
      print('hasCompletedBusinessSetup: ${sessionData['hasCompletedBusinessSetup']}');

      if (!mounted) return;

      // Update auth provider with session data
      final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
      authProvider.initFromSessionData(sessionData);

      if (!mounted || _isNavigating) return;
      _isNavigating = true;

      // Enhanced navigation logic with safer checks
      if (sessionData['hasCompletedOnboarding'] != true) {
        print('DEBUG: Navigating to onboarding');
        _navigateToOnboarding();
      } else if (sessionData['isLoggedIn'] != true) {
        print('DEBUG: Navigating to login');
        _navigateToLogin();
      } else if (sessionData['hasCompletedBusinessSetup'] != true) {
        print('DEBUG: Navigating to business setup');
        _navigateToBusinessSetup();
      } else {
        print('DEBUG: Navigating to home');
        _navigateToHome();
      }
    } catch (e) {
      print('ERROR: Exception in navigation: $e');
      // Fallback to onboarding if there's an error
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        _navigateToOnboarding();
      }
    }
  }

  void _navigateToOnboarding() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToBusinessSetup() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const BusinessSetupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.9),
              AppTheme.primaryColor,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20.r,
                              offset: Offset(0, 10.h),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.business_center,
                          size: 80.sp,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      // App Name
                      Text(
                        "TradeHub",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Tagline
                      Text(
                        isArabic ? "تواصل. تجارة. نمو." : "Connect. Trade. Grow.",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w400,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 50.h),
                      // Loading indicator
                      SizedBox(
                        width: 40.w,
                        height: 40.h,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}