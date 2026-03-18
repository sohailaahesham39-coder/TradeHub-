import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> chat;

  const ChatDetailScreen({Key? key, required this.chat}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello, can we discuss the order details?',
      'isSentByUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 10)),
    },
    {
      'text': 'Sure, what details do you need?',
      'isSentByUser': true,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 8)),
    },
    {
      'text': 'I need the pricing for bulk orders.',
      'isSentByUser': false,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'text': 'I’ll send you the pricing sheet shortly.',
      'isSentByUser': true,
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
    },
  ];

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
      _messageController.clear();

      // Simulate contact response (for demo purposes)
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _messages.add({
            'text': 'Thanks for your message! I’ll get back to you soon.',
            'isSentByUser': false,
            'timestamp': DateTime.now(),
          });
        });
      });
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
            AppImageHandler.loadProfileImage(
              imageUrl: widget.chat['avatar'],
              size: 40.r,
              borderColor: AppTheme.primaryColor.withOpacity(0.2),
              borderWidth: 2,
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat['name'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  widget.chat['type'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isArabic ? 'معلومات جهة الاتصال' : 'Contact Info'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
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