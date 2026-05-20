import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'widgets/custom_button.dart';
import 'home_page.dart';
import 'checkout.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'models/cart_item_model.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String uid = context.read<AuthService>().currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: uid.isEmpty
          ? const Center(child: Text("Please login to see your cart"))
          : StreamBuilder<List<CartItemModel>>(
              stream: context.read<CartService>().getUserCart(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return _buildEmptyCart(context);
                }

                double subtotal = items.fold(0, (sum, i) => sum + (i.price * i.quantity));

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: items.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 20),
                        itemBuilder: (context, index) => _buildCartItem(context, items[index], uid),
                      ),
                    ),
                    _buildSummary(context, subtotal, items),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.white24),
          const SizedBox(height: 24),
          Text('Your cart is empty', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('Looks like you haven\'t added anything yet.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: CustomButton(
              label: 'Start Shopping',
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item, String uid) {
    final String imagePath = item.product?.images.isNotEmpty == true ? item.product!.images.first : 'lib/assets/images/home page/bag.png';
    final bool isNetwork = imagePath.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 100,
              height: 100,
              child: isNetwork ? Image.network(imagePath, fit: BoxFit.cover) : Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Product',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text('Size: ${item.selectedSize}', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${item.price.toInt()}',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    _buildQuantityPicker(context, item, uid),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityPicker(BuildContext context, CartItemModel item, String uid) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 16),
            onPressed: () => context.read<CartService>().updateCartItemQuantity(uid, item.itemId, item.quantity - 1),
          ),
          Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: () => context.read<CartService>().updateCartItemQuantity(uid, item.itemId, item.quantity + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, double subtotal, List<CartItemModel> items) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('Rs. ${subtotal.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping'),
              Text('Free', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleLarge),
              Text(
                'Rs. ${subtotal.toInt()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Checkout',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CheckoutPage(totalAmount: subtotal, items: items))),
          ),
        ],
      ),
    );
  }
}
