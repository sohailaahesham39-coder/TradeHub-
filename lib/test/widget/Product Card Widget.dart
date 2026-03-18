import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/models/Product%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCardWidget({
    Key? key,
    required this.product,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onTap: onTap ?? () {
        // Navigate to product details (placeholder)
      },
      child: Container(
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: AppImageHandler.loadProductImage(
                    imageUrl: product.imageUrl,
                    height: 120.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.h,
                  left: isArabic ? null : 8.w,
                  right: isArabic ? 8.w : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8.h,
                  right: isArabic ? null : 8.w,
                  left: isArabic ? 8.w : null,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.black.withOpacity(0.7)
                          : Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      product.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: AppTheme.primaryColor,
                      size: 18.sp,
                    ),
                  ),
                ),
                if (product.isOutOfStock || product.isLowStock)
                  Positioned(
                    bottom: 8.h,
                    right: isArabic ? null : 8.w,
                    left: isArabic ? 8.w : null,
                    child: _buildStockLabel(context, isArabic),
                  ),
              ],
            ),

            // Product Info
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    product.supplierName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.isDiscounted && product.isDiscountActive())
                            Text(
                              product.getFormattedOriginalPrice('\$'),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: themeProvider.isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            product.getFormattedPrice('\$'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (!product.isOutOfStock)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _getStockColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            product.getStockQuantity(isArabic),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: _getStockColor(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStockColor() {
    if (product.isOutOfStock) {
      return AppTheme.errorRed;
    } else if (product.isLowStock) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.successGreen;
    }
  }

  Widget _buildStockLabel(BuildContext context, bool isArabic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: product.isOutOfStock
            ? AppTheme.errorRed.withOpacity(0.9)
            : AppTheme.warningOrange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        product.getStockStatus(isArabic),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}