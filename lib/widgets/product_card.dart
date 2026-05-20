import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../product_details_page.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final String imagePath = product.images.isNotEmpty ? product.images.first : 'lib/assets/images/home page/bag.png';
    final bool isNetworkImage = imagePath.startsWith('http');
    final String uid = context.read<AuthService>().currentUser?.uid ?? '';

    return GestureDetector(
      onTap: () {
        context.read<ProductService>().incrementProductViews(product.productId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: 'product_${product.productId}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: isNetworkImage
                          ? Image.network(imagePath, fit: BoxFit.cover, width: double.infinity)
                          : Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image, size: 40)),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: StreamBuilder<List<ProductModel>>(
                      stream: context.read<UserService>().getUserWishlist(uid),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data?.any((p) => p.productId == product.productId) ?? false;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? AppTheme.primaryColor : Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              if (uid.isNotEmpty) {
                                if (isSaved) {
                                  context.read<UserService>().removeFromWishlist(uid, product.productId);
                                } else {
                                  context.read<UserService>().addToWishlist(uid, product.productId);
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${product.price.toInt()}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
