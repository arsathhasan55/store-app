import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/review_model.dart';
import 'models/product_model.dart';
import 'services/review_service.dart';
import 'services/product_service.dart';
import 'services/auth_service.dart';
import 'product_details_page.dart';

class UserReviewsPage extends StatelessWidget {
  const UserReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249);
    const Color backgroundColor = Color(0xFF131313);
    const Color cardColor = Color(0xFFE4E4E4);

    final uid = context.read<AuthService>().currentUser?.uid ?? '';

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
          title: const Text(
            'My Reviews',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
          ),
          centerTitle: true,
        ),
        body: uid.isEmpty
            ? const Center(child: Text("Please Login", style: TextStyle(color: Colors.white)))
            : StreamBuilder<List<ReviewModel>>(
                stream: context.read<ReviewService>().getUserReviews(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: primaryColor));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review_outlined, color: Colors.white24, size: 50),
                          SizedBox(height: 12),
                          Text('No reviews yet.', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  final reviews = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return _ReviewCard(review: review, cardColor: cardColor, primaryColor: primaryColor);
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final Color cardColor;
  final Color primaryColor;

  const _ReviewCard({
    required this.review,
    required this.cardColor,
    required this.primaryColor,
  });

  String _resolveImagePath(String? path) {
    if (path == null || path.isEmpty) return 'lib/assets/images/home page/bag.png';
    if (path.startsWith('http')) return path;
    if (path.startsWith('lib/assets')) return path;
    if (path.startsWith('assets/')) return 'lib/$path';
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: context.read<ProductService>().getProductById(review.productId),
      builder: (context, snapshot) {
        final product = snapshot.data;
        String imagePath = _resolveImagePath(product?.images.isNotEmpty == true ? product!.images.first : null);
        bool isNetwork = imagePath.startsWith('http');
        
        return GestureDetector(
          onTap: product != null 
              ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product)))
              : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryColor, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: cardColor,
                        child: isNetwork 
                          ? Image.network(imagePath, fit: BoxFit.cover) 
                          : Image.asset(imagePath, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Product Name and Rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product?.name ?? 'Loading product...',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black, fontFamily: 'Georgia'),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < review.rating ? Icons.star : Icons.star_border,
                                color: primaryColor,
                                size: 18,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                            style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    // Delete Icon
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1A1A),
                            title: const Text('Delete Review', style: TextStyle(color: Colors.white, fontFamily: 'Georgia')),
                            content: const Text('Are you sure you want to delete this review?', style: TextStyle(color: Colors.white70)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await context.read<ReviewService>().deleteReview(review.reviewId);
                                  if(context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review deleted')));
                                  }
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 24),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Review Text
                Text(
                  review.comment,
                  style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500, fontFamily: 'Georgia'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
