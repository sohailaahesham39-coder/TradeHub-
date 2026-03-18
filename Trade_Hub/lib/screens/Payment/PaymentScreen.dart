import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:trade_hub/models/Event%20Model.dart';
import 'package:trade_hub/providers/AppTheme.dart';
import 'package:trade_hub/providers/Localization%20Provider.dart';
import 'package:trade_hub/providers/Theme%20Provider.dart';
import 'dart:async';

class PaymentScreen extends StatefulWidget {
  final Event event;
  final int ticketQuantity;
  final double totalCost;
  final String ticketType;

  const PaymentScreen({
    Key? key,
    required this.event,
    required this.ticketQuantity,
    required this.totalCost,
    required this.ticketType,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  String _selectedPaymentMethod = 'Credit Card';
  bool _savePaymentInfo = false;
  bool _isProcessing = false;
  bool _paymentSuccess = false;
  late TabController _tabController;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'credit_card', 'name': 'Credit Card', 'icon': Icons.credit_card},
    {'id': 'paypal', 'name': 'PayPal', 'icon': Icons.payment},
    {'id': 'apple_pay', 'name': 'Apple Pay', 'icon': Icons.apple},
    {'id': 'google_pay', 'name': 'Google Pay', 'icon': Icons.g_mobiledata},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _paymentMethods.length, vsync: this);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderNameController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String input) {
    String digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 16) digitsOnly = digitsOnly.substring(0, 16);
    final buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      buffer.write(digitsOnly[i]);
      if ((i + 1) % 4 == 0 && i != digitsOnly.length - 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);
      Timer(const Duration(seconds: 2), () {
        setState(() {
          _isProcessing = false;
          _paymentSuccess = true;
        });
        Timer(const Duration(seconds: 2), () {
          Navigator.pop(context, true);
        });
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      _processPayment();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final isArabic = localizationProvider.isArabic;
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: _isProcessing
          ? _buildProcessingPayment(isArabic)
          : _paymentSuccess
          ? _buildPaymentSuccess(isArabic)
          : SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, isArabic),
            _buildStepper(isArabic),
            Expanded(
              child: _currentStep == 0
                  ? _buildOrderReview(context, isArabic, isDarkMode)
                  : _buildPaymentForm(context, isArabic, isDarkMode),
            ),
            _buildBottomBar(context, isArabic, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isArabic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            isArabic ? 'الدفع والتأكيد' : 'Checkout',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 48.w),
        ],
      ),
    );
  }

  Widget _buildStepper(bool isArabic) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Row(
        children: [
          _buildStepCircle(0, isArabic ? 'التفاصيل' : 'Review', _currentStep >= 0),
          Expanded(
            child: Container(
              height: 2.h,
              color: _currentStep >= 1 ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          _buildStepCircle(1, isArabic ? 'الدفع' : 'Payment', _currentStep >= 1),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? Icon(
              step < _currentStep ? Icons.check : Icons.circle,
              color: Colors.white,
              size: 16.sp,
            )
                : Text(
              '${step + 1}',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isActive ? AppTheme.primaryColor : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderReview(BuildContext context, bool isArabic, bool isDarkMode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventCard(context, isArabic, isDarkMode),
          SizedBox(height: 24.h),
          _buildOrderSummary(context, isArabic, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, bool isArabic, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
              ),
              image: DecorationImage(image: NetworkImage(widget.event.imageUrl), fit: BoxFit.cover),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16.h,
                  left: 16.w,
                  right: 16.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.white, size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            widget.event.getFormattedDate(), // Updated to use getter
                            style: TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18.sp, color: AppTheme.primaryColor),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        widget.event.location,
                        style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodySmall?.color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 18.sp, color: AppTheme.primaryColor),
                    SizedBox(width: 4.w),
                    Text(
                      widget.event.getFormattedTime(), // Updated to use getter
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, bool isArabic, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, 2.h)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'ملخص الطلب' : 'Order Summary',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20.h),
          _buildOrderItem(
            context,
            isArabic ? 'نوع التذكرة' : 'Ticket Type',
            widget.ticketType == 'standard'
                ? (isArabic ? 'عادي' : 'Standard')
                : widget.ticketType == 'vip'
                ? (isArabic ? 'كبار الشخصيات' : 'VIP')
                : (isArabic ? 'مجموعة' : 'Group'),
            isDarkMode,
          ),
          _buildOrderItem(
            context,
            isArabic ? 'عدد التذاكر' : 'Number of Tickets',
            '${widget.ticketQuantity}',
            isDarkMode,
          ),
          _buildOrderItem(
            context,
            isArabic ? 'سعر التذكرة' : 'Price per Ticket',
            widget.event.getFormattedPrice(isArabic ? 'د.إ' : '\$'), // Updated to use ticketPrice
            isDarkMode,
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isArabic ? 'المجموع' : 'Total',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                '${isArabic ? 'د.إ' : '\$'}${widget.totalCost.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, String label, String value, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h), // Note: 'bottom' is likely intended; left as-is from your snippet
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(BuildContext context, bool isArabic, bool isDarkMode) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPaymentMethodSelector(context, isArabic, isDarkMode),
            SizedBox(height: 24.h),
            _buildCardDetailsForm(context, isArabic, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector(BuildContext context, bool isArabic, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'طريقة الدفع' : 'Payment Method',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, 2.h)),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
              tabs: _paymentMethods.map((method) {
                return Tab(
                  height: 70.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(method['icon'] as IconData),
                      SizedBox(height: 4.h),
                      Text(
                        method['name'] as String,
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onTap: (index) => setState(() => _selectedPaymentMethod = _paymentMethods[index]['name'] as String),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetailsForm(BuildContext context, bool isArabic, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'تفاصيل البطاقة' : 'Card Details',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, 2.h)),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 200.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, const Color(0xFF8A64EB)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20.h,
                      right: 20.w,
                      child: Icon(Icons.credit_card, color: Colors.white.withOpacity(0.7), size: 30.sp),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 100.h,
                        width: 150.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100.r),
                            bottomRight: Radius.circular(16.r),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            _cardNumberController.text.isEmpty
                                ? 'XXXX XXXX XXXX XXXX'
                                : _formatCardNumber(_cardNumberController.text),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'اسم حامل البطاقة' : 'CARD HOLDER',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _cardHolderNameController.text.isEmpty
                                        ? 'FULL NAME'
                                        : _cardHolderNameController.text.toUpperCase(),
                                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'تنتهي في' : 'EXPIRES',
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _expiryDateController.text.isEmpty ? 'MM/YY' : _expiryDateController.text,
                                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _cardHolderNameController,
                decoration: InputDecoration(
                  labelText: isArabic ? 'اسم حامل البطاقة' : 'Card Holder Name',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                ),
                onChanged: (value) => setState(() {}),
                validator: (value) =>
                value == null || value.isEmpty ? (isArabic ? 'يرجى إدخال اسم حامل البطاقة' : 'Please enter the card holder name') : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isArabic ? 'رقم البطاقة' : 'Card Number',
                  prefixIcon: Icon(Icons.credit_card, color: AppTheme.primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                ),
                onChanged: (value) => setState(() {}),
                validator: (value) =>
                value == null || value.isEmpty ? (isArabic ? 'يرجى إدخال رقم البطاقة' : 'Please enter the card number') : null,
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryDateController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'تاريخ الانتهاء' : 'Expiry Date',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                      onChanged: (value) => setState(() {}),
                      validator: (value) =>
                      value == null || value.isEmpty ? (isArabic ? 'يرجى إدخال تاريخ الانتهاء' : 'Please enter expiry date') : null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: 'XXX',
                        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                        ),
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
                      ),
                      validator: (value) =>
                      value == null || value.isEmpty ? (isArabic ? 'يرجى إدخال رمز الأمان' : 'Please enter CVV') : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: _savePaymentInfo,
                      onChanged: (value) => setState(() => _savePaymentInfo = value!),
                      activeColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isArabic ? 'حفظ معلومات الدفع للاستخدام المستقبلي' : 'Save payment info for future use',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, bool isArabic, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r, offset: Offset(0, -2.h)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: _goToPreviousStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              ),
              child: Text(
                isArabic ? 'السابق' : 'Previous',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            )
          else
            SizedBox(width: 80.w),
          ElevatedButton(
            onPressed: _goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            ),
            child: Text(
              _currentStep == 0 ? (isArabic ? 'التالي' : 'Next') : (isArabic ? 'ادفع الآن' : 'Pay Now'),
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingPayment(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            strokeWidth: 4.w,
          ),
          SizedBox(height: 24.h),
          Text(
            isArabic ? 'جاري معالجة الدفع...' : 'Processing Payment...',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSuccess(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.primaryColor,
            size: 80.sp,
          ),
          SizedBox(height: 24.h),
          Text(
            isArabic ? 'تم الدفع بنجاح!' : 'Payment Successful!',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          Text(
            isArabic ? 'سيتم إعادة توجيهك قريبًا...' : 'You will be redirected shortly...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}