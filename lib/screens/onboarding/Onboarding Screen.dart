import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';

import '../../providers/Localization Provider.dart';
import '../../test/unit/AppImageHandler Utility .dart';
import '../auth/Login Screen.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  bool _isLastPage = false;
  final SessionManager _sessionManager = SessionManager();

  final List<OnboardingData> _onboardingPages = [
    OnboardingData(
      title: 'Connect with Business Partners',
      description: 'Find and connect with suppliers, distributors, and business owners all in one place to expand your network.',
      image: 'https://example.com/images/tradehub/onboarding1.jpg',
      bgColor: const Color(0xFF3871E0),
      icon: Icons.people_outline,
    ),
    OnboardingData(
      title: 'Manage Your Inventory',
      description: 'Keep track of your products and services with our powerful inventory management system for better business control.',
      image: 'https://example.com/images/tradehub/onboarding2.jpg',
      bgColor: const Color(0xFF4ECDC4),
      icon: Icons.inventory_2_outlined,
    ),
    OnboardingData(
      title: 'Discover Business Events',
      description: 'Explore, book, and organize business events to expand your network and grow your business opportunities.',
      image: 'https://example.com/images/tradehub/onboarding3.jpg',
      bgColor: const Color(0xFF7B68EE),
      icon: Icons.event_note_outlined,
    ),
    OnboardingData(
      title: 'Secure Payment Processing',
      description: 'Book event tickets and process payments securely within the app using multiple payment methods.',
      image: 'https://example.com/images/tradehub/onboarding4.jpg',
      bgColor: const Color(0xFF2ECC71),
      icon: Icons.payment_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _onboardingPages[0].bgColor,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _pageController.addListener(() {
      if (_pageController.page!.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
          _isLastPage = _currentPage == _onboardingPages.length - 1;

          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            systemNavigationBarColor: _onboardingPages[_currentPage].bgColor,
            systemNavigationBarIconBrightness: Brightness.light,
          ));
        });

        _animationController.reset();
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Modified to mark onboarding as completed
  Future<void> _navigateToLogin() async {
    // Mark onboarding as completed
    await _sessionManager.completeOnboarding();

    // Update AuthProvider
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    await authProvider.completeOnboarding();

    // Navigate to login screen
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

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingPages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
                _isLastPage = page == _onboardingPages.length - 1;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_onboardingPages[index]);
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isArabic ? Icons.language : Icons.translate,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        localizationProvider.toggleLocale;
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToLogin, // Using the updated method
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      isArabic ? 'تخطي' : 'Skip',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(context),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            data.bgColor,
            data.bgColor.withOpacity(0.8),
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              if (data.image.isNotEmpty) ...[
                Hero(
                  tag: 'onboarding_image_${data.title}',
                  child: Container(
                    height: 280,
                    width: 280,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: AppImageHandler.loadNetworkImage(
                      imageUrl: data.image,
                      height: 240,
                      width: 240,
                      fit: BoxFit.contain,
                      placeholderIcon: data.icon,
                      borderRadius: BorderRadius.circular(20),
                      backgroundColor: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    data.icon,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(30),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      Provider.of<LocalizationProvider>(context).isArabic
                          ? _getArabicTitle(data.title)
                          : data.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Provider.of<LocalizationProvider>(context).isArabic
                          ? _getArabicDescription(data.description)
                          : data.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _onboardingPages[_currentPage].bgColor.withOpacity(0),
            _onboardingPages[_currentPage].bgColor,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SmoothPageIndicator(
              controller: _pageController,
              count: _onboardingPages.length,
              effect: ExpandingDotsEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Colors.white,
                dotColor: Colors.white.withOpacity(0.4),
                spacing: 8,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_isLastPage) {
                  _navigateToLogin();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _onboardingPages[_currentPage].bgColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isArabic && _isLastPage)
                    const Icon(Icons.keyboard_arrow_left, size: 20),
                  Text(
                    _isLastPage
                        ? isArabic ? 'ابدأ الآن' : 'Get Started'
                        : isArabic ? 'التالي' : 'Next',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isArabic && _isLastPage)
                    const SizedBox(width: 8),
                  if (!isArabic && _isLastPage)
                    const Icon(Icons.keyboard_arrow_right, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getArabicTitle(String englishTitle) {
    switch (englishTitle) {
      case 'Connect with Business Partners':
        return 'تواصل مع شركاء العمل';
      case 'Manage Your Inventory':
        return 'إدارة المخزون الخاص بك';
      case 'Discover Business Events':
        return 'اكتشف فعاليات الأعمال';
      case 'Secure Payment Processing':
        return 'معالجة دفع آمنة';
      default:
        return englishTitle;
    }
  }

  String _getArabicDescription(String englishDescription) {
    if (englishDescription.contains('Connect with Business Partners')) {
      return 'ابحث وتواصل مع الموردين والموزعين وأصحاب الأعمال في مكان واحد لتوسيع شبكتك.';
    } else if (englishDescription.contains('Manage Your Inventory')) {
      return 'تتبع منتجاتك وخدماتك باستخدام نظام إدارة المخزون القوي للتحكم بشكل أفضل في أعمالك.';
    } else if (englishDescription.contains('Discover Business Events')) {
      return 'استكشف وحجز وتنظيم فعاليات الأعمال لتوسيع شبكتك وتنمية فرص عملك.';
    } else if (englishDescription.contains('Secure Payment Processing')) {
      return 'حجز تذاكر الفعاليات ومعالجة المدفوعات بشكل آمن داخل التطبيق باستخدام طرق دفع متعددة.';
    } else {
      return englishDescription;
    }
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final Color bgColor;
  final IconData icon;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.bgColor,
    required this.icon,
  });
}