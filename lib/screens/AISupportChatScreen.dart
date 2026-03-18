import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class AISupportChatScreen extends StatefulWidget {
  const AISupportChatScreen({Key? key}) : super(key: key);

  @override
  State<AISupportChatScreen> createState() => _AISupportChatScreenState();
}

class _AISupportChatScreenState extends State<AISupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I’m TradeHub’s AI Support. How can I assist you today?',
      'isSentByUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 1)),
    },
  ];

  // Mock AI response system
  final Map<String, String> _aiResponses = {
    'inventory': 'To add a product to your inventory, go to the Inventory Screen, tap the "+" button, and fill in the product details. Would you like more details?',
    'events': 'You can view upcoming events on the Events Screen. Tap "View All" on the Home Screen’s events section to see the full list. Need help registering for an event?',
    'connections': 'To connect with new suppliers or distributors, visit the Recent Connections section on the Home Screen and send a connection request. Want tips on networking?',
    'orders': 'Pending orders can be viewed in the Quick Stats section on the Home Screen. Tap "Orders" to see details. Shall I guide you through order management?',
    'support': 'I’m here to help! Please ask about inventory, events, connections, orders, or any other TradeHub feature.',
  };

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isSentByUser': true,
        'timestamp': DateTime.now(),
      });

      // Simulate AI response
      final userMessage = _messageController.text.toLowerCase();
      String aiResponse = 'Sorry, I didn’t understand that. Could you clarify or ask about inventory, events, connections, or orders?';
      _aiResponses.forEach((key, value) {
        if (userMessage.contains(key)) {
          aiResponse = value;
        }
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _messages.add({
            'text': aiResponse,
            'isSentByUser': false,
            'timestamp': DateTime.now(),
          });
        });
      });

      _messageController.clear();
    });
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArabic ? 'دعم الذكاء الاصطناعي' : 'AI Support',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  isArabic ? 'متواجد الآن' : 'Online Now',
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isSentByUser = message['isSentByUser'];
                return Align(
                  alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    constraints: BoxConstraints(maxWidth: 0.7.sw),
                    decoration: BoxDecoration(
                      color: isSentByUser
                          ? AppTheme.primaryColor
                          : themeProvider.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['text'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isSentByUser
                                ? Colors.white
                                : themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatTimestamp(message['timestamp']),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: isSentByUser ? Colors.white70 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: isArabic ? 'اكتب رسالتك...' : 'Type your message...',
                      filled: true,
                      fillColor: themeProvider.isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    ),
                    style: TextStyle(fontSize: 16.sp),
                    textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: AppTheme.primaryColor,
                    size: 24.sp,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
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