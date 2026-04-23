import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_page.dart';
import 'bill_payment.dart';
import 'models/cart_item_model.dart';


class CheckoutPage extends StatefulWidget {
  final double totalAmount;
  final List<CartItemModel> items;
  const CheckoutPage({super.key, required this.totalAmount, required this.items});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedPayment = 'Card';
  final TextEditingController _contactController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249);
    const Color backgroundColor = Color(0xFF000000);
    const Color fieldColor = Color(0xFFE4E4E4); // Light grey container

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Back + Cancel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                          (route) => false,
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Georgia',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
                const SizedBox(height: 32),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgressCircle(isCompleted: true, isActive: false, text: '1', primaryColor: primaryColor),
                    _buildProgressLine(isActive: true, primaryColor: primaryColor),
                    _buildProgressCircle(isCompleted: false, isActive: true, text: '2', primaryColor: primaryColor), // Gold solid
                    _buildProgressLine(isActive: false, primaryColor: primaryColor),
                    _buildProgressCircle(isCompleted: false, isActive: false, text: '3', primaryColor: primaryColor), // Grey solid
                  ],
                ),
                const SizedBox(height: 48),

                // Payment Details Header
                const Center(
                  child: Text(
                    'PAYMENT DETAILS',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Card Number
                _buildLabel('CARD NUMBER'),
                _buildTextField(hint: '1234 **** **** 5678', fieldColor: fieldColor),
                const SizedBox(height: 20),

                // Expiry and CVV
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('EXPIRY'),
                          _buildTextField(hint: 'MM / YY', fieldColor: fieldColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CVV'),
                          _buildTextField(hint: '***', fieldColor: fieldColor),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Cardholder Name
                _buildLabel('CARDHOLDER NAME'),
                _buildTextField(hint: 'Arsath Hasan', fieldColor: fieldColor),
                const SizedBox(height: 32),

                // Payment Methods
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPaymentChip('UPI', _selectedPayment == 'UPI', primaryColor, fieldColor),
                    _buildPaymentChip('Card', _selectedPayment == 'Card', primaryColor, fieldColor),
                _buildPaymentChip('Wallet', _selectedPayment == 'Wallet', primaryColor, fieldColor),
                  ],
                ),
                const SizedBox(height: 32),

                // Delivery Schedule
                // Contact Details
                const Center(
                  child: Text(
                    'CONTACT DETAILS',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildLabel('CONTACT NUMBER'),
                _buildTextField(
                  hint: '+94 77 123 4567', 
                  fieldColor: fieldColor,
                  controller: _contactController,
                ),
                const SizedBox(height: 32),

                // Order Total
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Total',
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Georgia'),
                      ),
                      Text(
                        'Rs. ${widget.totalAmount.toInt()}',
                        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Georgia'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_contactController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your contact number'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final deliveryDateTime = DateTime.now().add(const Duration(days: 3));

                      final amount = widget.totalAmount.toInt();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BillPaymentPage(
                            paymentAmount: amount,
                            items: widget.items,
                            paymentMethod: _selectedPayment,
                            deliveryDate: deliveryDateTime,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pay Rs. ${widget.totalAmount.toInt()} Securely ⟫',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Georgia',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentChip(String label, bool isSelected, Color primaryColor, Color fieldColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPayment = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : fieldColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            fontFamily: 'Georgia',
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, required Color fieldColor, TextEditingController? controller}) {
    return Container(
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: 'Georgia',
          fontSize: 18,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.bold,
            fontFamily: 'Georgia',
            fontSize: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildProgressCircle({required bool isCompleted, required bool isActive, required String text, required Color primaryColor}) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? primaryColor : (isCompleted ? Colors.transparent : const Color(0xFF6B6B6B)),
        border: Border.all(color: isCompleted ? primaryColor : Colors.transparent, width: 2),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(Icons.check, color: primaryColor)
          : Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black, 
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Georgia',
              ),
            ),
    );
  }

  Widget _buildProgressLine({required bool isActive, required Color primaryColor}) {
    return Container(
      width: 60,
      height: 2,
      color: isActive ? primaryColor : const Color(0xFF6B6B6B),
    );
  }
}
