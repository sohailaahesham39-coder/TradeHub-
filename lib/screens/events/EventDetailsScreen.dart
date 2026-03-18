import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:trade_hub/models/Event%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/screens/events/TicketBookingScreen.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event, // Made required instead of optional with a default
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, isArabic),
          SliverPadding(
            padding: EdgeInsets.all(16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildEventDetails(context, isArabic),
                SizedBox(height: 24.h),
                _buildOrganizerInfo(context, isArabic),
                SizedBox(height: 24.h),
                _buildActionButtons(context, isArabic),
                SizedBox(height: 16.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isArabic) {
    return SliverAppBar(
      expandedHeight: 250.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: AppImageHandler.loadEventImage(
          imageUrl: event.imageUrl,
          width: double.infinity,
          height: 250.h,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)), // Fixed typo: 'bottom' instead of 'custom'
          overlayContent: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment:
                  isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Icon(Icons.people, color: Colors.white, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '${event.totalAttendees} ${isArabic ? 'حاضرين' : 'Attendees'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share, color: Colors.white, size: 24.sp),
          onPressed: () {
            // Implement share functionality
          },
        ),
      ],
    );
  }

  Widget _buildEventDetails(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(event.date),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('EEEE, hh:mm a').format(event.date),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                event.getFormattedPrice(isArabic ? 'د.إ' : '\$'),
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Icon(Icons.location_on_outlined,
                color: AppTheme.primaryColor, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                event.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Text(
          isArabic ? 'تفاصيل الفعالية' : 'Event Description',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          event.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildOrganizerInfo(BuildContext context, bool isArabic) {
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
      child: Row(
        children: [
          AppImageHandler.loadProfileImage(
            imageUrl:
            'https://example.com/images/tradehub/organizers/${event.organizerId}.jpg',
            size: 50.w,
            useShimmerLoading: true,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  event.organizerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isArabic ? 'المنظم' : 'Organizer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12.sp),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.message_outlined,
                color: AppTheme.primaryColor, size: 20.sp),
            onPressed: () {
              // Navigate to messaging screen or open chat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketBookingScreen(event: event,),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              isArabic ? 'حجز الآن' : 'Book Now',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        OutlinedButton(
          onPressed: () {
            // Add to calendar or save event
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(color: AppTheme.primaryColor),
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Icon(Icons.bookmark_border, size: 20.sp),
        ),
      ],
    );
  }
}