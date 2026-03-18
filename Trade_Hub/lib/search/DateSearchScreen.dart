import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';

class DateSearchScreen extends StatefulWidget {
  const DateSearchScreen({Key? key}) : super(key: key);

  @override
  State<DateSearchScreen> createState() => _DateSearchScreenState();
}

class _DateSearchScreenState extends State<DateSearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Calendar format
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Date range selection
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  // Selected date type
  String _dateFilterType = 'range'; // 'single', 'range', 'preset'

  // Preset ranges
  final List<Map<String, dynamic>> _presetRanges = [
    {
      'id': 'today',
      'name_en': 'Today',
      'name_ar': 'اليوم',
    },
    {
      'id': 'yesterday',
      'name_en': 'Yesterday',
      'name_ar': 'أمس',
    },
    {
      'id': 'thisWeek',
      'name_en': 'This Week',
      'name_ar': 'هذا الأسبوع',
    },
    {
      'id': 'lastWeek',
      'name_en': 'Last Week',
      'name_ar': 'الأسبوع الماضي',
    },
    {
      'id': 'thisMonth',
      'name_en': 'This Month',
      'name_ar': 'هذا الشهر',
    },
    {
      'id': 'lastMonth',
      'name_en': 'Last Month',
      'name_ar': 'الشهر الماضي',
    },
    {
      'id': 'last3Months',
      'name_en': 'Last 3 Months',
      'name_ar': 'آخر 3 أشهر',
    },
    {
      'id': 'thisYear',
      'name_en': 'This Year',
      'name_ar': 'هذه السنة',
    },
  ];

  String _selectedPreset = 'thisWeek';

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

    // Initialize default date range to this week
    _setPresetRange('thisWeek');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setPresetRange(String presetId) {
    setState(() {
      _selectedPreset = presetId;
      final now = DateTime.now();

      switch (presetId) {
        case 'today':
          _rangeStart = DateTime(now.year, now.month, now.day);
          _rangeEnd = _rangeStart;
          break;
        case 'yesterday':
          _rangeStart = DateTime(now.year, now.month, now.day - 1);
          _rangeEnd = _rangeStart;
          break;
        case 'thisWeek':
        // Calculate the start of the current week (Sunday)
          _rangeStart = now.subtract(Duration(days: now.weekday % 7));
          _rangeStart = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
          // Calculate end of week (Saturday)
          _rangeEnd = _rangeStart!.add(const Duration(days: 6));
          break;
        case 'lastWeek':
        // Calculate the start of the last week
          _rangeStart = now.subtract(Duration(days: (now.weekday % 7) + 7));
          _rangeStart = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
          // Calculate end of last week
          _rangeEnd = _rangeStart!.add(const Duration(days: 6));
          break;
        case 'thisMonth':
          _rangeStart = DateTime(now.year, now.month, 1);
          _rangeEnd = DateTime(now.year, now.month + 1, 0); // Last day of the month
          break;
        case 'lastMonth':
          _rangeStart = DateTime(now.year, now.month - 1, 1);
          _rangeEnd = DateTime(now.year, now.month, 0); // Last day of the previous month
          break;
        case 'last3Months':
          _rangeStart = DateTime(now.year, now.month - 3, 1);
          _rangeEnd = DateTime(now.year, now.month, 0);
          break;
        case 'thisYear':
          _rangeStart = DateTime(now.year, 1, 1);
          _rangeEnd = DateTime(now.year, 12, 31);
          break;
        default:
          _rangeStart = null;
          _rangeEnd = null;
      }

      // Update focused day to range start
      if (_rangeStart != null) {
        _focusedDay = _rangeStart!;
      }
    });
  }

  String _getFormattedDateRange() {
    if (_rangeStart == null) return '';

    if (_rangeEnd == null || _rangeStart!.isAtSameMomentAs(_rangeEnd!)) {
      return DateFormat('MMM d, y').format(_rangeStart!);
    }

    return '${DateFormat('MMM d, y').format(_rangeStart!)} - ${DateFormat('MMM d, y').format(_rangeEnd!)}';
  }

  void _applyAndNavigateBack() {
    // Here you would typically pass the selected dates back to the calling screen
    Navigator.pop(context, {
      'rangeStart': _rangeStart,
      'rangeEnd': _rangeEnd,
      'selectedDay': _selectedDay,
      'dateFilterType': _dateFilterType,
      'selectedPreset': _selectedPreset,
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
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
                isArabic ? 'تحديد التاريخ' : 'Select Date',
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
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.check,
                      size: 22.sp,
                      color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                  onPressed: _applyAndNavigateBack,
                ),
                SizedBox(width: 8.w),
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
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -30.h,
                  right: -20.w,
                  child: Container(
                    height: 100.h,
                    width: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50.h,
                  left: -30.w,
                  child: Container(
                    height: 150.h,
                    width: 150.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withOpacity(0.15),
                    ),
                  ),
                ),

                // Main content
                SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date filter type selector
                      _buildDateFilterTypeSelector(themeProvider, isArabic),
                      SizedBox(height: 16.h),

                      // Conditional content based on selected filter type
                      if (_dateFilterType == 'preset')
                        _buildPresetRanges(themeProvider, isArabic)
                      else
                        _buildCalendarView(themeProvider, isArabic),

                      SizedBox(height: 24.h),

                      // Selected date range display
                      _buildSelectedDateDisplay(themeProvider, isArabic),

                      SizedBox(height: 24.h),

                      // Apply button
                      _buildApplyButton(themeProvider, isArabic),
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
    required ThemeProvider themeProvider,
    required Widget child,
    double borderRadius = 16,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDateFilterTypeSelector(ThemeProvider themeProvider, bool isArabic) {
    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'نوع التاريخ' : 'Date Type',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildDateTypeOption(
                title: isArabic ? 'يوم محدد' : 'Single Day',
                icon: Icons.calendar_today,
                value: 'single',
                themeProvider: themeProvider,
              ),
              SizedBox(width: 16.w),
              _buildDateTypeOption(
                title: isArabic ? 'نطاق التاريخ' : 'Date Range',
                icon: Icons.date_range,
                value: 'range',
                themeProvider: themeProvider,
              ),
              SizedBox(width: 16.w),
              _buildDateTypeOption(
                title: isArabic ? 'فترة محددة' : 'Preset',
                icon: Icons.auto_awesome,
                value: 'preset',
                themeProvider: themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTypeOption({
    required String title,
    required IconData icon,
    required String value,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = _dateFilterType == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _dateFilterType = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(themeProvider.isDarkMode ? 0.7 : 0.8)
                : themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryBlue
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : themeProvider.isDarkMode
                    ? Colors.white70
                    : AppTheme.primaryBlue,
                size: 24.sp,
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : themeProvider.isDarkMode
                      ? Colors.white
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetRanges(ThemeProvider themeProvider, bool isArabic) {
    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'اختر فترة زمنية' : 'Choose a Time Period',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: _presetRanges.length,
            itemBuilder: (context, index) {
              final preset = _presetRanges[index];
              final isSelected = _selectedPreset == preset['id'];

              return GestureDetector(
                onTap: () => _setPresetRange(preset['id']),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryBlue.withOpacity(themeProvider.isDarkMode ? 0.7 : 0.8)
                        : themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryBlue
                          : themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.8),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPresetIcon(preset['id']),
                        color: isSelected
                            ? Colors.white
                            : themeProvider.isDarkMode
                            ? Colors.white70
                            : AppTheme.primaryBlue,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          isArabic ? preset['name_ar'] : preset['name_en'],
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getPresetIcon(String presetId) {
    switch (presetId) {
      case 'today':
        return Icons.today;
      case 'yesterday':
        return Icons.history;
      case 'thisWeek':
        return Icons.view_week;
      case 'lastWeek':
        return Icons.view_week_outlined;
      case 'thisMonth':
        return Icons.calendar_view_month;
      case 'lastMonth':
        return Icons.calendar_view_month_outlined;
      case 'last3Months':
        return Icons.calendar_today_sharp;
      case 'thisYear':
        return Icons.calendar_today;
      default:
        return Icons.date_range;
    }
  }

  Widget _buildCalendarView(ThemeProvider themeProvider, bool isArabic) {
    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: _dateFilterType == 'range'
                ? RangeSelectionMode.enforced
                : RangeSelectionMode.disabled,
            selectedDayPredicate: (day) {
              // Use the same logic for selectedDay in both single and range modes
              if (_dateFilterType == 'single') {
                return isSameDay(_selectedDay, day);
              }
              return false;
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (_dateFilterType == 'single') {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  // Also set range start/end for consistency
                  _rangeStart = selectedDay;
                  _rangeEnd = selectedDay;
                });
              }
            },
            onRangeSelected: (start, end, focusedDay) {
              if (_dateFilterType == 'range') {
                setState(() {
                  _selectedDay = null;
                  _focusedDay = focusedDay;
                  _rangeStart = start;
                  _rangeEnd = end;
                });
              }
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            // Calendar style
            calendarStyle: CalendarStyle(
              // Selected day
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),

              // Today
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),

              // Range selection
              rangeStartDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              rangeStartTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              rangeEndDecoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              rangeEndTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              rangeHighlightColor: AppTheme.primaryBlue.withOpacity(0.2),

              // Default
              defaultTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 14.sp,
              ),

              // Weekend
              weekendTextStyle: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.red.withOpacity(0.7),
                fontSize: 14.sp,
              ),

              // Outside days
              outsideTextStyle: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.5),
                fontSize: 14.sp,
              ),
            ),

            // Header style
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: true,
              formatButtonDecoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              formatButtonTextStyle: TextStyle(
                color: AppTheme.primaryBlue,
                fontSize: 14.sp,
              ),
              titleTextStyle: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                size: 24.sp,
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                size: 24.sp,
              ),
            ),

            // Day of week style
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
              weekendStyle: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : Colors.red.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateDisplay(ThemeProvider themeProvider, bool isArabic) {
    String displayText = '';

    if (_dateFilterType == 'preset') {
      // Find the name of the selected preset
      final selectedPresetInfo = _presetRanges.firstWhere(
            (preset) => preset['id'] == _selectedPreset,
        orElse: () => {'name_en': '', 'name_ar': ''},
      );
      displayText = isArabic ? selectedPresetInfo['name_ar'] : selectedPresetInfo['name_en'];
    } else {
      // Display formatted date range
      displayText = _getFormattedDateRange();
    }

    if (displayText.isEmpty) {
      displayText = isArabic ? 'لم يتم تحديد تاريخ' : 'No date selected';
    }

    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'التاريخ المحدد' : 'Selected Date',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _dateFilterType == 'preset'
                      ? _getPresetIcon(_selectedPreset)
                      : _dateFilterType == 'single'
                      ? Icons.calendar_today
                      : Icons.date_range,
                  color: AppTheme.primaryBlue,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(ThemeProvider themeProvider, bool isArabic) {
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
            offset: Offset(0, 5),
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
        onPressed: _applyAndNavigateBack,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: Text(
          isArabic ? 'تطبيق' : 'Apply',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}