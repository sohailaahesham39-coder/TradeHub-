import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Version info
  final String _appVersion = "1.0.0";
  final String _buildNumber = "25";

  // Notification settings
  bool _notifyNewMessages = true;
  bool _notifyOrderUpdates = true;
  bool _notifyEvents = true;
  bool _notifyNewConnections = true;

  // Privacy settings
  bool _showOnlineStatus = true;
  bool _showProfileToConnections = true;
  bool _allowDataCollection = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    setState(() {
      _isLoading = true;
    });

    // Simulate saving settings to backend
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });

      // Show a custom snackbar with animation
      _showCustomSnackBar(
        context,
        Provider.of<LocalizationProvider>(context, listen: false).isArabic
            ? 'تم حفظ الإعدادات بنجاح'
            : 'Settings saved successfully',
      );
    });
  }

  void _showCustomSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<UserAuthProvider>(context);
    final isArabic = localizationProvider.isArabic;

    // Background gradient colors
    final Color gradientStart = themeProvider.isDarkMode
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFEEF5FF);
    final Color gradientEnd = themeProvider.isDarkMode
        ? const Color(0xFF12121C)
        : const Color(0xFFDAE9FA);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.h),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              elevation: 0,
              backgroundColor: themeProvider.isDarkMode
                  ? Colors.black.withOpacity(0.5)
                  : Colors.white.withOpacity(0.5),
              centerTitle: true,
              title: Text(
                isArabic ? 'الإعدادات' : 'Settings',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                ),
              ),
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 22.sp,
                    color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.only(right: 16.w),
                    child: SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [gradientStart, gradientEnd],
          ),
        ),
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primaryBlue,
                      strokeWidth: 3.w,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      isArabic ? 'جارِ حفظ الإعدادات...' : 'Saving settings...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            : FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -50.h,
                  right: -30.w,
                  child: Container(
                    height: 150.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80.h,
                  left: -50.w,
                  child: Container(
                    height: 200.h,
                    width: 200.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(0.15),
                    ),
                  ),
                ),

                // Main content
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAccountSection(context, isArabic, authProvider, themeProvider),
                      SizedBox(height: 24.h),
                      _buildAppearanceSection(context, isArabic, themeProvider, localizationProvider),
                      SizedBox(height: 24.h),
                      _buildNotificationSection(context, isArabic, themeProvider),
                      SizedBox(height: 24.h),
                      _buildPrivacySection(context, isArabic, themeProvider),
                      SizedBox(height: 24.h),
                      _buildSupportSection(context, isArabic, themeProvider),
                      SizedBox(height: 24.h),
                      _buildAboutSection(context, isArabic, themeProvider),
                      SizedBox(height: 36.h),
                      _buildSaveButton(context, isArabic, themeProvider),
                      SizedBox(height: 16.h),
                      _buildLogoutButton(context, isArabic, authProvider, themeProvider),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    required ThemeProvider themeProvider,
    double borderRadius = 16,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(borderRadius.r),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, ThemeProvider themeProvider) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h, left: 5.w, right: 5.w),
      child: Row(
        children: [
          Container(
            height: 20.h,
            width: 4.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(
      BuildContext context, bool isArabic, UserAuthProvider authProvider, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'الحساب' : 'Account', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            children: [
              SizedBox(height: 5.h),
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                leading: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ),
                title: Text(
                  authProvider.username.isEmpty ? 'Mohammed Ahmed' : authProvider.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: AppTheme.successGreen.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Premium',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      // Edit profile logic
                    },
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.business,
                title: isArabic ? 'تفاصيل الشركة' : 'Company Details',
                themeProvider: themeProvider,
                onTap: () {
                  // Navigate to company details
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.security,
                title: isArabic ? 'الأمان وكلمة المرور' : 'Security & Password',
                themeProvider: themeProvider,
                onTap: () {
                  // Navigate to security settings
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      leading: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          icon,
          color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      trailing: trailing ??
          Container(
            width: 28.w,
            height: 28.h,
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
              size: 14.sp,
            ),
          ),
      onTap: onTap,
    );
  }

  Widget _buildAppearanceSection(
      BuildContext context, bool isArabic, ThemeProvider themeProvider, LocalizationProvider localizationProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'المظهر' : 'Appearance', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            children: [
              _buildSwitchTile(
                title: isArabic ? 'الوضع المظلم' : 'Dark Mode',
                subtitle: isArabic ? 'تفعيل المظهر الداكن للتطبيق' : 'Enable dark theme for the app',
                icon: themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                value: themeProvider.isDarkMode,
                themeProvider: themeProvider,
                onChanged: (value) {
                  themeProvider.setTheme(value);
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSwitchTile(
                title: isArabic ? 'اللغة العربية' : 'Arabic Language',
                subtitle: isArabic ? 'استخدام اللغة العربية في التطبيق' : 'Use Arabic language in the app',
                icon: Icons.language,
                value: isArabic,
                themeProvider: themeProvider,
                onChanged: (value) {
                  localizationProvider.toggleLanguage();
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.text_fields,
                title: isArabic ? 'حجم الخط' : 'Text Size',
                themeProvider: themeProvider,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'A',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: themeProvider.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                        size: 14.sp,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to text size settings
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required bool value,
    required ThemeProvider themeProvider,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        secondary: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
            size: 20.sp,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
          ),
        )
            : null,
        value: value,
        activeColor: AppTheme.primaryBlue,
        inactiveTrackColor: themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.3),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, bool isArabic, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'الإشعارات' : 'Notifications', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            children: [
              _buildSwitchTile(
                title: isArabic ? 'رسائل جديدة' : 'New Messages',
                icon: Icons.message,
                value: _notifyNewMessages,
                themeProvider: themeProvider,
                onChanged: (value) {
                  setState(() {
                    _notifyNewMessages = value;
                  });
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSwitchTile(
                title: isArabic ? 'تحديثات الطلبات' : 'Order Updates',
                icon: Icons.shopping_bag,
                value: _notifyOrderUpdates,
                themeProvider: themeProvider,
                onChanged: (value) {
                  setState(() {
                    _notifyOrderUpdates = value;
                  });
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSwitchTile(
                title: isArabic ? 'الفعاليات والأحداث' : 'Events',
                icon: Icons.event,
                value: _notifyEvents,
                themeProvider: themeProvider,
                onChanged: (value) {
                  setState(() {
                    _notifyEvents = value;
                  });
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSwitchTile(
                title: isArabic ? 'طلبات التواصل الجديدة' : 'New Connection Requests',
                icon: Icons.people,
                value: _notifyNewConnections,
                themeProvider: themeProvider,
                onChanged: (value) {
                  setState(() {
                    _notifyNewConnections = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, bool isArabic, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'الخصوصية' : 'Privacy', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            children: [
              _buildSwitchTile(
                title: isArabic ? 'عرض حالة الاتصال' : 'Show Online Status',
                icon: Icons.visibility,
                value: _showOnlineStatus,
                themeProvider: themeProvider,
                onChanged: (value) {
                  setState(() {
                    _showOnlineStatus = value;
                  });
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSwitchTile(
                title: isArabic ? 'إظهار الملف الشخصي للمتصلين' : 'Show Profile to Connections',
                icon: Icons.person_search,
                value: _showProfileToConnections,
                themeProvider: themeProvider,
                onChanged: (value) {
                  setState(() {
                    _showProfileToConnections = value;
                  });
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSwitchTile(
                title: isArabic ? 'السماح بجمع بيانات الاستخدام' : 'Allow Usage Data Collection',
                subtitle: isArabic
                    ? 'مساعدتنا في تحسين التطبيق من خلال مشاركة بيانات الاستخدام'
                    : 'Help us improve by sharing usage data',
                icon: Icons.analytics,
                value: _allowDataCollection,
                themeProvider: themeProvider,
                onChanged: (value) {
                  setState(() {
                    _allowDataCollection = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context, bool isArabic, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'الدعم والمساعدة' : 'Support', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: isArabic ? 'مركز المساعدة' : 'Help Center',
                themeProvider: themeProvider,
                onTap: () {
                  // Navigate to help center
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.chat_bubble_outline,
                title: isArabic ? 'تواصل معنا' : 'Contact Us',
                themeProvider: themeProvider,
                onTap: () {
                  // Navigate to contact us
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: isArabic ? 'الشروط والأحكام' : 'Terms & Conditions',
                themeProvider: themeProvider,
                onTap: () {
                  // Navigate to terms and conditions
                },
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: isArabic ? 'سياسة الخصوصية' : 'Privacy Policy',
                themeProvider: themeProvider,
                onTap: () {
                  // Navigate to privacy policy
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, bool isArabic, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'حول التطبيق' : 'About', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
                leading: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
                    size: 20.sp,
                  ),
                ),
                title: Text(
                  isArabic ? 'إصدار التطبيق' : 'App Version',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$_appVersion (${isArabic ? 'بناء' : 'Build'}: $_buildNumber)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 0.5),
              _buildSettingsTile(
                icon: Icons.system_update,
                title: isArabic ? 'التحقق من التحديثات' : 'Check for Updates',
                themeProvider: themeProvider,
                onTap: () {
                  // Check for updates
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isArabic ? 'أنت تستخدم أحدث إصدار' : 'You are using the latest version',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isArabic, ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBlue,
            Color(0xFF2C7BE5),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: Text(
          isArabic ? 'حفظ الإعدادات' : 'Save Settings',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

// Only the logout part of the SettingsScreen is modified here
// Update the _buildLogoutButton method in the SettingsScreen class

  Widget _buildLogoutButton(
      BuildContext context, bool isArabic, UserAuthProvider authProvider, ThemeProvider themeProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: _buildGlassmorphicContainer(
                  themeProvider: themeProvider,
                  borderRadius: 20,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 20.h),
                      Container(
                        padding: EdgeInsets.all(15.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 30.sp,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        isArabic ? 'تسجيل الخروج' : 'Logout',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Text(
                          isArabic ? 'هل أنت متأكد أنك تريد تسجيل الخروج؟' : 'Are you sure you want to logout?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                      SizedBox(height: 25.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                    side: BorderSide(
                                      color: themeProvider.isDarkMode
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  isArabic ? 'إلغاء' : 'Cancel',
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Implement logout logic here
                                  Navigator.pop(context); // Close dialog

                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  // Logout user
                                  await authProvider.logout();

                                  // Navigate to login screen
                                  if (context.mounted) {
                                    Navigator.of(context).pop(); // Close loading dialog
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/login',
                                          (route) => false,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  isArabic ? 'تسجيل الخروج' : 'Logout',
                                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: Text(
          isArabic ? 'تسجيل الخروج' : 'Logout',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}