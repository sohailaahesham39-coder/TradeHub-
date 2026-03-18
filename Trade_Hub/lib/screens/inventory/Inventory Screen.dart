import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/screens/inventory/add_product_screen.dart';
import 'package:trade_hub/screens/inventory/product_details_screen.dart';
import 'package:trade_hub/settings/ProfileScreen.dart';
import '../../models/Product%20Model.dart';
import '../../providers/Localization%20Provider.dart';
import '../../search/Search%20Screen.dart';
import '../../test/unit/AppImageHandler%20Utility%20.dart';
import '../../test/widget/Product%20Card%20Widget.dart';
import '../events/Events%20Screen.dart';
import '../home/Home%20Screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 3; // Inventory tab is selected by default
  String _selectedTab = 'all';
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _tabs = [
    {'id': 'all', 'name_en': 'All Products', 'name_ar': 'جميع المنتجات'},
    {'id': 'low_stock', 'name_en': 'Low Stock', 'name_ar': 'مخزون منخفض'},
    {'id': 'out_of_stock', 'name_en': 'Out of Stock', 'name_ar': 'نفذت الكمية'},
  ];

  final Map<String, String> _placeholderImages = {
    'chair': 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'bulbs': 'https://images.unsplash.com/photo-1619998713163-8f0d25d74fca?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'tea': 'https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'charger': 'https://images.unsplash.com/photo-1623126908029-58c1502b0952?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'furniture': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'electronics': 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
    'food': 'https://images.unsplash.com/photo-1607257971533-da2160d93e3d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
  };

  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Premium Leather Chairs',
      category: 'Furniture',
      price: 299.99,
      quantity: 5,
      imageUrl: 'https://example.com/images/tradehub/products/chair.jpg',
      supplierId: 'sup001',
      supplierName: 'Modern Furnishings Ltd.',
      isLowStock: true,
      isOutOfStock: false,
    ),
    Product(
      id: '2',
      name: 'Smart LED Bulbs (5-Pack)',
      category: 'Electronics',
      price: 59.99,
      quantity: 20,
      imageUrl: 'https://example.com/images/tradehub/products/bulbs.jpg',
      supplierId: 'sup002',
      supplierName: 'EcoLight Systems',
      isLowStock: false,
      isOutOfStock: false,
    ),
    Product(
      id: '3',
      name: 'Organic Green Tea (Bulk)',
      category: 'Food & Beverages',
      price: 45.50,
      quantity: 0,
      imageUrl: 'https://example.com/images/tradehub/products/tea.jpg',
      supplierId: 'sup003',
      supplierName: 'Natural Harvests Co.',
      isLowStock: false,
      isOutOfStock: true,
    ),
    Product(
      id: '4',
      name: 'Wireless Charging Pad',
      category: 'Electronics',
      price: 29.99,
      quantity: 3,
      imageUrl: 'https://example.com/images/tradehub/products/charger.jpg',
      supplierId: 'sup004',
      supplierName: 'TechGear Solutions',
      isLowStock: true,
      isOutOfStock: false,
    ),
    Product(
      id: '5',
      name: 'Oak Dining Table',
      category: 'Furniture',
      price: 599.99,
      quantity: 2,
      imageUrl: 'https://example.com/images/tradehub/products/furniture.jpg',
      supplierId: 'sup001',
      supplierName: 'Modern Furnishings Ltd.',
      isLowStock: true,
      isOutOfStock: false,
    ),
    Product(
      id: '6',
      name: 'Bluetooth Headphones',
      category: 'Electronics',
      price: 89.99,
      quantity: 12,
      imageUrl: 'https://example.com/images/tradehub/products/electronics.jpg',
      supplierId: 'sup002',
      supplierName: 'TechGear Solutions',
      isLowStock: false,
      isOutOfStock: false,
    ),
  ];

  List<Product> get _currentProducts {
    List<Product> filtered = _products;
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((product) =>
      product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          product.category.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }
    switch (_selectedTab) {
      case 'all':
        return filtered;
      case 'low_stock':
        return filtered.where((product) => product.isLowStock).toList();
      case 'out_of_stock':
        return filtered.where((product) => product.isOutOfStock).toList();
      default:
        return filtered;
    }
  }

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

    _patchProductImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppImageHandler.preloadImages(context, _products.map((p) => p.imageUrl).toList());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    AppImageHandler.customCacheManager.dispose();
    super.dispose();
  }

  void _patchProductImages() {
    for (var product in _products) {
      String url = product.imageUrl;
      if (url.contains('example.com') || !AppImageHandler.isValidImageUrl(url)) {
        if (url.contains('chair.jpg')) {
          product.imageUrl = _placeholderImages['chair']!;
        } else if (url.contains('bulbs.jpg')) {
          product.imageUrl = _placeholderImages['bulbs']!;
        } else if (url.contains('tea.jpg')) {
          product.imageUrl = _placeholderImages['tea']!;
        } else if (url.contains('charger.jpg')) {
          product.imageUrl = _placeholderImages['charger']!;
        } else if (url.contains('furniture.jpg')) {
          product.imageUrl = _placeholderImages['furniture']!;
        } else if (url.contains('electronics.jpg')) {
          product.imageUrl = _placeholderImages['electronics']!;
        } else if (url.contains('food.jpg')) {
          product.imageUrl = _placeholderImages['food']!;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isArabic = localizationProvider.isArabic;

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
                  color: AppTheme.primaryBlue.withOpacity(0.2),
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
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildSearchBar(themeProvider),
                  _buildTabBar(themeProvider),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: _buildInventorySummary(themeProvider),
                  ),
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
                              color: AppTheme.primaryBlue,
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
                                    : AppTheme.primaryBlue,
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
                      child: _currentProducts.isEmpty
                          ? _buildEmptyState(themeProvider)
                          : GridView.builder(
                        padding: EdgeInsets.all(16.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                        ),
                        itemCount: _currentProducts.length,
                        itemBuilder: (context, index) {
                          return ProductCardWidget(
                            product: _currentProducts[index] as dynamic,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailsScreen(
                                    product: _currentProducts[index] as dynamic,
                                  ),
                                ),
                              );
                            },
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
              isArabic ? 'المخزون' : 'Inventory',
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
                  isArabic ? Icons.arrow_forward : Icons.arrow_back,
                  size: 22.sp,
                  color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
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
                        : AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.refresh,
                    size: 22.sp,
                    color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                  ),
                ),
                onPressed: _refreshData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: _buildGlassmorphicContainer(
        themeProvider: themeProvider,
        borderRadius: 12,
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() {}),
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 16.sp,
          ),
          decoration: InputDecoration(
            hintText: isArabic ? 'البحث عن المنتجات...' : 'Search products...',
            hintStyle: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16.sp,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
              size: 20.sp,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
              icon: Icon(
                Icons.clear,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                size: 20.sp,
              ),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
            filled: false,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab['id'];
          return InkWell(
            onTap: () {
              setState(() {
                _selectedTab = tab['id']!;
                _isLoading = true;
                Future.delayed(const Duration(milliseconds: 500), () {
                  setState(() => _isLoading = false);
                });
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryBlue
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
                    color: AppTheme.primaryBlue.withOpacity(0.3),
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
    );
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

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      _showCustomSnackBar(
        context,
        Provider.of<LocalizationProvider>(context, listen: false).isArabic
            ? 'تم تحديث المخزون بنجاح'
            : 'Inventory refreshed successfully',
      );
    });
  }

  void _showCustomSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 40.h,
        left: 20.w,
        right: 20.w,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  Widget _buildInventorySummary(ThemeProvider themeProvider) {
    final allProducts = _products.length;
    final lowStock = _products.where((p) => p.isLowStock).length;
    final outOfStock = _products.where((p) => p.isOutOfStock).length;
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            count: allProducts,
            label: isArabic ? 'المنتجات' : 'Products',
            icon: Icons.inventory_2_outlined,
            color: AppTheme.primaryBlue,
            themeProvider: themeProvider,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSummaryCard(
            count: lowStock,
            label: isArabic ? 'مخزون منخفض' : 'Low Stock',
            icon: Icons.warning_amber_outlined,
            color: AppTheme.warningOrange,
            themeProvider: themeProvider,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSummaryCard(
            count: outOfStock,
            label: isArabic ? 'نفذت الكمية' : 'Out of Stock',
            icon: Icons.error_outline,
            color: AppTheme.errorRed,
            themeProvider: themeProvider,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
    required ThemeProvider themeProvider,
  }) {
    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      borderRadius: 12,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    final isArabic = Provider.of<LocalizationProvider>(context).isArabic;

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
                      : AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 40.sp,
                  color: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.7)
                      : AppTheme.primaryBlue,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                isArabic ? 'لا توجد منتجات' : 'No Products Available',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                isArabic
                    ? 'لا توجد منتجات في هذا القسم حالياً'
                    : 'There are no products in this section currently',
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
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddProductScreen(),
                          ),
                        ).then((_) => _refreshData);
                      },
                      icon: Icon(Icons.add, size: 20.sp),
                      label: Text(
                        isArabic ? 'إضافة منتج جديد' : 'Add New Product',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        elevation: 0,
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
            color: AppTheme.primaryBlue.withOpacity(0.3),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddProductScreen(),
                ),
              ).then((_) => _refreshData);
            },
            backgroundColor: AppTheme.primaryBlue,
            child: Icon(Icons.add, size: 24.sp, color: Colors.white),
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
        selectedItemColor: AppTheme.primaryBlue,
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
        break;
      case 3:
      // Already on InventoryScreen, do nothing
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }
}