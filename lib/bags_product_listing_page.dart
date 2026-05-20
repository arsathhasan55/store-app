import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'profile.dart';
import 'save_item.dart';
import 'home_page.dart';
import 'product_details_page.dart';
import 'theme/app_theme.dart';
import 'services/product_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'models/product_model.dart';

class BagsProductListingPage extends StatefulWidget {
  const BagsProductListingPage({super.key});

  @override
  State<BagsProductListingPage> createState() => _BagsProductListingPageState();
}

class _BagsProductListingPageState extends State<BagsProductListingPage> {
  final List<String> _subCategories = ['Recent', 'Most Viewed'];
  String _selectedCategory = 'Recent';
  String _searchQuery = '';

  String _resolveImagePath(String? path) {
    if (path == null || path.isEmpty) return 'lib/assets/images/bag category/bag.png';
    if (path.startsWith('http')) return path;
    if (path.startsWith('lib/assets')) return path;
    if (path.startsWith('assets/')) return 'lib/$path';
    return 'lib/assets/images/bag category/$path';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Luggage & Bags',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                        ),
                      ),
                    ),
                    // Item count badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primaryColor, width: 1),
                      ),
                      child: const Text(
                        'Bags',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Search Bar ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search bags, brands...',
                      hintStyle: TextStyle(color: AppTheme.textDisabled),
                      prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
                      filled: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Sub-Category Chips ──────────────────────────────
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _subCategories.length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final cat = _subCategories[index];
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.white12,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Product Grid ────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: _selectedCategory == 'Recent'
                      ? context.read<ProductService>().getRecentBags()
                      : context.read<ProductService>().getMostViewedBags(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                    }

                    var products = snapshot.data ?? [];
                    if (_searchQuery.isNotEmpty) {
                      products = products
                          .where((p) =>
                              p.name.toLowerCase().contains(_searchQuery) ||
                              p.description.toLowerCase().contains(_searchQuery))
                          .toList();
                    }

                    if (products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.white24),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty ? 'No results for "$_searchQuery"' : 'No items yet!',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) =>
                            _ProductGridCard(product: products[index], resolveImagePath: _resolveImagePath),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textDisabled,
          currentIndex: 1,
          onTap: (i) {
            if (i == 0) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()), (r) => false);
            if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const SaveItemPage()));
            if (i == 3) Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.category_rounded), label: 'Category'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Saved'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// ── Shared Product Grid Card ─────────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final ProductModel product;
  final String Function(String?) resolveImagePath;

  const _ProductGridCard({required this.product, required this.resolveImagePath});

  @override
  Widget build(BuildContext context) {
    final String imagePath = resolveImagePath(product.images.isNotEmpty ? product.images.first : null);
    final bool isNetwork = imagePath.startsWith('http');
    final String uid = context.read<AuthService>().currentUser?.uid ?? '';

    return GestureDetector(
      onTap: () {
        context.read<ProductService>().incrementProductViews(product.productId);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Wishlist
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Hero(
                    tag: 'product_${product.productId}',
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: isNetwork
                            ? Image.network(imagePath, fit: BoxFit.cover)
                            : Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stack) => const Center(
                                  child: Icon(Icons.image_outlined, color: Colors.white24, size: 40),
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Wishlist button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: StreamBuilder<bool>(
                      stream: context.read<UserService>().isProductInWishlist(uid, product.productId),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () {
                            if (uid.isNotEmpty) {
                              if (isSaved) {
                                context.read<UserService>().removeFromWishlist(uid, product.productId);
                              } else {
                                context.read<UserService>().addToWishlist(uid, product.productId);
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isSaved ? AppTheme.primaryColor : Colors.white70,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Georgia',
                        height: 1.3,
                      ),
                    ),
                    Text(
                      'Rs. ${product.price.toInt()}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
