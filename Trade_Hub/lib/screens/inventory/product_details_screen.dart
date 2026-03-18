import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/models/Product%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  String _selectedTab = 'details';
  final List<Map<String, String>> _tabs = [
    {'id': 'details', 'name_en': 'Details', 'name_ar': 'التفاصيل'},
    {'id': 'specifications', 'name_en': 'Specifications', 'name_ar': 'المواصفات'},
    {'id': 'reviews', 'name_en': 'Reviews', 'name_ar': 'التقييمات'},
  ];

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 16.h),
                _buildProductTitleSection(context, isArabic),
                SizedBox(height: 24.h),
                _buildTabBar(context, isArabic),
                SizedBox(height: 16.h),
                _buildTabContent(context, isArabic),
                SizedBox(height: 24.h),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, isArabic),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 320.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PageView.builder(
              itemCount: widget.product.additionalImages != null
                  ? (widget.product.additionalImages!.length + 1)
                  : 1,
              onPageChanged: (index) {
                setState(() {
                  _selectedImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final imageUrl = index == 0
                    ? widget.product.imageUrl
                    : widget.product.additionalImages![index - 1];
                return AppImageHandler.loadProductImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
            if (widget.product.additionalImages != null && widget.product.additionalImages!.isNotEmpty)
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.additionalImages!.length + 1,
                        (index) => Container(
                      width: 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _selectedImageIndex == index
                            ? AppTheme.primaryBlue // Updated
                            : AppTheme.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.product.isDiscounted)
              Positioned(
                top: 50.h,
                left: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed, // Updated
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    widget.product.getDiscountText(),
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (widget.product.isOutOfStock || widget.product.isLowStock)
              Positioned(
                top: 50.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: widget.product.isOutOfStock ? AppTheme.errorRed : AppTheme.warningOrange, // Updated
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    widget.product.isOutOfStock
                        ? (Provider.of<LocalizationProvider>(context).isArabic ? 'نفذت الكمية' : 'OUT OF STOCK')
                        : (Provider.of<LocalizationProvider>(context).isArabic ? 'مخزون منخفض' : 'LOW STOCK'),
                    style: TextStyle(
                      color: AppTheme.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: AppTheme.black, size: 20.sp),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.product.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: widget.product.isBookmarked ? AppTheme.primaryBlue : AppTheme.black, // Updated
              size: 20.sp,
            ),
          ),
          onPressed: () {
            setState(() {
              widget.product.isBookmarked = !widget.product.isBookmarked;
            });
          },
        ),
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.share, color: AppTheme.black, size: 20.sp),
          ),
          onPressed: () {
            // Implement share functionality here
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildProductTitleSection(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.category,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.primaryBlue, // Updated
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: 4.h),
        Text(
          widget.product.name,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'المورد:' : 'Supplier:',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              widget.product.supplierName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (widget.product.rating != null)
          Row(
            mainAxisAlignment: isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < (widget.product.rating ?? 0).floor()
                      ? Icons.star
                      : (index < (widget.product.rating ?? 0) ? Icons.star_half : Icons.star_border),
                  color: AppTheme.warningOrange, // Updated
                  size: 18.sp,
                );
              }),
              SizedBox(width: 4.w),
              Text(
                '${widget.product.rating}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.product.reviewCount != null)
                Text(
                  ' (${widget.product.reviewCount})',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
            ],
          ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Text(
              widget.product.getFormattedPrice(isArabic ? 'د.إ' : '\$'),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: widget.product.isDiscounted ? AppTheme.errorRed : AppTheme.primaryBlue, // Updated
              ),
            ),
            if (widget.product.isDiscounted)
              Padding(
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                child: Text(
                  widget.product.getFormattedOriginalPrice(isArabic ? 'د.إ' : '\$'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    decoration: TextDecoration.lineThrough,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
          ],
        ),
        if (widget.product.isDiscounted && widget.product.discountEndDate != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              isArabic
                  ? 'العرض ينتهي في ${widget.product.discountEndDate!.day}/${widget.product.discountEndDate!.month}/${widget.product.discountEndDate!.year}'
                  : 'Offer ends on ${widget.product.discountEndDate!.day}/${widget.product.discountEndDate!.month}/${widget.product.discountEndDate!.year}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.errorRed, // Updated
              ),
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
          ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, bool isArabic) {
    return Row(
      mainAxisAlignment: isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: _tabs.map((tab) {
        final isSelected = _selectedTab == tab['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTab = tab['id']!;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            margin: EdgeInsets.only(right: isArabic ? 0 : 16.w, left: isArabic ? 16.w : 0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? AppTheme.primaryBlue : Colors.transparent, // Updated
                  width: 2.w,
                ),
              ),
            ),
            child: Text(
              isArabic ? tab['name_ar']! : tab['name_en']!,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.primaryBlue : Theme.of(context).textTheme.bodyMedium?.color, // Updated
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabContent(BuildContext context, bool isArabic) {
    switch (_selectedTab) {
      case 'details':
        return _buildDetailsTab(context, isArabic);
      case 'specifications':
        return _buildSpecificationsTab(context, isArabic);
      case 'reviews':
        return _buildReviewsTab(context, isArabic);
      default:
        return _buildDetailsTab(context, isArabic);
    }
  }

  Widget _buildDetailsTab(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.description ??
              (isArabic ? 'لا يوجد وصف متاح لهذا المنتج.' : 'No description available for this product.'),
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            height: 1.5,
          ),
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
        ),
        SizedBox(height: 24.h),
        if (widget.product.tags != null && widget.product.tags!.isNotEmpty)
          Column(
            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'العلامات:' : 'Tags:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: widget.product.tags!.map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1), // Updated
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.primaryBlue, // Updated
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        SizedBox(height: 24.h),
        _buildSupplierInfo(context, isArabic),
      ],
    );
  }

  Widget _buildSpecificationsTab(BuildContext context, bool isArabic) {
    if (widget.product.attributes == null || widget.product.attributes!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Text(
            isArabic ? 'لا توجد مواصفات متاحة' : 'No specifications available',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.product.attributes!.length,
      separatorBuilder: (context, index) => Divider(height: 1.h),
      itemBuilder: (context, index) {
        final entry = widget.product.attributes!.entries.elementAt(index);
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(BuildContext context, bool isArabic) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48.sp,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'لا توجد تقييمات حتى الآن' : 'No reviews yet',
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplierInfo(BuildContext context, bool isArabic) {
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
            isArabic ? 'معلومات المورد:' : 'Supplier Information:',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1), // Updated
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.business,
                    color: AppTheme.primaryBlue, // Updated
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.supplierName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      isArabic ? 'مورد معتمد' : 'Verified Supplier',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.successGreen, // Updated
                      ),
                      textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              OutlinedButton.icon(
                onPressed: () {
                  // Connect with supplier logic
                },
                icon: Icon(Icons.message_outlined, size: 18.sp),
                label: Text(
                  isArabic ? 'تواصل' : 'Contact',
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue, // Updated
                  side: BorderSide(color: AppTheme.primaryBlue), // Updated
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isArabic) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 18.sp),
                    onPressed: _quantity > 1
                        ? () {
                      setState(() {
                        _quantity--;
                      });
                    }
                        : null,
                    constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                    padding: EdgeInsets.zero,
                  ),
                  Container(
                    width: 40.w,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 18.sp),
                    onPressed: _quantity < (widget.product.quantity)
                        ? () {
                      setState(() {
                        _quantity++;
                      });
                    }
                        : null,
                    constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.product.isOutOfStock
                    ? null
                    : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isArabic
                            ? 'تمت إضافة $_quantity من ${widget.product.name} إلى سلة التسوق'
                            : 'Added $_quantity ${widget.product.name} to cart',
                      ),
                      backgroundColor: AppTheme.successGreen, // Updated
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: Icon(Icons.shopping_cart, size: 20.sp),
                label: Text(
                  widget.product.isOutOfStock
                      ? (isArabic ? 'غير متوفر' : 'Out of Stock')
                      : (isArabic ? 'أضف إلى السلة' : 'Add to Cart'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue, // Updated
                  foregroundColor: AppTheme.white, // Updated
                  disabledBackgroundColor: Colors.grey,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}