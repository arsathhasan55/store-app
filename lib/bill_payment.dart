import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'models/cart_item_model.dart';
import 'models/order_model.dart';
import 'services/order_service.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';

class BillPaymentPage extends StatefulWidget {
  final int paymentAmount;
  final List<CartItemModel> items;
  final String paymentMethod;
  final DateTime deliveryDate;

  const BillPaymentPage({
    super.key,
    required this.paymentAmount,
    required this.items,
    required this.paymentMethod,
    required this.deliveryDate,
  });

  @override
  State<BillPaymentPage> createState() => _BillPaymentPageState();
}

class _BillPaymentPageState extends State<BillPaymentPage> {
  final String refNumber = '#${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processOrder();
    });
  }

  Future<void> _processOrder() async {
    String uid = context.read<AuthService>().currentUser?.uid ?? '';
    if (uid.isNotEmpty && widget.items.isNotEmpty) {
       try {
         OrderModel order = OrderModel(
            orderId: '',
            userId: uid,
            items: widget.items,
            totalAmount: widget.paymentAmount.toDouble(),
            status: 'Processing',
            createdAt: DateTime.now(),
            deliveryDate: widget.deliveryDate,
            isDelivered: false,
         );
         await context.read<OrderService>().createOrder(order);
         if (!mounted) return;
         await context.read<CartService>().clearCart(uid);
       } catch (e) {
         // ignore
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                const SizedBox(height: 32),

                // Main Receipt Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2196F3), // Bright bright blue from mockup
                      width: 4,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Pay Image
                      Image.asset(
                        'lib/assets/images/bill_payment/pay.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.check_circle_outline, color: Colors.green, size: 80);
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      const Text(
                        'Payment Success!',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Georgia',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Rs. ${widget.paymentAmount}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Georgia',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 1),
                      const SizedBox(height: 16),

                      // Details
                      _buildDetailRow('Ref Number', refNumber),
                      const SizedBox(height: 16),
                      _buildDetailRow('Date', currentDate),
                      const SizedBox(height: 16),
                      _buildDetailRow('Payment', widget.paymentMethod),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Delivery', 
                        "${widget.deliveryDate.day}/${widget.deliveryDate.month}/${widget.deliveryDate.year} ${widget.deliveryDate.hour.toString().padLeft(2, '0')}:${widget.deliveryDate.minute.toString().padLeft(2, '0')}"
                      ),
                      const SizedBox(height: 32),

                      // Continue Shopping Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF202020), // Dark grey almost black
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continue Shopping',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Georgia',
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Download Receipt
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment Successful'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text(
                          'Download Receipt',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Georgia',
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black, 
                            decorationThickness: 1.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'Georgia',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'Georgia',
          ),
        ),
      ],
    );
  }
}
