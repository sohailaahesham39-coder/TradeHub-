import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/settings/settings_screen.dart';
import '../models/Product%20Model.dart';
import '../screens/inventory/Inventory%20Screen.dart'; // Import InventoryScreen
import '../screens/events/Events%20Screen.dart'; // Import EventsScreen
import '../screens/home/Home%20Screen.dart'; // Import HomeScreen
import '../settings/ProfileScreen.dart'; // Import ProfileScreen (for Settings)

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 1; // Search tab is selected by default
  String _selectedFilter = 'all';
  bool _isSearching = false;
  bool _showFilterPanel = false;
  bool _isAdvancedSearch = false;

  // Date range filter
  DateTime? _startDate;
  DateTime? _endDate;

  // Price range filter
  RangeValues _priceRange = const RangeValues(0, 1000);

  // Sort options
  String _sortBy = 'relevance';

  List<Product> _searchResults = [];
  List<String> _recentSearches = [
    'Organic Products',
    'Electronic Components',
    'Office Supplies',
    'Packaging Materials',
  ];

  final List<Map<String, dynamic>> _filterOptions = [
    {
      'id': 'all',
      'name_en': 'All',
      'name_ar': 'الكل',
      'icon': Icons.apps,
    },
    {
      'id': 'suppliers',
      'name_en': 'Suppliers',
      'name_ar': 'الموردين',
      'icon': Icons.inventory_2_outlined,
    },
    {
      'id': 'distributors',
      'name_en': 'Distributors',
      'name_ar': 'الموزعين',
      'icon': Icons.local_shipping_outlined,
    },
    {
      'id': 'products',
      'name_en': 'Products',
      'name_ar': 'المنتجات',
      'icon': Icons.shopping_bag_outlined,
    },
    {
      'id': 'events',
      'name_en': 'Events',
      'name_ar': 'الفعاليات',
      'icon': Icons.event_note_outlined,
    },
  ];

  final List<Map<String, dynamic>> _sortOptions = [
    {
      'id': 'relevance',
      'name_en': 'Relevance',
      'name_ar': 'الصلة',
      'icon': Icons.sort,
    },
    {
      'id': 'price_low',
      'name_en': 'Price: Low to High',
      'name_ar': 'السعر: من الأقل إلى الأعلى',
      'icon': Icons.arrow_upward,
    },
    {
      'id': 'price_high',
      'name_en': 'Price: High to Low',
      'name_ar': 'السعر: من الأعلى إلى الأقل',
      'icon': Icons.arrow_downward,
    },
    {
      'id': 'newest',
      'name_en': 'Newest First',
      'name_ar': 'الأحدث أولاً',
      'icon': Icons.calendar_today,
    },
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'furniture',
      'name_en': 'Furniture',
      'name_ar': 'أثاث',
      'icon': Icons.chair,
    },
    {
      'id': 'electronics',
      'name_en': 'Electronics',
      'name_ar': 'إلكترونيات',
      'icon': Icons.devices,
    },
    {
      'id': 'food',
      'name_en': 'Food & Beverages',
      'name_ar': 'طعام ومشروبات',
      'icon': Icons.fastfood,
    },
    {
      'id': 'clothing',
      'name_en': 'Clothing',
      'name_ar': 'ملابس',
      'icon': Icons.checkroom,
    },
    {
      'id': 'health',
      'name_en': 'Health & Beauty',
      'name_ar': 'صحة وجمال',
      'icon': Icons.spa,
    },
  ];

  final List<Product> _mockProducts = [
    Product(
      id: '1',
      name: 'Premium Leather Chairs',
      category: 'Furniture',
      price: 299.99,
      quantity: 45,
      imageUrl: 'https://example.com/images/tradehub/products/chair.jpg',
      supplierId: 'sup001',
      supplierName: 'Modern Furnishings Ltd.',
    ),
    Product(
      id: '2',
      name: 'Smart LED Bulbs (5-Pack)',
      category: 'Electronics',
      price: 59.99,
      quantity: 120,
      imageUrl: 'https://example.com/images/tradehub/products/bulbs.jpg',
      supplierId: 'sup002',
      supplierName: 'EcoLight Systems',
    ),
    Product(
      id: '3',
      name: 'Organic Green Tea (Bulk)',
      category: 'Food & Beverages',
      price: 45.50,
      quantity: 80,
      imageUrl: 'https://example.com/images/tradehub/products/tea.jpg',
      supplierId: 'sup003',
      supplierName: 'Natural Harvests Co.',
    ),
    Product(
      id: '4',
      name: 'Ergonomic Office Chair',
      category: 'Furniture',
      price: 249.99,
      quantity: 35,
      imageUrl: 'https://example.com/images/tradehub/products/ergonomic_chair.jpg',
      supplierId: 'sup001',
      supplierName: 'Modern Furnishings Ltd.',
    ),
    Product(
      id: '5',
      name: 'Bluetooth Speakers',
      category: 'Electronics',
      price: 89.99,
      quantity: 60,
      imageUrl: 'https://example.com/images/tradehub/products/speaker.jpg',
      supplierId: 'sup002',
      supplierName: 'EcoLight Systems',
    ),
  ];

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;

      // Apply filters to search results
      _searchResults = _mockProducts
          .where((product) =>
      product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.category.toLowerCase().contains(query.toLowerCase()) ||
          product.supplierName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Apply price filter if using advanced search
      if (_isAdvancedSearch) {
        _searchResults = _searchResults
            .where((product) =>
        product.price >= _priceRange.start && product.price <= _priceRange.end)
            .toList();
      }

      // Apply sorting
      switch (_sortBy) {
        case 'price_low':
          _searchResults.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _searchResults.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'newest':
        // For demonstration, we're not sorting by date since our mock data doesn't have dates
          break;
        case 'relevance':
        default:
        // Relevance sorting would typically be more complex and based on multiple factors
          break;
      }
    });

    if (!_recentSearches.contains(query) && query.isNotEmpty) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _searchResults = [];
    });
  }

  void _toggleFilterPanel() {
    setState(() {
      _showFilterPanel = !_showFilterPanel;
    });
  }

  void _toggleAdvancedSearch() {
    setState(() {
      _isAdvancedSearch = !_isAdvancedSearch;
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final isArabic = Provider.of<LocalizationProvider>(context, listen: false).isArabic;
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: themeProvider.isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
              onSurface: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            dialogBackgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
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
                isArabic ? 'البحث' : 'Search',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                ),
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
                      _showFilterPanel ? Icons.close : Icons.tune,
                      size: 22.sp,
                      color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                    ),
                  ),
                  onPressed: _toggleFilterPanel,
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
                Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: _buildSearchBar(context, themeProvider),
                    ),

                    // Filter chips
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: _buildFilterChips(isArabic, themeProvider),
                    ),

                    SizedBox(height: 8.h),

                    // Main content area
                    Expanded(
                      child: Stack(
                        children: [
                          // Search results or recent searches
                          _isSearching
                              ? _buildSearchResults(themeProvider)
                              : _buildRecentSearches(isArabic, themeProvider),

                          // Filter panel - animated slide-in from the right
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            right: _showFilterPanel ? 0 : -320.w,
                            top: 0,
                            bottom: 0,
                            width: 300.w,
                            child: _buildFilterPanel(context, isArabic, themeProvider),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeProvider themeProvider) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      borderRadius: 16,
      padding: EdgeInsets.zero,
      child: TextField(
        controller: _searchController,
        onChanged: _performSearch,
        style: TextStyle(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          hintText: isArabic ? 'ابحث عن المنتجات أو الموردين...' : 'Search products, suppliers...',
          hintStyle: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white60 : Colors.black45,
            fontSize: 16.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
            size: 22.sp,
          ),
          suffixIcon: _isSearching
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              size: 22.sp,
            ),
            onPressed: _clearSearch,
          )
              : Icon(
            Icons.mic,
            color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
            size: 22.sp,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        ),
      ),
    );
  }

  Widget _buildFilterChips(bool isArabic, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filterOptions.map((filter) {
          final isSelected = _selectedFilter == filter['id'];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: _buildGlassmorphicChip(
              label: isArabic ? filter['name_ar'] : filter['name_en'],
              icon: filter['icon'],
              isSelected: isSelected,
              themeProvider: themeProvider,
              onTap: () {
                setState(() {
                  _selectedFilter = filter['id'];
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGlassmorphicChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(themeProvider.isDarkMode ? 0.7 : 0.8)
              : themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isSelected
                  ? Colors.white
                  : themeProvider.isDarkMode
                  ? Colors.white70
                  : AppTheme.primaryBlue,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Colors.white
                    : themeProvider.isDarkMode
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context, bool isArabic, ThemeProvider themeProvider) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: themeProvider.isDarkMode
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.7),
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isArabic ? 'الفلاتر' : 'Filters',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedFilter = 'all';
                          _sortBy = 'relevance';
                          _priceRange = const RangeValues(0, 1000);
                          _startDate = null;
                          _endDate = null;
                          _isAdvancedSearch = false;
                        });
                      },
                      child: Text(
                        isArabic ? 'إعادة ضبط' : 'Reset',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                SwitchListTile(
                  title: Text(
                    isArabic ? 'بحث متقدم' : 'Advanced Search',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  value: _isAdvancedSearch,
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (value) {
                    setState(() {
                      _isAdvancedSearch = value;
                    });
                  },
                ),
                if (_isAdvancedSearch) ...[
                  SizedBox(height: 16.h),
                  Text(
                    isArabic ? 'نطاق السعر' : 'Price Range',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${_priceRange.start.toInt()}',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      Text(
                        '\$${_priceRange.end.toInt()}',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    activeColor: AppTheme.primaryBlue,
                    inactiveColor: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                    labels: RangeLabels(
                      '\$${_priceRange.start.toInt()}',
                      '\$${_priceRange.end.toInt()}',
                    ),
                    onChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isArabic ? 'نطاق التاريخ' : 'Date Range',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () => _selectDateRange(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: themeProvider.isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18.sp,
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _startDate != null && _endDate != null
                                ? '${DateFormat('MMM d, y').format(_startDate!)} - ${DateFormat('MMM d, y').format(_endDate!)}'
                                : isArabic
                                ? 'اختر نطاق التاريخ'
                                : 'Select date range',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                Text(
                  isArabic ? 'الفئات' : 'Categories',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _categories.map((category) {
                    return _buildGlassmorphicChip(
                      label: isArabic ? category['name_ar'] : category['name_en'],
                      icon: category['icon'],
                      isSelected: false,
                      themeProvider: themeProvider,
                      onTap: () {},
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
                Text(
                  isArabic ? 'ترتيب حسب' : 'Sort By',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sortOptions.length,
                  itemBuilder: (context, index) {
                    final option = _sortOptions[index];
                    final isSelected = _sortBy == option['id'];
                    return ListTile(
                      leading: Icon(
                        option['icon'],
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : themeProvider.isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                      ),
                      title: Text(
                        isArabic ? option['name_ar'] : option['name_en'],
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryBlue,
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          _sortBy = option['id'];
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: 16.h), // Padding before the button
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: () {
                      _toggleFilterPanel();
                      if (_searchController.text.isNotEmpty) {
                        _performSearch(_searchController.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isArabic ? 'تطبيق الفلاتر' : 'Apply Filters',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    EdgeInsetsGeometry padding = const EdgeInsets.all(8),
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

  Widget _buildSearchResults(ThemeProvider themeProvider) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    if (_searchResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: _buildGlassmorphicContainer(
            themeProvider: themeProvider,
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 40.sp,
                    color: themeProvider.isDarkMode ? Colors.white54 : AppTheme.primaryBlue,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  isArabic ? 'لا توجد نتائج' : 'No Results Found',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  isArabic
                      ? 'حاول البحث بمصطلحات مختلفة أو تصفية معايير البحث'
                      : 'Try searching with different terms or filtering criteria',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: 200.w,
                  child: OutlinedButton(
                    onPressed: _toggleFilterPanel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: BorderSide(color: AppTheme.primaryBlue),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tune, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(
                          isArabic ? 'تعديل الفلاتر' : 'Adjust Filters',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic
                    ? '${_searchResults.length} نتائج البحث'
                    : '${_searchResults.length} Results Found',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: _toggleFilterPanel,
                icon: Icon(
                  Icons.filter_list,
                  size: 18.sp,
                  color: AppTheme.primaryBlue,
                ),
                label: Text(
                  isArabic ? 'فلتر' : 'Filter',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 14.sp,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return _buildProductCard(_searchResults[index], themeProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, ThemeProvider themeProvider) {
    // Enhanced product card with glassmorphism
    return _buildGlassmorphicContainer(
      themeProvider: themeProvider,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image - make height more flexible with Expanded
          Expanded(
            flex: 4, // Give image area 40% of the available height
            child: Container(
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(product.category),
                  size: 40.sp,
                  color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
                ),
              ),
            ),
          ),

          // Content area - make this flexible too
          Expanded(
            flex: 6, // Give content area 60% of the available height
            child: Padding(
              padding: EdgeInsets.all(8.w), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category - smaller with reduced padding
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: themeProvider.isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 9.sp, // Smaller font
                        color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h), // Reduced spacing

                  // Product name
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 13.sp, // Slightly smaller font
                      fontWeight: FontWeight.bold,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h), // Reduced spacing

                  // Supplier name - make this an Expanded widget to take available space
                  Expanded(
                    child: Text(
                      product.supplierName,
                      style: TextStyle(
                        fontSize: 11.sp, // Smaller font
                        color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Price and add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Wrap the price in Flexible to allow it to shrink if needed
                      Flexible(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp, // Reduced size
                            fontWeight: FontWeight.bold,
                            color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
                          ),
                          overflow: TextOverflow.ellipsis, // Handle text overflow
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 4.w), // Small gap
                      // Make the button smaller and fixed size
                      Container(
                        width: 28.w, // Fixed width
                        height: 28.w, // Fixed height
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16.sp, // Smaller icon
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'furniture':
        return Icons.chair;
      case 'electronics':
        return Icons.devices;
      case 'food & beverages':
        return Icons.fastfood;
      case 'clothing':
        return Icons.checkroom;
      default:
        return Icons.category;
    }
  }

  Widget _buildRecentSearches(bool isArabic, ThemeProvider themeProvider) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'البحوث الأخيرة' : 'Recent Searches',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _recentSearches.clear();
                    });
                  },
                  child: Text(
                    isArabic ? 'مسح' : 'Clear',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Recent searches list - set a fixed height or use Flexible with flex
          _recentSearches.isEmpty
              ? Center(
            child: _buildGlassmorphicContainer(
              themeProvider: themeProvider,
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 48.sp,
                    color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isArabic ? 'لا توجد عمليات بحث سابقة' : 'No recent searches',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
              : Container(
            height: 200.h, // Fixed height for the list
            child: ListView.builder(
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _buildGlassmorphicContainer(
                    themeProvider: themeProvider,
                    child: ListTile(
                      leading: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: themeProvider.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : AppTheme.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history,
                          color: themeProvider.isDarkMode
                              ? Colors.white70
                              : AppTheme.primaryBlue,
                          size: 20.sp,
                        ),
                      ),
                      title: Text(
                        _recentSearches[index],
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      trailing: Icon(
                        Icons.north_west,
                        color: themeProvider.isDarkMode ? Colors.white54 : Colors.black45,
                        size: 16.sp,
                      ),
                      onTap: () {
                        _searchController.text = _recentSearches[index];
                        _performSearch(_recentSearches[index]);
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Trending searches section
          if (_recentSearches.isNotEmpty) ...[
            SizedBox(height: 24.h),
            Text(
              isArabic ? 'عمليات البحث الشائعة' : 'Trending Searches',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildTrendingSearchChip('Electronic Components', themeProvider),
                _buildTrendingSearchChip('Organic Supplies', themeProvider),
                _buildTrendingSearchChip('Office Furniture', themeProvider),
                _buildTrendingSearchChip('LED Lighting', themeProvider),
                _buildTrendingSearchChip('Packaging Materials', themeProvider),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendingSearchChip(String label, ThemeProvider themeProvider) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.2)
                : Colors.white.withOpacity(0.8),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.trending_up,
              size: 14.sp,
              color: themeProvider.isDarkMode ? Colors.white70 : AppTheme.primaryBlue,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
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
      // Already on SearchScreen, do nothing
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InventoryScreen()),
        );
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