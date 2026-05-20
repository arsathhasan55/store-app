import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/order_model.dart';
import 'models/review_model.dart';
import 'models/product_model.dart';
import 'services/order_service.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/review_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249);
    const Color backgroundColor = Color(0xFF1A1A1A);
    const Color fieldColor = Color(0xFFE4E4E4);

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
          title: const Text('My Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
          centerTitle: true,
        ),
        body: uid.isEmpty
            ? const Center(child: Text("Please Login", style: TextStyle(color: Colors.white)))
            : StreamBuilder<List<OrderModel>>(
                stream: context.read<OrderService>().getUserOrders(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryColor));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No orders found.', style: TextStyle(color: Colors.white, fontSize: 18)));
                  }

                  var orders = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      // Just showing a summary card
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order: #${order.orderId.hashCode.toString().substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, fontFamily: 'Georgia')),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: order.status == 'Processing' ? primaryColor.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.status, 
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900, 
                                      color: order.status == 'Processing' ? primaryColor : Colors.green,
                                      fontSize: 12,
                                      fontFamily: 'Georgia',
                                    )
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            
                            // Items in this order
                            ...order.items.map((item) {
                              return FutureBuilder<ProductModel?>(
                                future: context.read<ProductService>().getProductById(item.productId),
                                builder: (context, prodSnapshot) {
                                  final product = prodSnapshot.data;
                                  String imagePath = product != null && product.images.isNotEmpty ? product.images.first : 'lib/assets/images/home page/bag.png';
                                  bool isNetwork = imagePath.startsWith('http');

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            width: 70,
                                            height: 70,
                                            color: fieldColor,
                                            child: isNetwork ? Image.network(imagePath, fit: BoxFit.cover) : Image.asset(imagePath, fit: BoxFit.cover),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product?.name ?? 'Loading item...',
                                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.black, fontFamily: 'Georgia'),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text('Size: ${item.selectedSize}', style: const TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)),
                                              Text('Rs. ${item.price.toInt()}', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _showAddReviewDialog(context, item.productId, primaryColor, fieldColor),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.black,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(horizontal: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text('Review', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, fontFamily: 'Georgia')),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              );
                            }),
                            
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: ${order.createdAt.toLocal().toString().split(' ')[0]}', style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold)),
                                    Text('Total: Rs. ${order.totalAmount.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black, fontFamily: 'Georgia')),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, String productId, Color primaryColor, Color fieldColor) {
    double userRating = 5.0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Write a Review', style: TextStyle(color: Colors.white, fontFamily: 'Georgia', fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setDialogState(() {
                            userRating = index + 1.0;
                          });
                        },
                        icon: Icon(
                          index < userRating ? Icons.star : Icons.star_border,
                          color: primaryColor,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    style: const TextStyle(color: Colors.black),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      hintStyle: const TextStyle(color: Colors.black54),
                      fillColor: const Color(0xFFE4E4E4),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (reviewController.text.trim().isEmpty) return;
                    
                    final authService = context.read<AuthService>();
                    final reviewService = context.read<ReviewService>();
                    final uid = authService.currentUser?.uid ?? '';
                    
                    if (uid.isNotEmpty) {
                      String userName = 'Anonymous';
                      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
                      if (userDoc.exists) {
                        userName = userDoc.data()?['name'] ?? 'Anonymous';
                      }

                      final review = ReviewModel(
                        reviewId: '',
                        productId: productId,
                        userId: uid,
                        userName: userName,
                        rating: userRating,
                        comment: reviewController.text.trim(),
                        createdAt: DateTime.now(),
                      );
                      
                      await reviewService.addReview(review);
                      if(context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!'), backgroundColor: Colors.green));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Submit', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
