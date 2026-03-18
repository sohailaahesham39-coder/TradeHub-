import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/models/Event%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/screens/ChatScreen.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';
import 'package:trade_hub/settings/ProfileScreen.dart';
import 'package:trade_hub/settings/settings_screen.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';
import '../../models/Product Model.dart';
import '../../search/Search Screen.dart';
import '../events/Events Screen.dart';
import '../inventory/Inventory Screen.dart';
import '../auth/Login Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showAppBarShadow = false;
  final SessionManager _sessionManager = SessionManager();

  final Map<String, String> _placeholderImages = {
    'chair': 'https://i.pinimg.com/736x/06/3f/a3/063fa3406db85d5d3c6d2b8f41414960.jpg',
    'bulbs': 'https://i.pinimg.com/736x/e0/c7/68/e0c768d866699a23a77768bd04775b1e.jpg',
    'tea': 'https://i.pinimg.com/736x/84/be/30/84be3089a3dada088daa76eab5d01b98.jpg',
    'charger': 'https://i.pinimg.com/736x/2a/11/9d/2a119ddf59577d581a35c622cf56987d.jpg',
    'profile': 'https://i.pinimg.com/736x/d2/54/e5/d254e5c08e0bcc1f14dbf274346020b2.jpg',
  };

  final List<Product> _trendingProducts = [
    Product(
      id: '1',
      name: 'Premium Leather Chairs',
      category: 'Furniture',
      price: 299.99,
      quantity: 45,
      imageUrl: 'https://i.pinimg.com/736x/06/3f/a3/063fa3406db85d5d3c6d2b8f41414960.jpg',
      supplierId: 'sup001',
      supplierName: 'Modern Furnishings Ltd',
    ),
    Product(
      id: '2',
      name: 'Smart LED Bulbs (5-Pack)',
      category: 'Electronics',
      price: 59.99,
      quantity: 120,
      imageUrl: 'https://i.pinimg.com/736x/e0/c7/68/e0c768d866699a23a77768bd04775b1e.jpg',
      supplierId: 'sup002',
      supplierName: 'EcoLight Systems',
    ),
    Product(
      id: '3',
      name: 'Organic Green Tea (Bulk)',
      category: 'Food & Beverages',
      price: 45.50,
      quantity: 80,
      imageUrl: 'https://i.pinimg.com/736x/84/be/30/84be3089a3dada088daa76eab5d01b98.jpg',
      supplierId: 'sup003',
      supplierName: 'Natural Harvests Co.',
    ),
    Product(
      id: '4',
      name: 'Wireless Charging Pad',
      category: 'Electronics',
      price: 29.99,
      quantity: 65,
      imageUrl: 'https://i.pinimg.com/736x/2a/11/9d/2a119ddf59577d581a35c622cf56987d.jpg',
      supplierId: 'sup004',
      supplierName: 'TechGear Solutions',
    ),
  ];

  final List<Event> _upcomingEvents = [
    Event(
      id: '1',
      title: 'Annual Business Conference',
      description: 'Join the biggest B2B networking event of the year with industry leaders and innovators.',
      date: DateTime.now().add(const Duration(days: 15)),
      location: 'Grand Convention Center, Dubai',
      imageUrl: 'https://i.pinimg.com/736x/35/8e/99/358e99dd6268f98d9182b55a13f0b0c6.jpg',
      ticketPrice: 149.99,
      totalAttendees: 450,
      organizerId: 'org001',
      organizerName: 'Business Growth Network',
    ),
    Event(
      id: '2',
      title: 'Supply Chain Management Workshop',
      description: 'Learn effective strategies to optimize your supply chain and reduce operational costs.',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Business Innovation Center, Abu Dhabi',
      imageUrl: 'https://i.pinimg.com/736x/cb/c5/5c/cbc55c268b4ff623cd4765e3e3c6ccb0.jpg',
      ticketPrice: 79.99,
      totalAttendees: 120,
      organizerId: 'org002',
      organizerName: 'Logistics Professionals Association',
    ),
    Event(
      id: '3',
      title: 'International Trade Expo',
      description: 'Showcase your products to international buyers and expand your global presence.',
      date: DateTime.now().add(const Duration(days: 30)),
      location: 'International Exhibition Center, Riyadh',
      imageUrl: 'https://i.pinimg.com/736x/0e/05/6b/0e056bd3d332590b079ac0389446b2d4.jpg',
      ticketPrice: 199.99,
      totalAttendees: 800,
      organizerId: 'org003',
      organizerName: 'Global Trade Authority',
    ),
  ];

  final Map<String, dynamic> _inventorySummary = {
    'totalProducts': 142,
    'totalCategories': 8,
    'lowStock': 12,
    'outOfStock': 3,
    'topCategory': 'Electronics',
    'recentlyAdded': 5,
    'totalValue': 58750.00,
  };

  final List<Map<String, dynamic>> _recentConnections = [
    {
      'id': 'user1',
      'name': 'Ahmed Trading Co.',
      'type': 'Distributor',
      'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'location': 'Dubai, UAE',
    },
    {
      'id': 'user2',
      'name': 'Green Earth Supplies',
      'type': 'Supplier',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'location': 'Riyadh, KSA',
    },
    {
      'id': 'user3',
      'name': 'Tech Innovations Ltd',
      'type': 'Business Owner',
      'avatar': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'location': 'Abu Dhabi, UAE',
    },
    {
      'id': 'user4',
      'name': 'Global Logistics Co.',
      'type': 'Distributor',
      'avatar': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
      'location': 'Doha, Qatar',
    },
  ];

  final Map<String, dynamic> _businessStats = {
    'connectionRequests': 5,
    'newMessages': 8,
    'pendingOrders': 3,
    'savedItems': 12,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    _patchProductImages();

    _scrollController.addListener(() {
      setState(() {
        _showAppBarShadow = _scrollController.offset > 0;
      });
    });

    _refreshUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshUserData() async {
    try {
      final sessionData = await _sessionManager.getUserSessionData();
      if (!sessionData['isLoggedIn']) {
        _handleSessionExpired();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSessionExpired() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session expired. Please log in again.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
      await authProvider.logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _patchProductImages() {
    for (var product in _trendingProducts) {
      if (product.imageUrl.contains('chair.jpg')) {
        product.imageUrl = _placeholderImages['chair']!;
      } else if (product.imageUrl.contains('bulbs.jpg')) {
        product.imageUrl = _placeholderImages['bulbs']!;
      } else if (product.imageUrl.contains('tea.jpg')) {
        product.imageUrl = _placeholderImages['tea']!;
      } else if (product.imageUrl.contains('charger.jpg')) {
        product.imageUrl = _placeholderImages['charger']!;
      }
    }
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      _showCustomSnackBar(
        context,
        Provider.of<LocalizationProvider>(context, listen: false).isArabic
            ? 'تم تحديث البيانات بنجاح'
            : 'Data refreshed successfully',
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

    final backgroundColor = themeProvider.isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF9FAFC);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: themeProvider.isDarkMode ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
        onRefresh: () async {
          _refreshData();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SafeArea(
          child: _isLoading
              ? _buildLoadingIndicator(themeProvider, isArabic)
              : NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [_buildAppBar(context, themeProvider)];
            },
            body: FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: 16.h),
                        _buildWelcomeSection(context, authProvider, themeProvider),
                        SizedBox(height: 24.h),
                        _buildQuickStats(context, themeProvider),
                        SizedBox(height: 28.h),
                        _buildInventorySummaryCard(context, themeProvider),
                        SizedBox(height: 28.h),
                        _buildSectionHeader(
                          context,
                          isArabic ? 'المنتجات الرائجة' : 'Trending Products',
                          themeProvider: themeProvider,
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const InventoryScreen()),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildTrendingProducts(context, isArabic, themeProvider),
                        SizedBox(height: 28.h),
                        _buildRecentConnections(context, themeProvider),
                        SizedBox(height: 28.h),
                        _buildSectionHeader(
                          context,
                          isArabic ? 'الفعاليات القادمة' : 'Upcoming Events',
                          themeProvider: themeProvider,
                          onViewAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EventsScreen()),
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildEventsSection(context, themeProvider),
                        SizedBox(height: 28.h),
                        _buildBusinessTipsBanner(context, themeProvider),
                        SizedBox(height: 30.h),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _handleBottomNavTap(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12.sp,
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: isArabic ? 'الرئيسية' : 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: isArabic ? 'بحث' : 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            activeIcon: Icon(Icons.event_note),
            label: isArabic ? 'الفعاليات' : 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: isArabic ? 'المخزون' : 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: isArabic ? 'المحادثات' : 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle_outlined),
            activeIcon: Icon(Icons.supervised_user_circle),
            label: isArabic ? 'الملف الشخصي' : 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == _currentIndex && index == 0) return; // Already on HomeScreen

    switch (index) {
      case 0:
      // Already on HomeScreen, reset index
        setState(() {
          _currentIndex = 0;
        });
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const InventoryScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildLoadingIndicator(ThemeProvider themeProvider, bool isArabic) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: themeProvider.isDarkMode
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50.w,
              height: 50.h,
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 3.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'جارِ تحديث البيانات...' : 'Refreshing data...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeProvider themeProvider) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
      elevation: _showAppBarShadow ? 2 : 0,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.business_center,
              color: AppTheme.primaryColor,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'TradeHub',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.search,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  size: 20.sp,
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications coming soon')),
                );
              },
            ),
            Positioned(
              right: 8.w,
              top: 8.h,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, UserAuthProvider authProvider, ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;
    final username = authProvider.username.isNotEmpty ? authProvider.username : 'User';
    final companyName = authProvider.companyName.isNotEmpty ? authProvider.companyName : 'Your Company';

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
                        ? 'لديك ${_businessStats['connectionRequests']} طلبات اتصال و ${_businessStats['newMessages']} رسائل جديدة'
                        : 'You have ${_businessStats['connectionRequests']} connection requests and ${_businessStats['newMessages']} new messages',
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
                Container(
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
                    child: AppImageHandler.loadProfileImage(
                      imageUrl: authProvider.profileImage.isNotEmpty
                          ? authProvider.profileImage
                          : _placeholderImages['profile']!,
                      size: 65.r,
                      borderWidth: 0,
                      showBorder: false,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
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

  Widget _buildQuickStats(BuildContext context, ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: themeProvider.isDarkMode
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'لمحة سريعة' : 'Quick Stats',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatColumn(
                icon: Icons.people_alt_outlined,
                value: _businessStats['connectionRequests'].toString(),
                label: isArabic ? 'طلبات التواصل' : 'Requests',
                color: Colors.blue,
                themeProvider: themeProvider,
              ),
              _buildStatColumn(
                icon: Icons.message_outlined,
                value: _businessStats['newMessages'].toString(),
                label: isArabic ? 'رسائل جديدة' : 'Messages',
                color: Colors.green,
                themeProvider: themeProvider,
              ),
              _buildStatColumn(
                icon: Icons.shopping_bag_outlined,
                value: _businessStats['pendingOrders'].toString(),
                label: isArabic ? 'طلبات معلقة' : 'Orders',
                color: Colors.orange,
                themeProvider: themeProvider,
              ),
              _buildStatColumn(
                icon: Icons.bookmark_border,
                value: _businessStats['savedItems'].toString(),
                label: isArabic ? 'عناصر محفوظة' : 'Saved',
                color: Colors.purple,
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required ThemeProvider themeProvider,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 22.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildInventorySummaryCard(BuildContext context, ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, Color(0xFF3B82F6)],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'ملخص المخزون' : 'Inventory Summary',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InventoryScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      isArabic ? 'تقرير كامل' : 'Full Report',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInventoryStat(
                  label: isArabic ? 'إجمالي المنتجات' : 'Total Products',
                  value: _inventorySummary['totalProducts'].toString(),
                  color: Colors.white,
                ),
                _buildInventoryStat(
                  label: isArabic ? 'مخزون منخفض' : 'Low Stock',
                  value: _inventorySummary['lowStock'].toString(),
                  color: Colors.white,
                ),
                _buildInventoryStat(
                  label: isArabic ? 'نفاد المخزون' : 'Out of Stock',
                  value: _inventorySummary['outOfStock'].toString(),
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: 0.65,
                minHeight: 6.h,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isArabic ? 'حالة المخزون' : 'Inventory Health',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  '65%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentConnections(BuildContext context, ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: themeProvider.isDarkMode
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'آخر الاتصالات' : 'Recent Connections',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? 'عرض جميع الاتصالات' : 'View all connections'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  isArabic ? 'عرض الكل' : 'View All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 102.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentConnections.length,
              itemBuilder: (context, index) {
                final connection = _recentConnections[index];
                return Container(
                  width: 90.w,
                  margin: EdgeInsets.only(right: 16.w),
                  child: Column(
                    children: [
                      AppImageHandler.loadProfileImage(
                        imageUrl: connection['avatar'],
                        size: 55.r,
                        borderColor: AppTheme.primaryColor.withOpacity(0.2),
                        borderWidth: 2,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        connection['name'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        connection['type'],
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context,
      String title, {
        required ThemeProvider themeProvider,
        VoidCallback? onViewAll,
      }) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isArabic ? 'عرض الكل' : 'View All',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingProducts(BuildContext context, bool isArabic, ThemeProvider themeProvider) {
    return SizedBox(
      height: 220.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingProducts.length,
        itemBuilder: (context, index) {
          final product = _trendingProducts[index];
          return GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product: ${product.name}'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: 160.w,
              margin: EdgeInsets.only(right: 16.w),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: themeProvider.isDarkMode
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    child: AppImageHandler.loadProductImage(
                      imageUrl: product.imageUrl,
                      width: 160.w,
                      height: 120.h,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: themeProvider.isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsSection(BuildContext context, ThemeProvider themeProvider) {
    return SizedBox(
      height: 240.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _upcomingEvents.length,
        itemBuilder: (context, index) {
          final event = _upcomingEvents[index];
          return Container(
            width: 280.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: themeProvider.isDarkMode
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16.r),
                        topRight: Radius.circular(16.r),
                      ),
                      child: AppImageHandler.loadEventImage(
                        imageUrl: event.imageUrl,
                        width: 280.w,
                        height: 150.h,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                        overlayContent: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  '${event.date.day} ${_getMonthName(event.date.month)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                event.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.5),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '\$${event.ticketPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16.sp,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.people_outline,
                        size: 16.sp,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${event.totalAttendees}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildBusinessTipsBanner(BuildContext context, ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Container(
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: themeProvider.isDarkMode
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline,
              color: AppTheme.primaryColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'نصيحة اليوم' : 'Business Tip of the Day',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isArabic
                      ? 'قم بتحسين شبكتك من خلال التواصل المنتظم مع الموردين'
                      : 'Enhance your network by regularly connecting with suppliers',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}