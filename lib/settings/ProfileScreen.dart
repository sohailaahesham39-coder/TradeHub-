import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';
import 'package:trade_hub/settings/settings_screen.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;
  int _selectedTabIndex = 0;

  // Business stats data
  final List<Map<String, dynamic>> _businessStats = [
    {'title': 'Connections', 'title_ar': 'العلاقات', 'value': 145, 'icon': Icons.people_alt_outlined, 'color': Colors.blue},
    {'title': 'Products', 'title_ar': 'المنتجات', 'value': 37, 'icon': Icons.inventory_2_outlined, 'color': Colors.green},
    {'title': 'Events', 'title_ar': 'الفعاليات', 'value': 8, 'icon': Icons.event_outlined, 'color': Colors.purple},
    {'title': 'Orders', 'title_ar': 'الطلبات', 'value': 87, 'icon': Icons.shopping_bag_outlined, 'color': Colors.orange},
  ];

  // Recent activities data
  final List<Map<String, dynamic>> _recentActivities = [
    {
      'type': 'connection',
      'title': 'New Connection',
      'title_ar': 'علاقة جديدة',
      'description': 'Connected with "Tech Innovations LLC"',
      'description_ar': 'تم التواصل مع "شركة تيك إنوفيشنز"',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'icon': Icons.people_alt_outlined,
      'color': Colors.blue
    },
    {
      'type': 'product',
      'title': 'Product Listed',
      'title_ar': 'إضافة منتج',
      'description': 'Added "Premium Leather Furniture Set" to inventory',
      'description_ar': 'تمت إضافة "مجموعة أثاث جلدية فاخرة" إلى المخزون',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.inventory_2_outlined,
      'color': Colors.green
    },
    {
      'type': 'order',
      'title': 'Order Completed',
      'title_ar': 'اكتمال الطلب',
      'description': 'Completed order #ORD-1234 for "Dubai Electronics Store"',
      'description_ar': 'تم إكمال الطلب #ORD-1234 لـ "متجر دبي للإلكترونيات"',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'icon': Icons.shopping_bag_outlined,
      'color': Colors.orange
    },
    {
      'type': 'event',
      'title': 'Event Registration',
      'title_ar': 'تسجيل حدث',
      'description': 'Registered for "International Trade Expo 2025"',
      'description_ar': 'تم التسجيل في "معرض التجارة الدولية 2025"',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'icon': Icons.event_outlined,
      'color': Colors.purple
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
    _scrollController.addListener(() => setState(() => _scrollOffset = _scrollController.offset));
    _loadSessionData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Load session data on initialization
  Future<void> _loadSessionData() async {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    final sessionData = await SessionManager().getUserSessionData();
    authProvider.initFromSessionData(sessionData);
  }

  void _refreshData() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
      _showCustomSnackBar(
        context,
        Provider.of<LocalizationProvider>(context, listen: false).isArabic ? 'تم تحديث البيانات بنجاح' : 'Profile updated successfully',
      );
    });
  }

  void _showCustomSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) => Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    boxShadow: [BoxShadow(color: AppTheme.successGreen.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.white, size: 24.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500),
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
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  // Create dynamic user data map from auth provider
  Map<String, dynamic> _createUserDataMap(UserAuthProvider authProvider) {
    return {
      'role': authProvider.businessType.isNotEmpty ? authProvider.businessType : 'Business Owner',
      'memberSince': authProvider.memberSince,
      'email': authProvider.email,
      'phone': authProvider.phone,
      'location': authProvider.location,
      'connections': 145,
      'products': 37,
      'events': 8,
      'completedOrders': 87,
      'rating': 4.8,
      'isPremium': authProvider.isPremium ?? true,
      'about': authProvider.businessType.isNotEmpty
          ? 'Experienced professional in ${authProvider.businessType}. Focusing on international trade and sustainable products.'
          : 'Experienced business owner specializing in international trade. Focusing on electronics, textile, and sustainable products.',
      'expertise': authProvider.businessType.isNotEmpty
          ? [authProvider.businessType, 'Supply Chain Management', 'Market Development', 'Business Networking']
          : ['International Trade', 'Supply Chain Management', 'Market Development', 'Business Networking'],
      'profileImage': authProvider.profileImage.isNotEmpty ? authProvider.profileImage : 'https://via.placeholder.com/150',
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final authProvider = Provider.of<UserAuthProvider>(context);
    final isArabic = localizationProvider.isArabic;

    // Generate user data from auth provider
    final userData = _createUserDataMap(authProvider);

    final Color gradientStart = themeProvider.isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFEEF5FF);
    final Color gradientEnd = themeProvider.isDarkMode ? const Color(0xFF12121C) : const Color(0xFFDAE9FA);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [gradientStart, gradientEnd]),
        ),
        child: _isLoading
            ? Center(
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryBlue, strokeWidth: 3.w),
                SizedBox(height: 16.h),
                Text(
                  isArabic ? 'جارِ التحميل...' : 'Loading...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        )
            : RefreshIndicator(
          onRefresh: () async {
            _refreshData();
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppTheme.primaryBlue,
          backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                Positioned(
                  top: -50.h,
                  right: -30.w,
                  child: Container(
                    height: 150.h,
                    width: 150.w,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                ),
                Positioned(
                  bottom: -80.h,
                  left: -50.w,
                  child: Container(
                    height: 200.h,
                    width: 200.w,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryBlue.withOpacity(0.15)),
                  ),
                ),
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildProfileHeader(context, themeProvider, isArabic, authProvider, userData),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h, bottom: 10.h),
                        child: _buildBusinessStatsSection(context, themeProvider, isArabic),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        child: _buildTabBar(context, themeProvider, isArabic),
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildTabContent(themeProvider, isArabic, authProvider, userData)),
                    SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({
    required ThemeProvider themeProvider,
    required Widget child,
    double borderRadius = 16,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? (themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.65)),
            borderRadius: BorderRadius.circular(borderRadius.r),
            border: Border.all(color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, spreadRadius: 1)],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeProvider themeProvider, bool isArabic, UserAuthProvider authProvider, Map<String, dynamic> userData) {
    final parallaxOffset = _scrollOffset < 0 ? _scrollOffset / 2 : 0.0;
    final fadeRange = math.min(1.0, math.max(0.0, 1 - (_scrollOffset / 100)));

    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.w),
        child: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20.sp),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.edit, color: Colors.white, size: 20.sp),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          },
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(Icons.settings, color: Colors.white, size: 20.sp),
          ),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(0, parallaxOffset),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withOpacity(0.7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20.h,
                      right: -30.w,
                      child: Container(
                        height: 120.h,
                        width: 120.w,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    Positioned(
                      bottom: 30.h,
                      left: -30.w,
                      child: Container(
                        height: 100.h,
                        width: 100.w,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    Positioned(
                      bottom: -5,
                      left: 0,
                      right: 0,
                      child: ClipPath(
                        clipper: WaveClipper(),
                        child: Container(
                          height: 50.h,
                          color: themeProvider.isDarkMode ? const Color(0xFF1E1E2E).withOpacity(0.9) : const Color(0xFFEEF5FF).withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 1 - fadeRange,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10 * (1 - fadeRange), sigmaY: 10 * (1 - fadeRange)),
                child: Container(color: AppTheme.primaryBlue.withOpacity(0.3 * (1 - fadeRange))),
              ),
            ),
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: fadeRange,
                child: Column(
                  children: [
                    Container(
                      width: 110.w,
                      height: 110.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3.w),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(55.r),
                        child: AppImageHandler.loadProfileImage(
                          imageUrl: userData['profileImage'] as String? ?? 'https://via.placeholder.com/150',
                          size: 110.w,
                          placeholderIcon: Icons.person,
                          useShimmerLoading: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          authProvider.username.isNotEmpty ? authProvider.username : 'User Name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(0, 2))],
                          ),
                        ),
                        if (userData['isPremium'] as bool? ?? false)
                          Padding(
                            padding: EdgeInsets.only(left: 6.w),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), shape: BoxShape.circle),
                              child: Icon(Icons.verified, color: Colors.amber, size: 20.sp),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${userData['role'] ?? 'N/A'} | ${authProvider.companyName.isNotEmpty ? authProvider.companyName : 'Company Name'}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5, offset: const Offset(0, 2))],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(20.r)),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.white, size: 14.sp),
                              SizedBox(width: 4.w),
                              Text(
                                userData['location'] as String? ?? 'N/A',
                                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.3), borderRadius: BorderRadius.circular(20.r)),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14.sp),
                              SizedBox(width: 4.w),
                              Text(
                                '${userData['rating'] ?? 0.0}',
                                style: TextStyle(color: Colors.white, fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 1 - fadeRange,
                child: Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 80.w, right: 80.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.w)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18.r),
                          child: AppImageHandler.loadProfileImage(
                            imageUrl: userData['profileImage'] as String? ?? 'https://via.placeholder.com/150',
                            size: 36.w,
                            placeholderIcon: Icons.person,
                            useShimmerLoading: true,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        authProvider.username.isNotEmpty ? authProvider.username : 'User Name',
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessStatsSection(BuildContext context, ThemeProvider themeProvider, bool isArabic) {
    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _businessStats.map((stat) {
          return _buildStatItem(
            icon: stat['icon'] as IconData? ?? Icons.info,
            value: stat['value'] as int? ?? 0,
            title: isArabic ? (stat['title_ar'] as String? ?? 'N/A') : (stat['title'] as String? ?? 'N/A'),
            color: stat['color'] as Color? ?? Colors.grey,
            themeProvider: themeProvider,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required int value, required String title, required Color color, required ThemeProvider themeProvider}) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: Icon(icon, color: color, size: 24.sp)),
        ),
        SizedBox(height: 8.h),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(fontSize: 12.sp, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, ThemeProvider themeProvider, bool isArabic) {
    final tabLabels = [
      isArabic ? 'نبذة عني' : 'About Me',
      isArabic ? 'النشاطات' : 'Activities',
      isArabic ? 'معلومات الاتصال' : 'Contact'
    ];
    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      padding: EdgeInsets.all(8.w),
      child: Row(
        children: List.generate(
          tabLabels.length,
              (index) => Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == index ? AppTheme.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    tabLabels[index],
                    style: TextStyle(
                      color: _selectedTabIndex == index ? Colors.white : themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                      fontSize: 14.sp,
                      fontWeight: _selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ThemeProvider themeProvider, bool isArabic, UserAuthProvider authProvider, Map<String, dynamic> userData) {
    switch (_selectedTabIndex) {
      case 0:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              _buildAboutSection(themeProvider, isArabic, userData),
              SizedBox(height: 24.h),
              _buildExpertiseSection(themeProvider, isArabic, userData),
            ],
          ),
        );
      case 1:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildRecentActivitiesSection(themeProvider, isArabic),
        );
      case 2:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _buildContactInfoSection(themeProvider, isArabic, authProvider, userData),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title, ThemeProvider themeProvider) {
    return Padding(
      padding: EdgeInsets.only(top: 14.h, left: 5.w, right: 5.w),
      child: Row(
        children: [
          Container(
            height: 20.h,
            width: 4.w,
            decoration: BoxDecoration(color: AppTheme.primaryBlue, borderRadius: BorderRadius.circular(2.r)),
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

  Widget _buildAboutSection(ThemeProvider themeProvider, bool isArabic, Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'نبذة عني' : 'About Me', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                userData['about'] as String? ?? 'N/A',
                style: TextStyle(fontSize: 14.sp, height: 1.6, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      print('Navigate to Recommendations');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.rate_review_outlined, color: AppTheme.primaryBlue, size: 16.sp),
                          SizedBox(width: 8.w),
                          Text(
                            isArabic ? 'رؤية التوصيات' : 'View Recommendations',
                            style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseSection(ThemeProvider themeProvider, bool isArabic, Map<String, dynamic> userData) {
    final expertise = userData['expertise'] as List<dynamic>? ?? [];
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'مجالات الخبرة' : 'Expertise', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          child: Column(
            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: expertise.map((skill) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, color: AppTheme.primaryBlue, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text(
                          skill as String? ?? 'N/A',
                          style: TextStyle(fontSize: 13.sp, color: themeProvider.isDarkMode ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),
              Center(
                child: GestureDetector(
                  onTap: () {
                    print('Navigate to Add Skill');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30.r),
                      border: Border.all(color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.3), width: 1.w),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text(
                          isArabic ? 'إضافة مهارة جديدة' : 'Add New Skill',
                          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54, fontSize: 13.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(ThemeProvider themeProvider, bool isArabic) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'النشاطات الأخيرة' : 'Recent Activities', themeProvider),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentActivities.length,
          itemBuilder: (context, index) {
            final activity = _recentActivities[index];
            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: _buildGlassmorphicContainer(
                themeProvider: themeProvider,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.h,
                      decoration: BoxDecoration(
                        color: (activity['color'] as Color? ?? Colors.grey).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: (activity['color'] as Color? ?? Colors.grey).withOpacity(0.3), width: 1.w),
                      ),
                      child: Center(child: Icon(activity['icon'] as IconData? ?? Icons.info, color: activity['color'] as Color? ?? Colors.grey, size: 20.sp)),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? (activity['title_ar'] as String? ?? 'N/A') : (activity['title'] as String? ?? 'N/A'),
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            isArabic ? (activity['description_ar'] as String? ?? 'N/A') : (activity['description'] as String? ?? 'N/A'),
                            style: TextStyle(fontSize: 14.sp, color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 12.sp, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45),
                              SizedBox(width: 4.w),
                              Text(
                                _formatDate(activity['date'] as DateTime? ?? DateTime.now(), isArabic),
                                style: TextStyle(fontSize: 12.sp, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45, size: 14.sp),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(height: 16.h),
        Center(
          child: GestureDetector(
            onTap: () {
              print('Navigate to All Activities');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1.w),
              ),
              child: Text(
                isArabic ? 'عرض جميع النشاطات' : 'View All Activities',
                style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection(ThemeProvider themeProvider, bool isArabic, UserAuthProvider authProvider, Map<String, dynamic> userData) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, isArabic ? 'معلومات الاتصال' : 'Contact Information', themeProvider),
        _buildGlassmorphicContainer(
          themeProvider: themeProvider,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildContactItem(
                icon: Icons.email_outlined,
                title: isArabic ? 'البريد الإلكتروني' : 'Email',
                value: userData['email'] as String? ?? 'N/A',
                themeProvider: themeProvider,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: userData['email'] as String? ?? ''));
                  _showCustomSnackBar(context, isArabic ? 'تم نسخ البريد الإلكتروني' : 'Email copied');
                },
                isFirst: true,
              ),
              Divider(height: 1.h, thickness: 0.5, color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              _buildContactItem(
                icon: Icons.phone_outlined,
                title: isArabic ? 'رقم الهاتف' : 'Phone',
                value: userData['phone'] as String? ?? 'N/A',
                themeProvider: themeProvider,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: userData['phone'] as String? ?? ''));
                  _showCustomSnackBar(context, isArabic ? 'تم نسخ رقم الهاتف' : 'Phone number copied');
                },
              ),
              Divider(height: 1.h, thickness: 0.5, color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              _buildContactItem(
                icon: Icons.location_on_outlined,
                title: isArabic ? 'الموقع' : 'Location',
                value: userData['location'] as String? ?? 'N/A',
                themeProvider: themeProvider,
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: userData['location'] as String? ?? ''));
                  _showCustomSnackBar(context, isArabic ? 'تم نسخ الموقع' : 'Location copied');
                },
              ),
              Divider(height: 1.h, thickness: 0.5, color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              _buildContactItem(
                icon: Icons.calendar_today_outlined,
                title: isArabic ? 'عضو منذ' : 'Member Since',
                value: _formatMemberSince(userData['memberSince'] as DateTime? ?? DateTime.now(), isArabic),
                themeProvider: themeProvider,
                onCopy: () {
                  Clipboard.setData(ClipboardData(
                      text: _formatMemberSince(userData['memberSince'] as DateTime? ?? DateTime.now(), isArabic)));
                  _showCustomSnackBar(context, isArabic ? 'تم نسخ تاريخ العضوية' : 'Member since date copied');
                },
                isLast: true,
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        _buildConnectButtons(themeProvider, isArabic),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required ThemeProvider themeProvider,
    required VoidCallback onCopy,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: AppTheme.primaryBlue, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.content_copy, color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45, size: 18.sp),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButtons(ThemeProvider themeProvider, bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              print('Navigate to Messaging');
            },
            child: _buildGlassmorphicContainer(
              themeProvider: themeProvider,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, color: AppTheme.primaryBlue, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    isArabic ? 'مراسلة' : 'Message',
                    style: TextStyle(color: AppTheme.primaryBlue, fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _showCustomSnackBar(context, isArabic ? 'تم إرسال طلب الاتصال' : 'Connection request sent');
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppTheme.primaryBlue, const Color(0xFF2C7BE5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 10, spreadRadius: 0, offset: const Offset(0, 4))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    isArabic ? 'إضافة علاقة' : 'Connect',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date, bool isArabic) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return isArabic ? 'منذ ${difference.inMinutes} دقيقة' : '${difference.inMinutes} minutes ago';
      }
      return isArabic ? 'منذ ${difference.inHours} ساعة' : '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return isArabic ? 'منذ ${difference.inDays} يوم' : '${difference.inDays} days ago';
    } else {
      final dateFormat = DateFormat.yMMMd(isArabic ? 'ar' : 'en');
      return dateFormat.format(date);
    }
  }

  String _formatMemberSince(DateTime date, bool isArabic) {
    final dateFormat = DateFormat.yMMMM(isArabic ? 'ar' : 'en');
    return dateFormat.format(date);
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    final firstControlPoint = Offset(size.width * 0.75, size.height * 0.5);
    final firstEndPoint = Offset(size.width * 0.5, 0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    final secondControlPoint = Offset(size.width * 0.25, size.height * -0.5);
    final secondEndPoint = Offset(0, 0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: const Center(
        child: Text('Edit Profile Screen - To Be Implemented'),
      ),
    );
  }
}