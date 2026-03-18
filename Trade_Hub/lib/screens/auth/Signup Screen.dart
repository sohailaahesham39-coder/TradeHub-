import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../providers/Localization Provider.dart';
import '../../providers/Theme Provider.dart';
import '../../providers/AuthProvider.dart';
import 'Login Screen.dart';
import '../Business Setup Screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  bool _isLoading = false;

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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() => _isPasswordVisible = !_isPasswordVisible);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
        await authProvider.setUserData(
          username: _nameController.text.trim(),
          companyName: '', // Company name will be set in BusinessSetupScreen
        );

        setState(() => _isLoading = false);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const BusinessSetupScreen()),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LocalizationProvider>(context, listen: false).isArabic
                ? 'يرجى الموافقة على الشروط والأحكام'
                : 'Please accept the terms and conditions',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        ),
      );
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isArabic ? Icons.language : Icons.translate,
              size: 24.sp,
              color: textTheme.bodyLarge?.color,
            ),
            onPressed: () => localizationProvider.toggleLanguage(),
            tooltip: isArabic ? 'تغيير اللغة' : 'Change Language',
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 24.sp,
              color: textTheme.bodyLarge?.color,
            ),
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
                  SizedBox(height: 16.h),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 60.h,
                          width: 60.w,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Icon(
                            Icons.business_center,
                            size: 36.sp,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'TradeHub',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22.sp,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    isArabic ? 'إنشاء حساب' : 'Create Account',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 28.sp,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isArabic ? 'أنشئ حسابك للوصول إلى ميزات تريد هب!' : 'Create your account to access TradeHub features!',
                    style: textTheme.bodyLarge?.copyWith(
                      color: textTheme.bodySmall?.color,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12.r),
                    color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                    child: TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'الاسم الكامل' : 'Full Name',
                        hintText: isArabic ? 'أدخل اسمك الكامل' : 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline, size: 20.sp, color: primaryColor),
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
                          return isArabic ? 'الرجاء إدخال الاسم الكامل' : 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
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
                  SizedBox(height: 16.h),
                  Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12.r),
                    color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.next,
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
                  Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(12.r),
                    color: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      textInputAction: TextInputAction.done,
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                        labelText: isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
                        hintText: isArabic ? 'أعد إدخال كلمة المرور' : 'Re-enter your password',
                        prefixIcon: Icon(Icons.lock_outline, size: 20.sp, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20.sp,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
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
                          return isArabic ? 'الرجاء تأكيد كلمة المرور' : 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return isArabic ? 'كلمة المرور غير متطابقة' : 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
                          activeColor: primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          isArabic ? 'أوافق على شروط الخدمة وسياسة الخصوصية' : 'I agree to the Terms of Service and Privacy Policy',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
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
                        isArabic ? 'إنشاء حساب' : 'Create Account',
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
                          // Implement Google signup (e.g., with Firebase)
                          print('Google signup tapped');
                        },
                        icon: Icons.g_mobiledata_outlined, // Using font_awesome_flutter
                        color: Colors.red,
                      ),
                      SizedBox(width: 20.w),
                      _socialLoginButton(
                        onTap: () {
                          // Implement Apple signup
                          print('Apple signup tapped');
                        },
                        icon: Icons.apple,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                      SizedBox(width: 20.w),
                      _socialLoginButton(
                        onTap: () {
                          // Implement Microsoft signup
                          print('Microsoft signup tapped');
                        },
                        icon: Icons.web,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 20.w),
                      _socialLoginButton(
                        onTap: () {
                          // Implement Facebook signup
                          print('Facebook signup tapped');
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
                          isArabic ? 'لديك حساب بالفعل؟' : 'Already have an account?',
                          style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen())),
                          style: TextButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            isArabic ? 'تسجيل الدخول' : 'Login',
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