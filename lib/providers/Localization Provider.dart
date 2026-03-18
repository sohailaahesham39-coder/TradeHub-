import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LocalizationProvider with ChangeNotifier {
  static const String _languageKey = 'language_code';
  bool _isArabic = false;

  LocalizationProvider() {
    _loadLanguagePreference();
  }

  bool get isArabic => _isArabic;

  Locale get locale => _isArabic ? const Locale('ar', 'SA') : const Locale('en', 'US');

  Future<void> _loadLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isArabic = prefs.getBool(_languageKey) ?? false;
      notifyListeners();
    } catch (e) {
      // Default to English if error occurs
      _isArabic = false;
    }
  }

  Future<void> toggleLanguage() async {
    _isArabic = !_isArabic;
    notifyListeners(); // This is important to update UI

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_languageKey, _isArabic);
    } catch (e) {
      // Handle error
      print('Error saving language preference: $e');
    }
  }

  // Method to toggle locale with a specific value
  Future<void> toggleLocale(bool value) async {
    if (_isArabic != value) {
      _isArabic = value;
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_languageKey, _isArabic);
      } catch (e) {
        // Handle error
        print('Error saving language preference: $e');
      }
    }
  }
}

// Extension for string localization
extension StringLocalization on String {
  String tr(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
    final isArabic = localizationProvider.isArabic;

    // Map of English to Arabic translations
    final translations = {
      // General
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'search': 'بحث',
      'view_all': 'عرض الكل',
      'apply': 'تطبيق',
      'filter': 'تصفية',
      'sort': 'ترتيب',

      // Navigation
      'home': 'الرئيسية',
      'events': 'الفعاليات',
      'inventory': 'المخزون',
      'settings': 'الإعدادات',
      'profile': 'الملف الشخصي',

      // Home Screen
      'trending_products': 'المنتجات الرائجة',
      'upcoming_events': 'الفعاليات القادمة',
      'recent_connections': 'الاتصالات الحديثة',
      'inventory_status': 'حالة المخزون',
      'business_tips': 'نصائح للأعمال',

      // Inventory
      'total_products': 'إجمالي المنتجات',
      'low_stock': 'مخزون منخفض',
      'out_of_stock': 'نفذت الكمية',
      'in_stock': 'متوفر',
      'add_product': 'إضافة منتج',
      'search_products': 'البحث عن منتجات',
      'manage_inventory': 'إدارة المخزون',

      // Events
      'book_ticket': 'حجز تذكرة',
      'event_details': 'تفاصيل الفعالية',
      'filter_events': 'تصفية الفعاليات',
      'book_now': 'حجز الآن',
      'join_event': 'انضم للفعالية',
      'date': 'التاريخ',
      'time': 'الوقت',
      'location': 'الموقع',
      'organizer': 'المنظم',
      'attendees': 'الحاضرين',

      // Product Details
      'add_to_cart': 'إضافة إلى السلة',
      'product_details': 'تفاصيل المنتج',
      'specifications': 'المواصفات',
      'reviews': 'التقييمات',
      'supplier': 'المورد',
      'quantity': 'الكمية',
      'price': 'السعر',
      'description': 'الوصف',

      // Payment
      'payment_details': 'تفاصيل الدفع',
      'card_number': 'رقم البطاقة',
      'card_holder': 'اسم حامل البطاقة',
      'expiry_date': 'تاريخ الانتهاء',
      'cvv': 'رمز التحقق',
      'confirm_payment': 'تأكيد الدفع',
      'payment_successful': 'تم الدفع بنجاح',

      // Connections
      'connections': 'الاتصالات',
      'requests': 'الطلبات',
      'suggestions': 'المقترحات',
      'add_connection': 'إضافة اتصال',
      'remove_connection': 'إزالة اتصال',
      'accept': 'قبول',
      'reject': 'رفض',
      'connect': 'تواصل',
    };

    // Return the translation if it exists, otherwise return the original string
    return isArabic && translations.containsKey(this.toLowerCase())
        ? translations[this.toLowerCase()]!
        : this;
  }
}