import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';
import '../../providers/Localization Provider.dart';
import '../../providers/Theme Provider.dart';
import '../../providers/AuthProvider.dart';
import '../Business Setup Screen.dart';
import '../home/Home Screen.dart';
import 'Signup Screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _signupRequired = false;

  // Social login button widget
  Widget _socialLoginButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 54.w,
        height: 54.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 28.sp,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkSignupStatus();
  }

  Future<void> _checkSignupStatus() async {
    final sessionManager = SessionManager();
    final hasSignedUp = await sessionManager.hasSignedUp();
    setState(() {
      _signupRequired = !hasSignedUp;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
        await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          rememberMe: _rememberMe,
        );

        setState(() => _isLoading = false);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => authProvider.hasCompletedBusinessSetup
                ? const HomeScreen()
                : const BusinessSetupScreen(),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);

        // Check if the error is about signup requirement
        if (e.toString().contains('sign up first')) {
          setState(() {
            _signupRequired = true;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;
    final primaryColor = Theme.of(context).primaryColor;
    final textTheme = Theme.of(context).textTheme;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isArabic ? Icons.language : Icons.translate, size: 24.sp),
            onPressed: () => localizationProvider.toggleLanguage(),
            tooltip: isArabic ? 'تغيير اللغة' : 'Change Language',
          ),
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode, size: 24.sp),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: isArabic ? 'تغيير المظهر' : 'Toggle Theme',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 80.h,
                          width: 80.w,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Icon(
                            Icons.business_center,
                            size: 48.sp,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'TradeHub',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.sp,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          isArabic ? 'حلول أعمال متكاملة' : 'Business Solutions',
                          style: textTheme.bodyMedium?.copyWith(
                            color: textTheme.bodySmall?.color,
                            fontSize: 14.sp,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                  Text(
                    isArabic ? 'مرحباً بك مجدداً' : 'Welcome Back',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 28.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isArabic ? 'سعداء برؤيتك مرة أخرى! يرجى تسجيل الدخول لحسابك.' : 'Glad to see you again! Please login to your account.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: textTheme.bodySmall?.color,
                      fontSize: 16.sp,
                    ),
                  ),

                  // Sign up required notice
                  if (_signupRequired) ...[
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.amber, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber, size: 24.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'يجب عليك إنشاء حساب أولاً قبل تسجيل الدخول'
                                  : 'You need to create an account first before logging in',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 32.h),
                  Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12.r),
                    color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                        hintText: isArabic ? 'أدخل بريدك الإلكتروني' : 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined, size: 20.sp, color: primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        floatingLabelStyle: TextStyle(color: primaryColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isArabic ? 'الرجاء إدخال البريد الإلكتروني' : 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return isArabic ? 'الرجاء إدخال بريد إلكتروني صحيح' : 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12.r),
                    color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'كلمة المرور' : 'Password',
                        hintText: isArabic ? 'أدخل كلمة المرور' : 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outline, size: 20.sp, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: primaryColor, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.red.shade400, width: 1),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        floatingLabelStyle: TextStyle(color: primaryColor),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return isArabic ? 'الرجاء إدخال كلمة المرور' : 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return isArabic ? 'كلمة المرور يجب أن تكون على الأقل 6 أحرف' : 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) => setState(() => _rememberMe = value ?? false),
                              activeColor: primaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            isArabic ? 'تذكرني' : 'Remember me',
                            style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          isArabic ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: _isLoading || _signupRequired ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        disabledBackgroundColor: _signupRequired
                            ? Colors.grey.shade400
                            : primaryColor.withOpacity(0.6),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        isArabic ? 'تسجيل الدخول' : 'Login',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          isArabic ? 'أو' : 'OR',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade400, thickness: 1)),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialLoginButton(
                        onTap: () {
                          // Implement Google login
                          print('Google login tapped');
                        },
                        icon: Icons.g_mobiledata_outlined, // Using font_awesome_flutter
                        color: Colors.red,
                      ),
                      SizedBox(width: 20.w),
                      _socialLoginButton(
                        onTap: () {
                          // Implement Apple login
                          print('Apple login tapped');
                        },
                        icon: Icons.apple,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: 20.w),
                      _socialLoginButton(
                        onTap: () {
                          // Implement Microsoft login
                          print('Microsoft login tapped');
                        },
                        icon: Icons.web,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 20.w),
                      _socialLoginButton(
                        onTap: () {
                          // Implement Facebook login
                          print('Facebook login tapped');
                        },
                        icon: Icons.facebook,
                        color: const Color(0xFF1877F2),
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isArabic ? 'ليس لديك حساب؟' : 'Don\'t have an account?',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isArabic ? 'إنشاء حساب' : 'Create Account',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}