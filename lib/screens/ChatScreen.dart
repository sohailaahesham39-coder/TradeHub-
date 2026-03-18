import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/screens/AISupportChatScreen.dart';
import 'package:trade_hub/screens/ChatDetailScreen.dart';
import 'package:trade_hub/screens/auth/Login%20Screen.dart';
import 'package:trade_hub/services/SessionManager/SessionManager.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SessionManager _sessionManager = SessionManager();
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Placeholder chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'id': 'chat1',
      'name': 'Ahmed Trading Co.',
      'type': 'Distributor',
      'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a',
      'lastMessage': 'Can we discuss the order details?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
      'unreadCount': 2,
    },
    {
      'id': 'chat2',
      'name': 'Green Earth Supplies',
      'type': 'Supplier',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
      'lastMessage': 'New shipment arriving tomorrow.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'unreadCount': 0,
    },
    {
      'id': 'chat3',
      'name': 'Tech Innovations Ltd',
      'type': 'Business Owner',
      'avatar': 'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e',
      'lastMessage': 'Interested in your LED bulbs.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 1,
    },
    {
      'id': 'chat4',
      'name': 'Global Logistics Co.',
      'type': 'Distributor',
      'avatar': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7',
      'lastMessage': 'Delivery scheduled for next week.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'unreadCount': 0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkSession();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    try {
      final sessionData = await _sessionManager.getUserSessionData();
      if (!sessionData['isLoggedIn']) {
        _handleSessionExpired();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking session: $e'),
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

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) return _chats;
    return _chats.where((chat) {
      return chat['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chat['lastMessage'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: AppTheme.primaryColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              isArabic ? 'المحادثات' : 'Chats',
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
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(
            icon: Icon(
              isArabic ? Icons.language : Icons.translate,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
            onPressed: () => localizationProvider.toggleLanguage(),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 3.w,
          ),
        )
            : Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: isArabic ? 'ابحث في المحادثات...' : 'Search chats...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20.sp),
                  filled: true,
                  fillColor: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                style: TextStyle(fontSize: 16.sp),
                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AISupportChatScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: themeProvider.isDarkMode
                        ? []
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.support_agent,
                          color: AppTheme.primaryColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          isArabic ? 'دعم الذكاء الاصطناعي' : 'AI Support',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filteredChats.isEmpty
                  ? Center(
                child: Text(
                  isArabic ? 'لا توجد محادثات' : 'No chats found',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: _filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = _filteredChats[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(chat: chat),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: themeProvider.isDarkMode
                            ? []
                            : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          AppImageHandler.loadProfileImage(
                            imageUrl: chat['avatar'],
                            size: 50.r,
                            borderColor: AppTheme.primaryColor.withOpacity(0.2),
                            borderWidth: 2,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chat['name'],
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  chat['lastMessage'],
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatTimestamp(chat['timestamp']),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              if (chat['unreadCount'] > 0)
                                Container(
                                  margin: EdgeInsets.only(top: 8.h),
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Text(
                                    '${chat['unreadCount']}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_add, color: AppTheme.primaryColor, size: 24.sp),
                      title: Text(
                        isArabic ? 'بدء محادثة جديدة' : 'Start New Chat',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isArabic ? 'اختيار جهة اتصال جديدة' : 'Select a new contact'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.support_agent, color: AppTheme.primaryColor, size: 24.sp),
                      title: Text(
                        isArabic ? 'الدردشة مع الدعم الذكي' : 'Chat with AI Support',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AISupportChatScreen()),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: Icon(Icons.add, size: 24.sp),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}