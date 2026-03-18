import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:trade_hub/models/Event%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';
import 'package:trade_hub/screens/Payment/PaymentScreen.dart';

class TicketBookingScreen extends StatefulWidget {
  final Event event;

  const TicketBookingScreen({
    super.key,
    required this.event,
  });

  @override
  State<TicketBookingScreen> createState() => _TicketBookingScreenState();
}

class _TicketBookingScreenState extends State<TicketBookingScreen> {
  int _ticketQuantity = 1;
  final int _maxTickets = 10; // Maximum tickets per booking
  bool _isLoading = false;

  double get _totalCost => widget.event.ticketPrice * _ticketQuantity;

  // List of available ticket types
  final List<Map<String, dynamic>> _ticketTypes = [
    {'id': 'standard', 'name_en': 'Standard', 'name_ar': 'عادي', 'selected': true},
    {'id': 'vip', 'name_en': 'VIP', 'name_ar': 'كبار الشخصيات', 'selected': false},
    {'id': 'group', 'name_en': 'Group (5+ people)', 'name_ar': 'مجموعة (5+ أشخاص)', 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'حجز التذاكر' : 'Ticket Booking',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            _buildEventCard(context, isArabic),
            SizedBox(height: 24.h),
            _buildTicketTypeSelector(context, isArabic),
            SizedBox(height: 24.h),
            _buildTicketSelector(context, isArabic),
            SizedBox(height: 24.h),
            _buildTotalCost(context, isArabic),
            SizedBox(height: 24.h),
            _buildConfirmButton(context, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: AppImageHandler.loadEventImage(
              imageUrl: widget.event.imageUrl,
              width: double.infinity,
              height: 150.h,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: isArabic
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16.sp, color: AppTheme.primaryColor),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('dd MMM yyyy').format(widget.event.date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: isArabic
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16.sp, color: AppTheme.primaryColor),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        widget.event.location,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketTypeSelector(BuildContext context, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'نوع التذكرة' : 'Ticket Type',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _ticketTypes.map((type) {
              final isSelected = type['selected'] as bool;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Deselect all types first
                    for (var t in _ticketTypes) {
                      t['selected'] = false;
                    }
                    // Select the tapped type
                    type['selected'] = true;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.5),
                      width: 1.w,
                    ),
                  ),
                  child: Text(
                    isArabic ? type['name_ar'] as String : type['name_en'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketSelector(BuildContext context, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'عدد التذاكر' : 'Number of Tickets',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle,
                    size: 28.sp, color: AppTheme.primaryColor),
                onPressed: _ticketQuantity > 1
                    ? () {
                  setState(() {
                    _ticketQuantity--;
                  });
                }
                    : null,
              ),
              SizedBox(width: 16.w),
              Text(
                '$_ticketQuantity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 16.w),
              IconButton(
                icon: Icon(Icons.add_circle,
                    size: 28.sp, color: AppTheme.primaryColor),
                onPressed: _ticketQuantity < _maxTickets
                    ? () {
                  setState(() {
                    _ticketQuantity++;
                  });
                }
                    : null,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            isArabic
                ? 'الحد الأقصى: $_maxTickets تذاكر'
                : 'Maximum: $_maxTickets tickets',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCost(BuildContext context, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'سعر التذكرة:' : 'Ticket Price:',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(
                widget.event.getFormattedPrice(isArabic ? 'د.إ' : '\$'),
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'عدد التذاكر:' : 'Number of Tickets:',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(
                '$_ticketQuantity',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
          Divider(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'الإجمالي:' : 'Total Cost:',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${isArabic ? 'د.إ' : '\$'}${_totalCost.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, bool isArabic) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });

          // Simulate some processing time
          await Future.delayed(const Duration(seconds: 1));

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  event: widget.event,
                  ticketQuantity: _ticketQuantity,
                  totalCost: _totalCost,
                  ticketType: _ticketTypes.firstWhere((type) => type['selected'] as bool)['id'] as String,
                ),
              ),
            );

            setState(() {
              _isLoading = false;
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          isArabic ? 'المتابعة للدفع' : 'Continue to Payment',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}