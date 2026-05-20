import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'widgets/custom_button.dart';
import 'cart.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/cart_service.dart';
import 'services/review_service.dart';
import 'models/product_model.dart';
import 'models/cart_item_model.dart';
import 'models/review_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String _selectedSize = 'M';
  bool _isAddingToCart = false;

  String _resolveImagePath(String? path) {
    if (path == null || path.isEmpty) return 'lib/assets/images/women category/top/34.jpg';
    if (path.startsWith('http')) return path;
    if (path.startsWith('lib/assets')) return path;
    if (path.startsWith('assets/')) return 'lib/$path';
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Image Header
          SliverAppBar(
            expandedHeight: 450,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${widget.product.productId}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    (() {
                      String path = _resolveImagePath(widget.product.images.isNotEmpty ? widget.product.images.first : null);
                      return path.startsWith('http')
                          ? Image.network(path, fit: BoxFit.cover)
                          : Image.asset(path, fit: BoxFit.cover);
                    })(),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black26, Colors.transparent, Colors.black45],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            _buildRatingBar(),
                          ],
                        ),
                      ),
                      Text(
                        'Rs. ${widget.product.price.toInt()}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  // Description
                  Text('Description', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.description.isNotEmpty ? widget.product.description : 'Product description not available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),

                  const SizedBox(height: 32),

                  // Size Selection
                  Text('Select Size', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildSizeSelection(),

                  const SizedBox(height: 40),

                  // Reviews
                  _buildReviewsSection(),
                  
                  const SizedBox(height: 120), // Padding for sticky buttons
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomActions(),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        ...List.generate(4, (i) => const Icon(Icons.star_rounded, color: AppTheme.primaryColor, size: 18)),
        const Icon(Icons.star_half_rounded, color: AppTheme.primaryColor, size: 18),
        const SizedBox(width: 8),
        Text('(128 Reviews)', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSizeSelection() {
    final sizes = widget.product.size.isNotEmpty ? widget.product.size : ['S', 'M', 'L', 'XL'];
    return Wrap(
      spacing: 12,
      children: sizes.map((size) {
        final isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () => setState(() => _selectedSize = size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.white10,
              ),
            ),
            child: Text(
              size,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Product Reviews', style: Theme.of(context).textTheme.titleLarge),
            TextButton(onPressed: () {}, child: const Text('See All')),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ReviewModel>>(
          stream: context.read<ReviewService>().getProductReviews(widget.product.productId),
          builder: (context, snapshot) {
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Text('No reviews yet. Be the first to share your thoughts!');
            }
            return Column(
              children: reviews.take(2).map((r) => _buildReviewCard(r)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: AppTheme.primaryColor, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    final String uid = context.read<AuthService>().currentUser?.uid ?? '';
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Row(
        children: [
          StreamBuilder<List<ProductModel>>(
            stream: context.read<UserService>().getUserWishlist(uid),
            builder: (context, snapshot) {
              final isSaved = snapshot.data?.any((p) => p.productId == widget.product.productId) ?? false;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? AppTheme.primaryColor : Colors.white70),
                  onPressed: () {
                    if (uid.isNotEmpty) {
                      if (isSaved) {
                        context.read<UserService>().removeFromWishlist(uid, widget.product.productId);
                      } else {
                        context.read<UserService>().addToWishlist(uid, widget.product.productId);
                      }
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CustomButton(
              label: 'Add to Cart',
              isLoading: _isAddingToCart,
              onPressed: () async {
                if (uid.isEmpty) return;
                setState(() => _isAddingToCart = true);
                try {
                  final item = CartItemModel(
                    itemId: '',
                    productId: widget.product.productId,
                    quantity: 1,
                    selectedSize: _selectedSize,
                    selectedColor: widget.product.colors.isNotEmpty ? widget.product.colors.first : '',
                    price: widget.product.price,
                  );
                  await context.read<CartService>().addToCart(uid, item);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart!'), behavior: SnackBarBehavior.floating),
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                  }
                } finally {
                  if (mounted) setState(() => _isAddingToCart = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
