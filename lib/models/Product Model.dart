import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final double price;

  @HiveField(4)
  int quantity;

  @HiveField(5)
  String imageUrl;

  @HiveField(6)
  final String supplierId;

  @HiveField(7)
  final String supplierName;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final Map<String, dynamic>? attributes;

  @HiveField(10)
  final DateTime? createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  @HiveField(12)
  final List<String>? additionalImages;

  @HiveField(13)
  final List<String>? tags;

  @HiveField(14)
  bool isDiscounted;

  @HiveField(15)
  double? discountPercentage;

  @HiveField(16)
  DateTime? discountEndDate;

  @HiveField(17)
  bool isBookmarked;

  @HiveField(18)
  double? rating;

  @HiveField(19)
  int? reviewCount;

  @HiveField(20)
  bool isNew;

  @HiveField(21)
  bool isLowStock;

  @HiveField(22)
  bool isOutOfStock;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.supplierId,
    required this.supplierName,
    this.description,
    this.attributes,
    this.createdAt,
    this.updatedAt,
    this.additionalImages,
    this.tags,
    this.isDiscounted = false,
    this.discountPercentage,
    this.discountEndDate,
    this.isBookmarked = false,
    this.rating,
    this.reviewCount,
    this.isNew = false,
    this.isLowStock = false,
    this.isOutOfStock = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      imageUrl: json['imageUrl'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String,
      description: json['description'] as String?,
      attributes: json['attributes'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      additionalImages: json['additionalImages'] != null ? List<String>.from(json['additionalImages'] as List) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      isDiscounted: json['isDiscounted'] as bool? ?? false,
      discountPercentage: json['discountPercentage'] != null ? (json['discountPercentage'] as num).toDouble() : null,
      discountEndDate: json['discountEndDate'] != null ? DateTime.parse(json['discountEndDate'] as String) : null,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] as int?,
      isNew: json['isNew'] as bool? ?? false,
      isLowStock: json['isLowStock'] as bool? ?? false,
      isOutOfStock: json['isOutOfStock'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'description': description,
      'attributes': attributes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'additionalImages': additionalImages,
      'tags': tags,
      'isDiscounted': isDiscounted,
      'discountPercentage': discountPercentage,
      'discountEndDate': discountEndDate?.toIso8601String(),
      'isBookmarked': isBookmarked,
      'rating': rating,
      'reviewCount': reviewCount,
      'isNew': isNew,
      'isLowStock': isLowStock,
      'isOutOfStock': isOutOfStock,
    };
  }


  // Using getter method only for computed property
  bool get isInStock => quantity > 0;

  // Formatted price methods
  String getFormattedPrice(String currency) {
    if (isDiscounted && discountPercentage != null) {
      final discountedPrice = price * (1 - (discountPercentage! / 100));
      return '$currency${discountedPrice.toStringAsFixed(2)}';
    }
    return '$currency${price.toStringAsFixed(2)}';
  }

  double getDiscountedPrice() {
    if (isDiscounted && discountPercentage != null) {
      return price * (1 - (discountPercentage! / 100));
    }
    return price;
  }

  String getFormattedOriginalPrice(String currency) {
    return '$currency${price.toStringAsFixed(2)}';
  }

  String getDiscountText() {
    if (isDiscounted && discountPercentage != null) {
      return '${discountPercentage!.toStringAsFixed(0)}% OFF';
    }
    return '';
  }

  bool isDiscountActive() {
    if (!isDiscounted || discountEndDate == null) return isDiscounted;

    final now = DateTime.now();
    return isDiscounted && discountEndDate!.isAfter(now);
  }

  String getStockStatus(bool isArabic) {
    if (isOutOfStock) {
      return isArabic ? 'نفذت الكمية' : 'Out of Stock';
    } else if (isLowStock) {
      return isArabic ? 'مخزون منخفض' : 'Low Stock';
    } else {
      return isArabic ? 'متوفر' : 'In Stock';
    }
  }

  String getStockQuantity(bool isArabic) {
    if (isOutOfStock) {
      return isArabic ? 'غير متوفر' : 'Not Available';
    } else {
      return isArabic ? 'متوفر: $quantity' : 'Available: $quantity';
    }
  }
}