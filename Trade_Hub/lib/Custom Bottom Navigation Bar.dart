// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:trade_hub/providers/AppTheme.dart';
// import 'package:trade_hub/providers/Localization%20Provider.dart';
// import 'package:trade_hub/providers/Theme%20Provider.dart';
//
// class CustomBottomNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const CustomBottomNavigationBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final localizationProvider = Provider.of<LocalizationProvider>(context);
//     final isArabic = localizationProvider.isArabic;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: themeProvider.isDarkMode
//             ? const Color(0xFF1A1A2E)
//             : Colors.white,
//         border: Border(
//           top: BorderSide(
//             color: Colors.grey.withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 8.h),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildNavItem(
//                 index: 0,
//                 icon: Icons.home_outlined,
//                 selectedIcon: Icons.home,
//                 label: isArabic ? 'الرئيسية' : 'home',
//                 isSelected: currentIndex == 0,
//                 themeProvider: themeProvider,
//               ),
//               _buildNavItem(
//                 index: 1,
//                 icon: Icons.search_outlined,
//                 selectedIcon: Icons.search,
//                 label: isArabic ? 'بحث' : 'search',
//                 isSelected: currentIndex == 1,
//                 themeProvider: themeProvider,
//               ),
//               _buildNavItem(
//                 index: 2,
//                 icon: Icons.event_note_outlined,
//                 selectedIcon: Icons.event_note,
//                 label: isArabic ? 'الفعاليات' : 'events',
//                 isSelected: currentIndex == 2,
//                 themeProvider: themeProvider,
//                 useBlueCircle: true,
//               ),
//               _buildNavItem(
//                 index: 3,
//                 icon: Icons.inventory_2_outlined,
//                 selectedIcon: Icons.inventory_2,
//                 label: isArabic ? 'المخزون' : 'inventory',
//                 isSelected: currentIndex == 3,
//                 themeProvider: themeProvider,
//               ),
//               _buildNavItem(
//                 index: 4,
//                 icon: Icons.settings_outlined,
//                 selectedIcon: Icons.settings,
//                 label: isArabic ? 'الإعدادات' : 'settings',
//                 isSelected: currentIndex == 4,
//                 themeProvider: themeProvider,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem({
//     required int index,
//     required IconData icon,
//     required IconData selectedIcon,
//     required String label,
//     required bool isSelected,
//     required ThemeProvider themeProvider,
//     bool useBlueCircle = false,
//   }) {
//     final Color activeColor = AppTheme.primaryBlue;
//     final Color inactiveColor = themeProvider.isDarkMode
//         ? Colors.white70
//         : Colors.grey;
//
//     return InkWell(
//       onTap: () => onTap(index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               if (isSelected && useBlueCircle)
//                 Container(
//                   width: 48.w,
//                   height: 48.h,
//                   decoration: BoxDecoration(
//                     color: AppTheme.primaryBlue.withOpacity(0.1),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               Icon(
//                 isSelected ? selectedIcon : icon,
//                 color: isSelected ? activeColor : inactiveColor,
//                 size: 24.sp,
//               ),
//             ],
//           ),
//           SizedBox(height: 4.h),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: isSelected ? activeColor : inactiveColor,
//               fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }