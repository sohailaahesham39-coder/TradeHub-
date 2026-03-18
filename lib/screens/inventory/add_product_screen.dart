import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/models/Product%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _tagsController;
  late String _selectedCategory;
  late bool _isDiscounted;
  late double _discountPercentage;
  DateTime? _discountEndDate;
  late bool _isNew;
  File? _mainImageFile;
  List<File> _additionalImageFiles = [];
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Electronics',
    'Furniture',
    'Food & Beverages',
    'Clothing',
    'Health & Beauty',
    'Office Supplies',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '');
    _tagsController = TextEditingController(text: widget.product?.tags?.join(', ') ?? '');
    _selectedCategory = widget.product?.category ?? 'Electronics';
    _isDiscounted = widget.product?.isDiscounted ?? false;
    _discountPercentage = widget.product?.discountPercentage ?? 0.0;
    _discountEndDate = widget.product?.discountEndDate;
    _isNew = widget.product?.isNew ?? false;
    _mainImageFile = widget.product?.imageUrl != null && widget.product!.imageUrl.startsWith('file://') ? File(widget.product!.imageUrl.replaceFirst('file://', '')) : null;
    _additionalImageFiles = widget.product?.additionalImages
        ?.where((url) => url.startsWith('file://'))
        .map((url) => File(url.replaceFirst('file://', '')))
        .toList() ??
        [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMainImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAdditionalImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _additionalImageFiles.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  Future<void> _selectDiscountEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _discountEndDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _discountEndDate = picked);
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile, String productId, String imageType, [int? index]) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('products/$productId/${imageType}${index != null ? '_$index' : ''}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await imageRef.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationProvider>(context, listen: false).isArabic
                  ? 'يرجى تسجيل الدخول لإضافة منتج'
                  : 'Please log in to add a product',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final productId = widget.product?.id ?? const Uuid().v4();
      String? mainImageUrl = widget.product?.imageUrl;
      List<String> additionalImageUrls = widget.product?.additionalImages ?? [];

      // Upload main image if changed
      if (_mainImageFile != null) {
        mainImageUrl = await _uploadImageToFirebase(_mainImageFile!, productId, 'main');
        if (mainImageUrl == null) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Provider.of<LocalizationProvider>(context, listen: false).isArabic
                    ? 'فشل في رفع الصورة الرئيسية'
                    : 'Failed to upload main image',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      // Upload additional images
      additionalImageUrls = [];
      for (int i = 0; i < _additionalImageFiles.length; i++) {
        final url = await _uploadImageToFirebase(_additionalImageFiles[i], productId, 'additional', i);
        if (url != null) {
          additionalImageUrls.add(url);
        }
      }

      // Create or update product
      final product = Product(
        id: productId,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text.trim()),
        quantity: int.parse(_quantityController.text.trim()),
        imageUrl: mainImageUrl ?? '',
        supplierId: authProvider.email.isNotEmpty ? authProvider.email : 'default_supplier_id',
        supplierName: authProvider.companyName.isNotEmpty ? authProvider.companyName : authProvider.username,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        additionalImages: additionalImageUrls,
        tags: _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        isDiscounted: _isDiscounted,
        discountPercentage: _isDiscounted ? _discountPercentage : null,
        discountEndDate: _isDiscounted ? _discountEndDate : null,
        isNew: _isNew,
        createdAt: widget.product?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isBookmarked: widget.product?.isBookmarked ?? false,
        rating: widget.product?.rating,
        reviewCount: widget.product?.reviewCount,
        attributes: widget.product?.attributes,
        isLowStock: widget.product?.isLowStock ?? false,
        isOutOfStock: widget.product?.isOutOfStock ?? false,
      );

      // Save to Firestore
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('products').doc(productId).set({
          'id': product.id,
          'name': product.name,
          'category': product.category,
          'price': product.price,
          'quantity': product.quantity,
          'imageUrl': product.imageUrl,
          'supplierId': product.supplierId,
          'supplierName': product.supplierName,
          'description': product.description,
          'additionalImages': product.additionalImages,
          'tags': product.tags,
          'isDiscounted': product.isDiscounted,
          'discountPercentage': product.discountPercentage,
          'discountEndDate': product.discountEndDate?.toIso8601String(),
          'isNew': product.isNew,
          'createdAt': product.createdAt!.toIso8601String(),
          'updatedAt': product.updatedAt!.toIso8601String(),
          'isBookmarked': product.isBookmarked,
          'rating': product.rating,
          'reviewCount': product.reviewCount,
          'attributes': product.attributes,
          'isLowStock': product.isLowStock,
          'isOutOfStock': product.isOutOfStock,
        });

        // Optionally save to Hive for local caching
        final box = Hive.box<Product>('products');
        await box.put(product.id, product);

        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationProvider>(context, listen: false).isArabic
                  ? widget.product == null
                  ? 'تمت إضافة المنتج بنجاح'
                  : 'تم تحديث المنتج بنجاح'
                  : widget.product == null
                  ? 'Product added successfully'
                  : 'Product updated successfully',
            ),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, product);
      } catch (e) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationProvider>(context, listen: false).isArabic
                  ? 'فشل في حفظ المنتج: $e'
                  : 'Failed to save product: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.product != null) {
      setState(() => _isSubmitting = true);
      try {
        // Delete from Firestore
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('products').doc(widget.product!.id).delete();

        // Delete images from Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('products/${widget.product!.id}');
        await storageRef.listAll().then((result) async {
          for (var item in result.items) {
            await item.delete();
          }
        });

        // Delete from Hive
        final box = Hive.box<Product>('products');
        await box.delete(widget.product!.id);

        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationProvider>(context, listen: false).isArabic
                  ? 'تم حذف المنتج بنجاح'
                  : 'Product deleted successfully',
            ),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, null);
      } catch (e) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LocalizationProvider>(context, listen: false).isArabic
                  ? 'فشل في حذف المنتج: $e'
                  : 'Failed to delete product: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic
              ? widget.product == null
              ? 'إضافة منتج جديد'
              : 'تعديل المنتج'
              : widget.product == null
              ? 'Add New Product'
              : 'Edit Product',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: Icon(Icons.delete, size: 24.sp, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(isArabic ? 'تأكيد الحذف' : 'Confirm Delete'),
                    content: Text(isArabic ? 'هل أنت متأكد من حذف هذا المنتج؟' : 'Are you sure you want to delete this product?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(isArabic ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _deleteProduct();
                }
              },
            ),
        ],
      ),
      body: _isSubmitting
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryBlue),
            SizedBox(height: 16.h),
            Text(
              isArabic ? 'جارِ معالجة المنتج...' : 'Processing product...',
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context, isArabic),
              SizedBox(height: 24.h),
              _buildBasicInfo(context, isArabic),
              SizedBox(height: 24.h),
              _buildDetailsSection(context, isArabic),
              SizedBox(height: 24.h),
              _buildSubmitButton(context, isArabic),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'صور المنتج' : 'Product Images',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            width: 180.w,
            height: 180.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade300),
              image: _mainImageFile != null
                  ? DecorationImage(image: FileImage(_mainImageFile!), fit: BoxFit.cover)
                  : widget.product?.imageUrl != null
                  ? DecorationImage(image: NetworkImage(widget.product!.imageUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: _mainImageFile == null && widget.product?.imageUrl == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, size: 48.sp, color: AppTheme.primaryBlue),
                SizedBox(height: 8.h),
                Text(
                  isArabic ? 'اضغط لإضافة الصورة الرئيسية' : 'Tap to add main image',
                  style: TextStyle(fontSize: 14.sp, color: AppTheme.primaryBlue),
                  textAlign: TextAlign.center,
                ),
              ],
            )
                : null,
          ),
        ),
        SizedBox(height: 16.h),
        ElevatedButton(
          onPressed: _pickAdditionalImages,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: AppTheme.white,
            padding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          child: Text(isArabic ? 'إضافة صور إضافية' : 'Add Additional Images'),
        ),
        if (_additionalImageFiles.isNotEmpty || (widget.product?.additionalImages?.isNotEmpty ?? false))
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _additionalImageFiles.length + (widget.product?.additionalImages?.length ?? 0),
              itemBuilder: (context, index) {
                if (index < _additionalImageFiles.length) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Stack(
                      children: [
                        Image.file(_additionalImageFiles[index], width: 80.w, height: 80.h, fit: BoxFit.cover),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => setState(() => _additionalImageFiles.removeAt(index)),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  final additionalImageIndex = index - _additionalImageFiles.length;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Image.network(
                      widget.product!.additionalImages![additionalImageIndex],
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'معلومات أساسية' : 'Basic Information',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: isArabic ? 'اسم المنتج *' : 'Product Name *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          validator: (value) => value == null || value.isEmpty
              ? (isArabic ? 'يرجى إدخال اسم المنتج' : 'Please enter product name')
              : null,
        ),
        SizedBox(height: 16.h),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            labelText: isArabic ? 'الفئة *' : 'Category *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          items: _categories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(),
          onChanged: (value) => setState(() => _selectedCategory = value!),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isArabic ? 'السعر *' : 'Price *',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return isArabic ? 'يرجى إدخال السعر' : 'Please enter price';
                  if (double.tryParse(value) == null) return isArabic ? 'أدخل سعرًا صالحًا' : 'Enter a valid price';
                  return null;
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isArabic ? 'الكمية *' : 'Quantity *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return isArabic ? 'يرجى إدخال الكمية' : 'Please enter quantity';
                  if (int.tryParse(value) == null) return isArabic ? 'أدخل رقمًا صحيحًا' : 'Enter a whole number';
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'التفاصيل والخيارات' : 'Details & Options',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: isArabic ? 'وصف المنتج' : 'Product Description',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            labelText: isArabic ? 'العلامات (مفصولة بفواصل)' : 'Tags (comma-separated)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
        SizedBox(height: 16.h),
        SwitchListTile(
          title: Text(isArabic ? 'منتج جديد' : 'New Product', style: TextStyle(fontSize: 16.sp)),
          subtitle: Text(
            isArabic ? 'ضع علامة على هذا المنتج كمنتج جديد' : 'Mark this product as new',
            style: TextStyle(fontSize: 12.sp),
          ),
          value: _isNew,
          activeColor: AppTheme.primaryBlue,
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
          onChanged: (value) => setState(() => _isNew = value),
        ),
        Divider(height: 1.h),
        SwitchListTile(
          title: Text(isArabic ? 'تخفيض السعر' : 'Discount', style: TextStyle(fontSize: 16.sp)),
          subtitle: Text(
            isArabic ? 'تطبيق خصم على هذا المنتج' : 'Apply a discount to this product',
            style: TextStyle(fontSize: 12.sp),
          ),
          value: _isDiscounted,
          activeColor: AppTheme.primaryBlue,
          contentPadding: EdgeInsets.symmetric(horizontal: 0),
          onChanged: (value) => setState(() => _isDiscounted = value),
        ),
        if (_isDiscounted) ...[
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_discountPercentage.toStringAsFixed(0)}% ${isArabic ? 'خصم' : 'Discount'}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                SizedBox(height: 8.h),
                Slider(
                  value: _discountPercentage,
                  min: 0,
                  max: 90,
                  divisions: 18,
                  label: '${_discountPercentage.toStringAsFixed(0)}%',
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (value) => setState(() => _discountPercentage = value),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  _discountEndDate != null
                      ? '${isArabic ? 'تاريخ انتهاء الخصم:' : 'Discount End Date:'} ${_discountEndDate!.day}/${_discountEndDate!.month}/${_discountEndDate!.year}'
                      : isArabic
                      ? 'اختر تاريخ انتهاء الخصم'
                      : 'Select Discount End Date',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              TextButton(
                onPressed: () => _selectDiscountEndDate(context),
                child: Text(isArabic ? 'اختيار' : 'Pick', style: TextStyle(color: AppTheme.primaryBlue)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isArabic) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text(
          isArabic
              ? widget.product == null
              ? 'إضافة المنتج'
              : 'تحديث المنتج'
              : widget.product == null
              ? 'Add Product'
              : 'Update Product',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}