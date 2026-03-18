// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:trade_hub/providers/AuthProvider.dart';
// import 'package:trade_hub/screens/auth/Login%20Screen.dart';
// import 'package:trade_hub/screens/Business%20Setup%20Screen.dart';
// import 'package:trade_hub/screens/home/Home%20Screen.dart';
// import 'package:trade_hub/screens/onboarding/Onboarding%20Screen.dart';
// import 'package:trade_hub/services/SessionManager/SessionManager.dart';
//
// /// AppRouter handles user navigation flow on app launch and manages session persistence
// class AppRouter extends StatefulWidget {
//   const AppRouter({Key? key}) : super(key: key);
//
//   @override
//   State<AppRouter> createState() => _AppRouterState();
// }
//
// class _AppRouterState extends State<AppRouter> {
//   final SessionManager _sessionManager = SessionManager();
//   bool _isLoading = true;
//   Widget? _initialScreen;
//
//   @override
//   void initState() {
//     super.initState();
//     _checkUserSession();
//   }
//
//   Future<void> _checkUserSession() async {
//     try {
//       final sessionData = await _sessionManager.getUserSessionData();
//
//       // Set provider data if user is logged in
//       if (sessionData['isLoggedIn']) {
//         final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
//         await authProvider.setUserData(
//           username: sessionData['username'],
//           companyName: sessionData['companyName'],
//           businessType: sessionData['businessType'],
//         );
//       }
//
//       // Determine the initial screen based on session state
//       if (!sessionData['hasCompletedOnboarding']) {
//         _initialScreen = const OnboardingScreen();
//       } else if (!sessionData['isLoggedIn']) {
//         _initialScreen = const LoginScreen();
//       } else if (!sessionData['hasCompletedBusinessSetup']) {
//         _initialScreen = const BusinessSetupScreen();
//       } else {
//         _initialScreen = const HomeScreen();
//       }
//     } catch (e) {
//       print('Error checking user session: $e');
//       _initialScreen = const OnboardingScreen();
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Set system UI settings
//     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//     ));
//
//     if (_isLoading) {
//       return SplashScreen();
//     }
//
//     return _initialScreen ?? const OnboardingScreen();
//   }
// }
//
// /// A simple splash screen shown while checking user session
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Theme.of(context).primaryColor,
//               Theme.of(context).primaryColor.withOpacity(0.7),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // App logo
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Icon(
//                   Icons.business_center,
//                   size: 80,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 24),
//
//               // App name
//               const Text(
//                 'TradeHub',
//                 style: TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//
//               const SizedBox(height: 50),
//
//               // Loading indicator
//               const SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   strokeWidth: 3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }