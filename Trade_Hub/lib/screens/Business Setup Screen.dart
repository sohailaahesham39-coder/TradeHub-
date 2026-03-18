import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/screens/home/Home%20Screen.dart';
import 'package:trade_hub/settings/settings_screen.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({Key? key}) : super(key: key);

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  String _selectedBusinessType = 'business_owner';
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _businessTypes = [
    'business_owner',
    'supplier',
    'distributor',
  ];

  final Map<String, String> _typeImages = {
    'business_owner': 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'supplier': 'https://images.unsplash.com/photo-1553413077-190dd305871c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'distributor': 'https://images.unsplash.com/photo-1580674285054-bed31e145f59?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppImageHandler.preloadImages(context, _typeImages.values.toList());
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _setupBusiness() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
        await authProvider.completeBusinessSetup(
          companyName: _businessNameController.text.trim(),
          businessType: _selectedBusinessType,
        );

        // Optionally complete onboarding if this is the first setup
        if (authProvider.isFirstLaunch) {
          await authProvider.completeOnboarding();
        }

        setState(() => _isLoading = false);

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(e.toString());
      }
    }
  }

  void _showErrorSnackBar(String errorMessage) {
    final isArabic = Provider.of<LocalizationProvider>(context, listen: false).isArabic;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'فشل الإعداد: $errorMessage' : 'Setup failed: $errorMessage',
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: isArabic ? 'حسناً' : 'OK',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  IconData _getIconForBusinessType(String type) {
    switch (type) {
      case 'business_owner':
        return Icons.business;
      case 'supplier':
        return Icons.inventory_2_outlined;
      case 'distributor':
        return Icons.local_shipping_outlined;
      default:
        return Icons.business_outlined;
    }
  }

  String _getBusinessTypeName(String type, bool isArabic) {
    if (isArabic) {
      switch (type) {
        case 'business_owner':
          return 'صاحب الأعمال';
        case 'supplier':
          return 'مورّد';
        case 'distributor':
          return 'موزّع';
        default:
          return 'نوع الأعمال';
      }
    } else {
      switch (type) {
        case 'business_owner':
          return 'Business Owner';
        case 'supplier':
          return 'Supplier';
        case 'distributor':
          return 'Distributor';
        default:
          return 'Business Type';
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
    final isDarkMode = themeProvider.isDarkMode;

    return WillPopScope(
      onWillPop: () async => false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            isArabic ? 'إعداد الأعمال' : 'Business Setup',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(
                isArabic ? Icons.language : Icons.translate,
                size: 24.sp,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
              onPressed: () => localizationProvider.toggleLanguage(),
              tooltip: isArabic ? 'تغيير اللغة' : 'Change Language',
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 90.h,
                            width: 90.w,
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: isDarkMode
                                  ? []
                                  : [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 1,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.business_center,
                              size: 54.sp,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'TradeHub',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 28.sp,
                              letterSpacing: 1.2,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.05) : primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: isDarkMode ? Colors.white.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: primaryColor, size: 24.sp),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'قم بإعداد حساب عملك للبدء في استخدام تريد هب'
                                  : 'Set up your business account to start using TradeHub',
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 15.sp,
                                color: isDarkMode ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      isArabic ? 'نوع الأعمال' : 'Business Type',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isArabic ? 'اختر نوع عملك من الخيارات أدناه' : 'Select your business type from the options below',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: isDarkMode ? Colors.white60 : Colors.black54),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _businessTypes
                          .map((type) => _buildEnhancedBusinessTypeOption(context, type, isArabic, primaryColor, isDarkMode))
                          .toList(),
                    ),
                    SizedBox(height: 40.h),
                    Text(
                      isArabic ? 'اسم العمل' : 'Business Name',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 20.sp,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isArabic ? 'أدخل اسم شركتك أو مؤسستك' : 'Enter your company or organization name',
                      style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp, color: isDarkMode ? Colors.white60 : Colors.black54),
                    ),
                    SizedBox(height: 16.h),
                    Material(
                      elevation: isDarkMode ? 0 : 2,
                      shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                      child: TextFormField(
                        controller: _businessNameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(fontSize: 16.sp, color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: isArabic ? 'اسم الشركة' : 'Company Name',
                          hintText: isArabic ? 'أدخل اسم شركتك' : 'Enter your company name',
                          prefixIcon: Icon(Icons.business, size: 22.sp, color: primaryColor),
                          labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 16.sp),
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white30 : Colors.black38, fontSize: 16.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.grey.shade300, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(color: primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                          floatingLabelStyle: TextStyle(color: primaryColor, fontSize: 16.sp),
                          filled: true,
                          fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return isArabic ? 'الرجاء إدخال اسم الشركة' : 'Please enter your company name';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 50.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _setupBusiness,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: isDarkMode ? 0 : 3,
                          shadowColor: primaryColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          disabledBackgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                        ),
                        child: _isLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 22.h,
                              width: 22.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5.w,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              isArabic ? 'جاري إنشاء الحساب...' : 'Creating account...',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        )
                            : Text(
                          isArabic ? 'إنشاء حساب الأعمال' : 'Create Business Account',
                          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedBusinessTypeOption(
      BuildContext context,
      String type,
      bool isArabic,
      Color primaryColor,
      bool isDarkMode,
      ) {
    final isSelected = _selectedBusinessType == type;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => setState(() => _selectedBusinessType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? primaryColor : isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade300,
            width: isSelected ? 2.w : 1.w,
          ),
          boxShadow: [
            if (!isSelected && !isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15.r,
                spreadRadius: 1.r,
                offset: Offset(0, 5.h),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: isSelected && !isDarkMode
                    ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 12.r,
                    spreadRadius: 2.r,
                    offset: Offset(0, 4.h),
                  ),
                ]
                    : [],
              ),
              child: Icon(
                _getIconForBusinessType(type),
                color: isSelected ? Colors.white : primaryColor,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _getBusinessTypeName(type, isArabic),
              style: TextStyle(
                color: isSelected ? primaryColor : isDarkMode ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  } Widget _buildWelcomeSection(BuildContext context, UserAuthProvider authProvider, ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;
    final username = authProvider.username.isNotEmpty ? authProvider.username : 'User';
    final companyName = authProvider.companyName.isNotEmpty ? authProvider.companyName : 'Your Company';
    final businessType = authProvider.businessType;

    // Business stats for notifications
    final Map<String, int> businessStats = {
      'connectionRequests': 5,
      'newMessages': 8,
    };

    // Business type images
    final Map<String, String> businessTypeImages = {
      'business_owner': 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'supplier': 'https://images.unsplash.com/photo-1553413077-190dd305871c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'distributor': 'https://images.unsplash.com/photo-1580674285054-bed31e145f59?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    };

    // Get the correct image URL based on business type
    String getBusinessTypeImage() {
      // Convert to lowercase and remove any spaces for safer comparison
      String normalizedType = businessType.toLowerCase().replaceAll(' ', '_');

      // Return the corresponding image URL or a default one if not found
      return businessTypeImages[normalizedType] ??
          // Default image if no matching business type
          'https://images.unsplash.com/photo-1560179707-f14e90ef3623?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80';
    }

    // Logout confirmation dialog
    Future<bool> _showLogoutConfirmDialog(BuildContext context, bool isArabic) async {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            isArabic ? 'تسجيل الخروج' : 'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            isArabic
                ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟'
                : 'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                isArabic ? 'إلغاء' : 'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(
                isArabic ? 'تسجيل الخروج' : 'Logout',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ) ?? false; // Default to false if dialog is dismissed
    }

    // Show profile action menu
    void _showProfileMenu() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              // Profile menu item
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  size: 24.sp,
                ),
                title: Text(
                  isArabic ? 'الملف الشخصي' : 'Profile',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: themeProvider.isDarkMode ? Colors.white30 : Colors.black26,
                  size: 16.sp,
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),

              // Business settings menu item
              ListTile(
                leading: Icon(
                  Icons.business,
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  size: 24.sp,
                ),
                title: Text(
                  isArabic ? 'إعدادات العمل' : 'Business Settings',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: themeProvider.isDarkMode ? Colors.white30 : Colors.black26,
                  size: 16.sp,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to business settings
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const BusinessSettingsScreen()),
                  // );
                },
              ),

              // Help & Support menu item
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  size: 24.sp,
                ),
                title: Text(
                  isArabic ? 'المساعدة والدعم' : 'Help & Support',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: themeProvider.isDarkMode ? Colors.white30 : Colors.black26,
                  size: 16.sp,
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to help screen
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const HelpScreen()),
                  // );
                },
              ),

              Divider(
                color: Colors.grey.withOpacity(0.2),
                thickness: 1,
                indent: 16.w,
                endIndent: 16.w,
              ),

              // Logout menu item
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 24.sp,
                ),
                title: Text(
                  isArabic ? 'تسجيل الخروج' : 'Logout',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.red,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: themeProvider.isDarkMode ? Colors.white30 : Colors.black26,
                  size: 16.sp,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // Confirm logout dialog
                  bool confirm = await _showLogoutConfirmDialog(context, isArabic);
                  if (confirm) {
                    await authProvider.logout();
                    // Navigate to login screen
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                          (route) => false,
                    );
                  }
                },
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.9),
            AppTheme.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? 'مرحباً، $username!' : 'Hello, $username!',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    companyName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    isArabic
                        ? 'لديك ${businessStats['connectionRequests']} طلبات اتصال و ${businessStats['newMessages']} رسائل جديدة'
                        : 'You have ${businessStats['connectionRequests']} connection requests and ${businessStats['newMessages']} new messages',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _showProfileMenu,
                  child: Container(
                    width: 65.w,
                    height: 65.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.8),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40.r),
                      child: authProvider.profileImage.isNotEmpty
                          ? Image.network(
                        authProvider.profileImage,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            getBusinessTypeImage(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.business,
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                              );
                            },
                          );
                        },
                      )
                          : Image.network(
                        getBusinessTypeImage(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.business,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: themeProvider.isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: _showProfileMenu,
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}