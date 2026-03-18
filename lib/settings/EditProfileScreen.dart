import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'package:trade_hub/providers/AuthProvider.dart';
import 'package:trade_hub/test/unit/AppImageHandler%20Utility%20.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _aboutController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    _usernameController.text = authProvider.username;
    _emailController.text = authProvider.email;
    _phoneController.text = authProvider.phone;
    _locationController.text = authProvider.location;
    _companyNameController.text = authProvider.companyName;
    _businessTypeController.text = authProvider.businessType;
    _aboutController.text = "Experienced business owner specializing in international trade. Focusing on electronics, textile, and sustainable products.";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _companyNameController.dispose();
    _businessTypeController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<UserAuthProvider>(context, listen: false);

        // Update profile using AuthProvider
        await authProvider.updateProfile(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          location: _locationController.text.trim(),
          companyName: _companyNameController.text.trim(),
          businessType: _businessTypeController.text.trim(),
        );

        setState(() => _isLoading = false);

        // Show success message and pop back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isLoading = false);

        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;
    final primaryColor = AppTheme.primaryBlue;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFEEF5FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.arrow_back,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              size: 20.sp,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeProvider.isDarkMode ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeProvider.isDarkMode ? const Color(0xFF1E1E2E) : const Color(0xFFEEF5FF),
              themeProvider.isDarkMode ? const Color(0xFF12121C) : const Color(0xFFDAE9FA),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture section
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 120.w,
                              height: 120.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: primaryColor, width: 3.w),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(60.r),
                                child: Consumer<UserAuthProvider>(
                                  builder: (context, authProvider, _) {
                                    return AppImageHandler.loadProfileImage(
                                      imageUrl: authProvider.profileImage.isNotEmpty
                                          ? authProvider.profileImage
                                          : 'https://via.placeholder.com/150',
                                      size: 120.w,
                                      placeholderIcon: Icons.person,
                                      useShimmerLoading: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Implement profile picture update
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(isArabic
                                          ? 'ستتم إضافة هذه الميزة قريباً'
                                          : 'This feature will be added soon'),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          isArabic ? 'تغيير صورة الملف الشخصي' : 'Change Profile Picture',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Section title
                  _buildSectionTitle(
                    isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                    themeProvider,
                  ),
                  SizedBox(height: 16.h),

                  // Username field
                  _buildGlassmorphicTextField(
                    controller: _usernameController,
                    labelText: isArabic ? 'الاسم' : 'Full Name',
                    icon: Icons.person_outline,
                    themeProvider: themeProvider,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isArabic ? 'الرجاء إدخال الاسم' : 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Email field
                  _buildGlassmorphicTextField(
                    controller: _emailController,
                    labelText: isArabic ? 'البريد الإلكتروني' : 'Email',
                    icon: Icons.email_outlined,
                    themeProvider: themeProvider,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isArabic ? 'الرجاء إدخال البريد الإلكتروني' : 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return isArabic ? 'الرجاء إدخال بريد إلكتروني صحيح' : 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Phone field
                  _buildGlassmorphicTextField(
                    controller: _phoneController,
                    labelText: isArabic ? 'رقم الهاتف' : 'Phone Number',
                    icon: Icons.phone_outlined,
                    themeProvider: themeProvider,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16.h),

                  // Location field
                  _buildGlassmorphicTextField(
                    controller: _locationController,
                    labelText: isArabic ? 'الموقع' : 'Location',
                    icon: Icons.location_on_outlined,
                    themeProvider: themeProvider,
                  ),
                  SizedBox(height: 32.h),

                  // Business section title
                  _buildSectionTitle(
                    isArabic ? 'معلومات الشركة' : 'Business Information',
                    themeProvider,
                  ),
                  SizedBox(height: 16.h),

                  // Company name field
                  _buildGlassmorphicTextField(
                    controller: _companyNameController,
                    labelText: isArabic ? 'اسم الشركة' : 'Company Name',
                    icon: Icons.business_outlined,
                    themeProvider: themeProvider,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isArabic ? 'الرجاء إدخال اسم الشركة' : 'Please enter company name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),

                  // Business type field
                  _buildGlassmorphicTextField(
                    controller: _businessTypeController,
                    labelText: isArabic ? 'نوع النشاط التجاري' : 'Business Type',
                    icon: Icons.category_outlined,
                    themeProvider: themeProvider,
                  ),
                  SizedBox(height: 16.h),

                  // About field
                  _buildGlassmorphicTextField(
                    controller: _aboutController,
                    labelText: isArabic ? 'نبذة عني' : 'About Me',
                    icon: Icons.info_outline,
                    themeProvider: themeProvider,
                    maxLines: 4,
                  ),
                  SizedBox(height: 40.h),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        isArabic ? 'حفظ التغييرات' : 'Save Changes',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeProvider themeProvider) {
    return Row(
      children: [
        Container(
          height: 20.h,
          width: 4.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : AppTheme.primaryBlue,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphicTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required ThemeProvider themeProvider,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final primaryColor = AppTheme.primaryBlue;

    return ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: themeProvider.isDarkMode
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: TextStyle(
              fontSize: 16.sp,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: labelText,
              prefixIcon: Icon(icon, color: primaryColor),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
              labelStyle: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}