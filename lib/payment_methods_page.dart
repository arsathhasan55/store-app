import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/user_service.dart';
import 'services/auth_service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _holderController = TextEditingController();

  void _showAddPaymentDialog() {
    _cardNumberController.clear();
    _expiryController.clear();
    _holderController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Add Payment Method', style: TextStyle(color: Colors.white, fontFamily: 'Georgia')),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_cardNumberController, 'Card Number', keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_expiryController, 'MM/YY'),
              const SizedBox(height: 12),
              _buildTextField(_holderController, 'Cardholder Name'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: _savePayment,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC9A249)),
            child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        fillColor: const Color(0xFFE4E4E4),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => value!.isEmpty ? 'Required' : null,
    );
  }

  void _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final uid = context.read<AuthService>().currentUser?.uid ?? '';
      final paymentData = {
        'cardNumber': _cardNumberController.text.trim().replaceAll(RegExp(r'\d(?=\d{4})'), '*'),
        'expiry': _expiryController.text.trim(),
        'holder': _holderController.text.trim(),
        'type': 'Visa', // default for demo
      };

      await context.read<UserService>().addPaymentMethod(uid, paymentData);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249);
    const Color backgroundColor = Color(0xFF131313);
    String uid = context.read<AuthService>().currentUser?.uid ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Payment Methods', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: context.read<UserService>().getPaymentMethods(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: primaryColor));
            }
            final methods = snapshot.data ?? [];
            if (methods.isEmpty) {
              return const Center(child: Text('No payment methods saved.', style: TextStyle(color: Colors.white70)));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final card = methods[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, color: primaryColor, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card['cardNumber'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
                            Text(card['holder'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => context.read<UserService>().deletePaymentMethod(uid, card['id']),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: _showAddPaymentDialog,
          child: const Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}
