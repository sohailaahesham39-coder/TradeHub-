import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/models/Event%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/settings/ProfileScreen.dart';
import '../../providers/Localization%20Provider.dart';
import '../../providers/Theme%20Provider.dart';
import '../../search/Search%20Screen.dart';
import '../../test/unit/AppImageHandler%20Utility%20.dart';
import '../../test/widget/Event%20Card%20Widget.dart';
import '../home/Home%20Screen.dart';
import '../inventory/Inventory%20Screen.dart';
import 'EventDetailsScreen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 2; // Events tab is selected by default
  String _selectedTab = 'upcoming';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _tabs = [
    {'id': 'upcoming', 'name_en': 'Upcoming', 'name_ar': 'القادمة'},
    {'id': 'my_bookings', 'name_en': 'My Bookings', 'name_ar': 'حجوزاتي'},
    {'id': 'past', 'name_en': 'Past Events', 'name_ar': 'الفعاليات السابقة'},
  ];

  // تعريف الصور مع روابط Pinterest
  final Map<String, String> _placeholderImages = {
    'conference': 'https://i.pinimg.com/736x/0e/05/6b/0e056bd3d332590b079ac0389446b2d4.jpg',
    'workshop': 'https://i.pinimg.com/736x/fc/eb/aa/fcebaaefd55383e336b719c75e466e5d.jpg',
    'expo': 'https://i.pinimg.com/736x/b9/5c/bf/b95cbf28fa5efcd2d2b0047acd3dfa8a.jpg',
    'marketing': 'https://i.pinimg.com/736x/9a/41/59/9a41597467cd1e0bb75ef5b4dd0535cd.jpg',
    'sustainability': 'https://i.pinimg.com/736x/a8/e5/c5/a8e5c5f756ad1179e194bc3205d8b144.jpg',
    'tech': 'https://i.pinimg.com/736x/9b/9b/3b/9b9b3ba7fad1f1f299bf2da2610070d0.jpg',
    'education': 'https://i.pinimg.com/736x/1f/53/ac/1f53acec52424543953c2ee5851ff4a6.jpg',
    'health': 'https://i.pinimg.com/736x/21/e0/ff/21e0fff95607b8049149e7c2268da1e8.jpg',
    'finance': 'https://i.pinimg.com/736x/4e/e8/de/4ee8de1944a5f1f7daf247a292319f76.jpg',
    'fashion': 'https://i.pinimg.com/736x/8f/88/65/8f88652154d4c67f7118850f35ba1a23.jpg',
  };

  final List<Event> _upcomingEvents = [
    Event(
      id: '1',
      title: 'Annual Business Conference 2025',
      description: 'Join industry leaders for a day of networking and innovation insights.',
      date: DateTime.now().add(const Duration(days: 15)),
      location: 'Grand Convention Center, Dubai',
      imageUrl: 'https://i.pinimg.com/736x/0e/05/6b/0e056bd3d332590b079ac0389446b2d4.jpg',
      ticketPrice: 149.99,
      totalAttendees: 450,
      organizerId: 'org001',
      organizerName: 'Business Growth Network',
      tags: ['Networking', 'Business', 'Conference'],
      website: 'https://businessgrowthnetwork.com',
      speakers: [
        {'name': 'Ahmed Al-Mansour', 'title': 'CEO, Gulf Investments'},
        {'name': 'Sarah Johnson', 'title': 'Marketing Director, Global Brands'},
      ],
      schedule: [
        {'time': '09:00 AM', 'title': 'Registration & Breakfast'},
        {'time': '10:00 AM', 'title': 'Keynote Speech'},
        {'time': '12:00 PM', 'title': 'Networking Lunch'},
      ],
      isVirtual: false,
      remainingTickets: 120,
    ),
    Event(
      id: '2',
      title: 'Supply Chain Optimization Workshop',
      description: 'Master strategies to streamline your supply chain operations.',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Business Innovation Center, Abu Dhabi',
      imageUrl:'https://i.pinimg.com/736x/19/01/9b/19019b113e1a9471a5e4e4f83c5c6b3e.jpg',
      ticketPrice: 79.99,
      totalAttendees: 120,
      organizerId: 'org002',
      organizerName: 'Logistics Professionals Association',
      tags: ['Workshop', 'Supply Chain', 'Logistics'],
      website: 'https://lpa.org/workshops',
      speakers: [
        {'name': 'Dr. Khalid Rahman', 'title': 'Supply Chain Expert'},
      ],
      schedule: [
        {'time': '09:30 AM', 'title': 'Introduction to SCM'},
        {'time': '11:00 AM', 'title': 'Case Studies Analysis'},
        {'time': '02:00 PM', 'title': 'Interactive Workshop'},
      ],
      isVirtual: true,
      virtualMeetingLink: 'https://zoom.us/j/123456789',
      remainingTickets: 35,
    ),
    Event(
      id: '3',
      title: 'International Trade Expo 2025',
      description: 'Expand your market reach with global buyers and exhibitors.',
      date: DateTime.now().add(const Duration(days: 30)),
      location: 'International Exhibition Center, Riyadh',
      imageUrl: 'https://i.pinimg.com/736x/5d/da/14/5dda14762f7908dfe66832cf56e200d4.jpg',
      ticketPrice: 199.99,
      totalAttendees: 800,
      organizerId: 'org003',
      organizerName: 'Global Trade Authority',
      tags: ['Expo', 'International', 'Exhibition'],
      website: 'https://globaltradeauthority.org',
      speakers: [
        {'name': 'Mohammed Al-Faisal', 'title': 'Minister of Commerce'},
        {'name': 'John Williams', 'title': 'Trade Commissioner, EU'},
      ],
      schedule: [
        {'time': '10:00 AM', 'title': 'Opening Ceremony'},
        {'time': '11:00 AM', 'title': 'Exhibition Opens'},
        {'time': '06:00 PM', 'title': 'Networking Reception'},
      ],
      isVirtual: false,
      remainingTickets: 250,
    ),
    Event(
      id: '6',
      title: 'Tech Innovation Summit',
      description: 'Discover the latest trends in technology and digital transformation.',
      date: DateTime.now().add(const Duration(days: 20)),
      location: 'Tech Park, Sharjah',
      imageUrl: 'https://i.pinimg.com/736x/e5/73/4d/e5734d2a09b5c9ee8f46d318d8dd8fc5.jpg',
      ticketPrice: 129.99,
      totalAttendees: 300,
      organizerId: 'org006',
      organizerName: 'Tech Pioneers Group',
      tags: ['Technology', 'Innovation', 'Summit'],
      website: 'https://techpioneersgroup.com',
      speakers: [
        {'name': 'Fatima Al-Zahra', 'title': 'AI Researcher'},
        {'name': 'Mark Lee', 'title': 'CTO, InnovateX'},
      ],
      schedule: [
        {'time': '08:30 AM', 'title': 'Welcome Address'},
        {'time': '09:30 AM', 'title': 'AI in Business Panel'},
        {'time': '01:00 PM', 'title': 'Tech Demos'},
      ],
      isVirtual: true,
      virtualMeetingLink: 'https://meet.google.com/abc-def-ghi',
      remainingTickets: 80,
    ),
    Event(
      id: '7',
      title: 'Education & Skills Forum',
      description: 'Upskill your workforce with cutting-edge educational strategies.',
      date: DateTime.now().add(const Duration(days: 25)),
      location: 'Knowledge Hub, Qatar',
      imageUrl: 'https://i.pinimg.com/736x/78/d4/b6/78d4b6ea5a48c9559954f0e4cf71af88.jpg',
      ticketPrice: 99.99,
      totalAttendees: 200,
      organizerId: 'org007',
      organizerName: 'EduFuture Alliance',
      tags: ['Education', 'Training', 'Forum'],
      website: 'https://edufuturealliance.org',
      speakers: [
        {'name': 'Dr. Layla Hassan', 'title': 'Education Consultant'},
        {'name': 'Paul Carter', 'title': 'Skills Development Specialist'},
      ],
      schedule: [
        {'time': '09:00 AM', 'title': 'Opening Keynote'},
        {'time': '11:00 AM', 'title': 'Skills Workshop'},
        {'time': '03:00 PM', 'title': 'Panel Discussion'},
      ],
      isVirtual: false,
      remainingTickets: 50,
    ),
    Event(
      id: '8',
      title: 'Healthcare Innovation Conference',
      description: 'Explore advancements in healthcare technology and patient care.',
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'Medical City, Jeddah',
      imageUrl: 'https://i.pinimg.com/736x/5d/48/db/5d48db92a0a8d80fc8f42fe1c69cb712.jpg',
      ticketPrice: 159.99,
      totalAttendees: 350,
      organizerId: 'org008',
      organizerName: 'HealthTech Society',
      tags: ['Healthcare', 'Technology', 'Conference'],
      website: 'https://healthtechsociety.org',
      speakers: [
        {'name': 'Dr. Omar Saeed', 'title': 'Medical Director'},
        {'name': 'Emily Clark', 'title': 'HealthTech Innovator'},
      ],
      schedule: [
        {'time': '08:00 AM', 'title': 'Registration'},
        {'time': '09:00 AM', 'title': 'Keynote on Telemedicine'},
        {'time': '02:00 PM', 'title': 'Innovation Showcase'},
      ],
      isVirtual: false,
      remainingTickets: 90,
    ),
    Event(
      id: '9',
      title: 'Finance & Investment Summit',
      description: 'Gain insights into the latest financial trends and investment opportunities.',
      date: DateTime.now().add(const Duration(days: 40)),
      location: 'Financial District, Kuwait',
      imageUrl: 'https://i.pinimg.com/736x/78/2e/1f/782e1f5443bd8d9a5d8afc544e250f1a.jpg',
      ticketPrice: 179.99,
      totalAttendees: 500,
      organizerId: 'org009',
      organizerName: 'Finance Leaders Network',
      tags: ['Finance', 'Investment', 'Summit'],
      website: 'https://financeleadersnetwork.com',
      speakers: [
        {'name': 'Youssef Al-Khalid', 'title': 'Investment Banker'},
        {'name': 'Laura Thompson', 'title': 'Financial Analyst'},
      ],
      schedule: [
        {'time': '10:00 AM', 'title': 'Market Trends Overview'},
        {'time': '12:00 PM', 'title': 'Investment Strategies'},
        {'time': '04:00 PM', 'title': 'Networking Session'},
      ],
      isVirtual: true,
      virtualMeetingLink: 'https://webex.com/meet/finance2025',
      remainingTickets: 150,
    ),
  ];

  final List<Event> _myBookings = [
    Event(
      id: '2',
      title: 'Supply Chain Optimization Workshop',
      description: 'Master strategies to streamline your supply chain operations.',
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Business Innovation Center, Abu Dhabi',
      imageUrl: 'https://i.pinimg.com/736x/19/01/9b/19019b113e1a9471a5e4e4f83c5c6b3e.jpg',
      ticketPrice: 79.99,
      totalAttendees: 120,
      organizerId: 'org002',
      organizerName: 'Logistics Professionals Association',
      tags: ['Workshop', 'Supply Chain', 'Logistics'],
      website: 'https://lpa.org/workshops',
      speakers: [
        {'name': 'Dr. Khalid Rahman', 'title': 'Supply Chain Expert'},
      ],
      schedule: [
        {'time': '09:30 AM', 'title': 'Introduction to SCM'},
        {'time': '11:00 AM', 'title': 'Case Studies Analysis'},
        {'time': '02:00 PM', 'title': 'Interactive Workshop'},
      ],
      isVirtual: true,
      virtualMeetingLink: 'https://zoom.us/j/123456789',
      remainingTickets: 35,
    ),
    Event(
      id: '6',
      title: 'Tech Innovation Summit',
      description: 'Discover the latest trends in technology and digital transformation.',
      date: DateTime.now().add(const Duration(days: 20)),
      location: 'Tech Park, Sharjah',
      imageUrl: 'https://i.pinimg.com/736x/e5/73/4d/e5734d2a09b5c9ee8f46d318d8dd8fc5.jpg',
      ticketPrice: 129.99,
      totalAttendees: 300,
      organizerId: 'org006',
      organizerName: 'Tech Pioneers Group',
      tags: ['Technology', 'Innovation', 'Summit'],
      website: 'https://techpioneersgroup.com',
      speakers: [
        {'name': 'Fatima Al-Zahra', 'title': 'AI Researcher'},
        {'name': 'Mark Lee', 'title': 'CTO, InnovateX'},
      ],
      schedule: [
        {'time': '08:30 AM', 'title': 'Welcome Address'},
        {'time': '09:30 AM', 'title': 'AI in Business Panel'},
        {'time': '01:00 PM', 'title': 'Tech Demos'},
      ],
      isVirtual: true,
      virtualMeetingLink: 'https://meet.google.com/abc-def-ghi',
      remainingTickets: 80,
    ),
    Event(
      id: '10',
      title: 'Fashion Industry Trends Seminar',
      description: 'Stay ahead with the latest trends in fashion and retail.',
      date: DateTime.now().add(const Duration(days: 12)),
      location: 'Fashion District, Dubai',
      imageUrl: 'https://i.pinimg.com/736x/3e/b8/2f/3eb82f98979c6d4ea5ad63d88e41bd25.jpg',
      ticketPrice: 89.99,
      totalAttendees: 150,
      organizerId: 'org010',
      organizerName: 'Fashion Forward Collective',
      tags: ['Fashion', 'Trends', 'Seminar'],
      website: 'https://fashionforwardcollective.com',
      speakers: [
        {'name': 'Amina Salem', 'title': 'Fashion Designer'},
        {'name': 'Sophie Dupont', 'title': 'Retail Consultant'},
      ],
      schedule: [
        {'time': '10:00 AM', 'title': 'Trend Forecast'},
        {'time': '11:30 AM', 'title': 'Design Workshop'},
        {'time': '02:00 PM', 'title': 'Q&A Session'},
      ],
      isVirtual: false,
      remainingTickets: 40,
    ),
  ];

  // تحديث الفعاليات السابقة باستخدام روابط Pinterest المباشرة بدلاً من example.com
  final List<Event> _pastEvents = [
    Event(
      id: '4',
      title: 'Digital Marketing Masterclass',
      description: 'Enhance your digital marketing skills with practical strategies and tools.',
      date: DateTime.now().subtract(const Duration(days: 15)),
      location: 'Tech Hub, Dubai',
      imageUrl: 'https://i.pinimg.com/736x/2f/b7/dc/2fb7dc3e5cb7b12b09d11688e8f4c4c2.jpg',
      ticketPrice: 99.99,
      totalAttendees: 180,
      organizerId: 'org004',
      organizerName: 'Digital Marketing Institute',
      tags: ['Marketing', 'Digital', 'Workshop'],
      website: 'https://dmi.org',
      speakers: [
        {'name': 'Laura Chen', 'title': 'Digital Marketing Strategist'},
      ],
      schedule: [
        {'time': '10:00 AM', 'title': 'SEO Fundamentals'},
        {'time': '01:00 PM', 'title': 'Social Media Marketing'},
      ],
      isVirtual: false,
      remainingTickets: 0,
    ),
    Event(
      id: '5',
      title: 'Sustainable Business Practices Forum',
      description: 'Explore sustainable practices to reduce environmental impact.',
      date: DateTime.now().subtract(const Duration(days: 30)),
      location: 'Green Business Center, Jeddah',
      imageUrl: 'https://i.pinimg.com/736x/2e/4c/89/2e4c89f3df17d8a3fab0d0afa0b26cb3.jpg',
      ticketPrice: 129.99,
      totalAttendees: 220,
      organizerId: 'org005',
      organizerName: 'Sustainable Business Alliance',
      tags: ['Sustainability', 'Business', 'Environment'],
      website: 'https://sustainablebusiness.org',
      speakers: [
        {'name': 'Dr. Aisha Al-Najjar', 'title': 'Sustainability Expert'},
        {'name': 'Thomas Green', 'title': 'Environmental Consultant'},
      ],
      schedule: [
        {'time': '09:00 AM', 'title': 'Opening Panel'},
        {'time': '11:30 AM', 'title': 'Case Studies'},
        {'time': '02:30 PM', 'title': 'Workshop Sessions'},
      ],
      isVirtual: false,
      remainingTickets: 0,
    ),
    Event(
      id: '11',
      title: 'Global Entrepreneurship Summit 2024',
      description: 'Inspiring startups and entrepreneurs with success stories and strategies.',
      date: DateTime.now().subtract(const Duration(days: 45)),
      location: 'Startup City, Bahrain',
      imageUrl: 'https://i.pinimg.com/736x/0e/05/6b/0e056bd3d332590b079ac0389446b2d4.jpg',
      ticketPrice: 139.99,
      totalAttendees: 600,
      organizerId: 'org011',
      organizerName: 'Entrepreneurship Network',
      tags: ['Entrepreneurship', 'Startups', 'Summit'],
      website: 'https://entrepreneurshipnetwork.com',
      speakers: [
        {'name': 'Hassan Al-Bader', 'title': 'Founder, TechStart'},
        {'name': 'Emma Stone', 'title': 'Venture Capitalist'},
      ],
      schedule: [
        {'time': '09:00 AM', 'title': 'Keynote Address'},
        {'time': '11:00 AM', 'title': 'Pitch Competition'},
        {'time': '03:00 PM', 'title': 'Networking Event'},
      ],
      isVirtual: false,
      remainingTickets: 0,
    ),
    Event(
      id: '12',
      title: 'Retail Innovation Workshop',
      description: 'Learn how to innovate in retail with technology and customer insights.',
      date: DateTime.now().subtract(const Duration(days: 20)),
      location: 'Retail Academy, Riyadh',
      imageUrl: 'https://i.pinimg.com/736x/19/01/9b/19019b113e1a9471a5e4e4f83c5c6b3e.jpg',
      ticketPrice: 69.99,
      totalAttendees: 100,
      organizerId: 'org012',
      organizerName: 'Retail Innovators Guild',
      tags: ['Retail', 'Innovation', 'Workshop'],
      website: 'https://retailinnovatorsguild.com',
      speakers: [
        {'name': 'Noura Al-Ghamdi', 'title': 'Retail Strategist'},
      ],
      schedule: [
        {'time': '10:00 AM', 'title': 'Retail Tech Intro'},
        {'time': '12:00 PM', 'title': 'Customer Experience Session'},
      ],
      isVirtual: true,
      virtualMeetingLink: 'https://zoom.us/j/987654321',
      remainingTickets: 0,
    ),
  ];

  // دالة محسّنة للحصول على الفعاليات الحالية
  List<Event> get _currentEvents {
    print('الحصول على الفعاليات للتبويب: $_selectedTab');
    switch (_selectedTab) {
      case 'upcoming':
        print('عدد الفعاليات القادمة: ${_upcomingEvents.length}');
        return _upcomingEvents;
      case 'my_bookings':
        print('عدد حجوزاتي: ${_myBookings.length}');
        return _myBookings;
      case 'past':
        print('عدد الفعاليات السابقة: ${_pastEvents.length}');
        return _pastEvents;
      default:
        print('التبويب غير معروف: $_selectedTab، عرض الفعاليات القادمة');
        return _upcomingEvents;
    }
  }

  @override
  void initState() {
    super.initState();
    print('تهيئة شاشة الفعاليات');
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

    // تصحيح الصور
    _patchEventImages();

    // تأكيد تحميل الشاشة
    setState(() {
      _isLoading = true;
    });

    // تأخير قصير ثم إعادة تعيين حالة التحميل إلى false
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          print('اكتمل التحميل');
        });
      }
    });

    // تحميل مسبق للصور
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allImages = [
        ..._upcomingEvents.map((e) => e.imageUrl),
        ..._myBookings.map((e) => e.imageUrl),
        ..._pastEvents.map((e) => e.imageUrl),
      ];
      print('بدء التحميل المسبق للصور: ${allImages.length} صورة');
      AppImageHandler.preloadImages(context, allImages);
    });
  }

  @override
  void dispose() {
    print('التخلص من موارد شاشة الفعاليات');
    _animationController.dispose();
    AppImageHandler.customCacheManager.dispose();
    super.dispose();
  }

  // دالة محسّنة لتصحيح روابط الصور
  void _patchEventImages() {
    print('بدء تصحيح روابط الصور');
    // قائمة تجمع جميع الأحداث
    final allEvents = [..._upcomingEvents, ..._myBookings, ..._pastEvents];
    int fixedCount = 0;

    for (var event in allEvents) {
      String url = event.imageUrl;

      // فحص صلاحية الرابط
      if (url.contains('example.com') || !AppImageHandler.isValidImageUrl(url)) {
        String oldUrl = url;

        // تبديل الصور
        if (url.contains('conference')) {
          event.imageUrl = _placeholderImages['conference']!;
        } else if (url.contains('workshop')) {
          event.imageUrl = _placeholderImages['workshop']!;
        } else if (url.contains('expo')) {
          event.imageUrl = _placeholderImages['expo']!;
        } else if (url.contains('marketing')) {
          event.imageUrl = _placeholderImages['marketing']!;
        } else if (url.contains('sustainability')) {
          event.imageUrl = _placeholderImages['sustainability']!;
        } else if (url.contains('tech')) {
          event.imageUrl = _placeholderImages['tech']!;
        } else if (url.contains('education')) {
          event.imageUrl = _placeholderImages['education']!;
        } else if (url.contains('health')) {
          event.imageUrl = _placeholderImages['health']!;
        } else if (url.contains('finance')) {
          event.imageUrl = _placeholderImages['finance']!;
        } else if (url.contains('fashion')) {
          event.imageUrl = _placeholderImages['fashion']!;
        } else {
          // صورة افتراضية للمؤتمرات إذا لم يكن هناك تطابق
          event.imageUrl = _placeholderImages['conference']!;
        }

        print('تم تصحيح الرابط: $oldUrl -> ${event.imageUrl}');
        fixedCount++;
      }
    }

    print('تم تصحيح $fixedCount رابط من أصل ${allEvents.length}');
  }

  // دالة تبديل التبويبات المحسّنة
  void _switchTab(String tabId) {
    print('تبديل التبويب إلى: $tabId');
    if (_selectedTab != tabId) {
      setState(() {
        _selectedTab = tabId;
        _isLoading = true;
      });

      // تأخير قصير ثم إعادة تعيين حالة التحميل
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            print('اكتمل تحميل التبويب: $tabId');
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isArabic = localizationProvider.isArabic;

    print('بناء واجهة شاشة الفعاليات، التبويب الحالي: $_selectedTab، التحميل: $_isLoading');

    final Color gradientStart = themeProvider.isDarkMode
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFEEF5FF);
    final Color gradientEnd = themeProvider.isDarkMode
        ? const Color(0xFF12121C)
        : const Color(0xFFDAE9FA);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassmorphicAppBar(context, themeProvider),
      body: Container(
      decoration: BoxDecoration(
      gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [gradientStart, gradientEnd],
    ),
    ),
    child: Stack(
    children: [
    Positioned(
    top: -50.h,
    right: -30.w,
    child: Container(
    height: 150.h,
    width: 150.w,
    decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: AppTheme.primaryColor.withOpacity(0.2),
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
        color: AppTheme.primaryColor.withOpacity(0.15),
      ),
    ),
    ),
      SafeArea(
        child: Column(
          children: [
            _buildTabBar(themeProvider),
            _isLoading
                ? Expanded(
              child: Center(
                child: Container(
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
                        color: AppTheme.primaryColor,
                        strokeWidth: 3.w,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        isArabic ? 'جارِ التحميل...' : 'Loading...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
                : Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _currentEvents.isEmpty
                    ? _buildEmptyState(themeProvider)
                    : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _currentEvents.length,
                  itemBuilder: (context, index) {
                    print('بناء عنصر رقم $index: ${_currentEvents[index].title}');
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: EventCardWidget(
                        event: _currentEvents[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailsScreen(
                                event: _currentEvents[index],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ],
    ),
      ),
      floatingActionButton: _buildGlassmorphicFAB(context, themeProvider),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  PreferredSizeWidget _buildGlassmorphicAppBar(BuildContext context, ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return PreferredSize(
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
              isArabic ? 'الفعاليات' : 'Events',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryColor,
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isArabic ? Icons.arrow_forward : Icons.arrow_back,
                  size: 22.sp,
                  color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryColor,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.search,
                    size: 22.sp,
                    color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
              IconButton(
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    size: 22.sp,
                    color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 70.h,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.map((tab) {
              final isSelected = _selectedTab == tab['id'];
              return InkWell(
                onTap: () => _switchTab(tab['id']!), // استخدام الدالة المحسّنة لتبديل التبويبات
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ]
                        : null,
                  ),
                  child: Text(
                    isArabic ? tab['name_ar']! : tab['name_en']!,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;
    print('بناء حالة فارغة للتبويب: $_selectedTab');

    return Center(
      child: _buildGlassmorphicContainer(
        themeProvider: themeProvider,
        child: Padding(
          padding: EdgeInsets.all(30.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_busy,
                  size: 40.sp,
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                isArabic ? 'لا توجد فعاليات' : 'No Events Available',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isArabic
                    ? 'لا توجد فعاليات في هذا القسم حالياً'
                    : 'There are no events in this section currently',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to create event screen
                        print('الضغط على إنشاء فعالية جديدة');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        elevation: 0,
                      ),
                      child: Text(
                        isArabic ? 'إنشاء فعالية جديدة' : 'Create New Event',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassmorphicFAB(BuildContext context, ThemeProvider themeProvider) {
    return Container(
      height: 60.h,
      width: 60.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FloatingActionButton(
            onPressed: () {
              // Navigate to create event screen
              print('الضغط على زر إنشاء فعالية جديدة (FAB)');
            },
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.add, size: 24.sp),
            elevation: 0,
          ),
        ),
      ),
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
            icon: Icon(Icons.supervised_user_circle_rounded),
            activeIcon: Icon(Icons.supervised_user_circle_rounded),
            label: isArabic ? 'الإعدادات' : 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    print('الانتقال إلى التبويب رقم: $index');
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
        break;
      case 2:
      // Already on EventsScreen, do nothing
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InventoryScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildGlassmorphicContainer({
    required ThemeProvider themeProvider,
    required Widget child,
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

  void _showFilterDialog(BuildContext context) {
    final isArabic = Provider.of<LocalizationProvider>(context, listen: false).isArabic;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    print('عرض مربع حوار التصفية');

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
                Text(
                  isArabic ? 'تصفية الفعاليات' : 'Filter Events',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildFilterSection(
                  title: isArabic ? 'نطاق التاريخ' : 'Date Range',
                  icon: Icons.date_range,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDateFilterChip(context, 'This Week', true, themeProvider),
                      _buildDateFilterChip(context, 'This Month', false, themeProvider),
                      _buildDateFilterChip(context, 'Custom', false, themeProvider),
                    ],
                  ),
                ),
                _buildFilterSection(
                  title: isArabic ? 'نوع الفعالية' : 'Event Type',
                  icon: Icons.category,
                  content: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _buildTypeFilterChip(context, 'Conference', false, themeProvider),
                      _buildTypeFilterChip(context, 'Workshop', true, themeProvider),
                      _buildTypeFilterChip(context, 'Expo', false, themeProvider),
                      _buildTypeFilterChip(context, 'Seminar', false, themeProvider),
                    ],
                  ),
                ),
                _buildFilterSection(
                  title: isArabic ? 'الصيغة' : 'Format',
                  icon: Icons.video_call,
                  content: Row(
                    children: [
                      Expanded(
                        child: _buildFormatFilterOption(
                          context,
                          'In Person',
                          Icons.people,
                          true,
                          themeProvider,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildFormatFilterOption(
                          context,
                          'Virtual',
                          Icons.videocam,
                          false,
                          themeProvider,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFilterSection(
                  title: isArabic ? 'نطاق السعر' : 'Price Range',
                  icon: Icons.attach_money,
                  content: Column(
                    children: [
                      SizedBox(
                        height: 30.h,
                        child: Slider(
                          value: 150,
                          min: 0,
                          max: 300,
                          activeColor: AppTheme.primaryColor,
                          inactiveColor: AppTheme.primaryColor.withOpacity(0.2),
                          onChanged: (value) {},
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$0',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          Text(
                            '\$150',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Text(
                            '\$300+',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            side: BorderSide(
                              color: themeProvider.isDarkMode
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.2),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Text(
                            isArabic ? 'إعادة تعيين' : 'Reset',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print('تطبيق عوامل التصفية');
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isArabic ? 'تطبيق' : 'Apply',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
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
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          content,
          SizedBox(height: 8.h),
          Divider(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterChip(BuildContext context, String label, bool isSelected, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor
            : themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor
              : themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.white
              : themeProvider.isDarkMode
              ? Colors.white
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTypeFilterChip(BuildContext context, String label, bool isSelected, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor
            : themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor
              : themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Colors.white
              : themeProvider.isDarkMode
              ? Colors.white
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildFormatFilterOption(
      BuildContext context,
      String label,
      IconData icon,
      bool isSelected,
      ThemeProvider themeProvider,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor
            : themeProvider.isDarkMode
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor
              : themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected
                ? Colors.white
                : themeProvider.isDarkMode
                ? Colors.white
                : Colors.black87,
            size: 18.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : themeProvider.isDarkMode
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

