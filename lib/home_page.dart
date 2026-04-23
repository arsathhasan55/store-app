import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile.dart';
import 'save_item.dart';
import 'womens_product_listing_page.dart';
import 'men_product.dart';
import 'bags_product_listing_page.dart';
import 'theme/app_theme.dart';
import 'widgets/product_card.dart';

import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/product_service.dart';
import 'models/user_model.dart';
import 'models/product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String searchQuery = '';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          color: AppTheme.primaryColor,
          child: CustomScrollView(
            slivers: [
              // Animated App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: _buildHeader(),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchBar(),
                ),
              ),

              // Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: _buildCategoryList(),
                ),
              ),

              // Hero Banner
              SliverToBoxAdapter(
                child: _buildHeroBanner(),
              ),

              // Sections
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildProductSections(),
                ),
              ),
              
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      extendBody: true,
    );
  }

  Widget _buildHeader() {
    final String uid = context.read<AuthService>().currentUser?.uid ?? '';
    return StreamBuilder<UserModel?>(
      stream: context.read<UserService>().getUserProfile(uid),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final name = user?.name ?? 'User';
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'Hello, $name ✨',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
              child: Hero(
                tag: 'profile_avatar',
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                    image: user?.profileImage != null && user!.profileImage!.isNotEmpty
                        ? DecorationImage(image: NetworkImage(user.profileImage!), fit: BoxFit.cover)
                        : const DecorationImage(image: AssetImage('lib/assets/images/profile/my photo.png'), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: TextField(
        onChanged: (v) => setState(() => searchQuery = v.toLowerCase()),
        decoration: const InputDecoration(
          hintText: 'Search styles, brands...',
          prefixIcon: Icon(Icons.search, color: AppTheme.primaryColor),
          filled: false,
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = [
      {'label': 'All', 'page': null},
      {'label': 'Women', 'page': const WomensProductListingPage()},
      {'label': 'Men', 'page': const MenProductListingPage()},
      {'label': 'Bags', 'page': const BagsProductListingPage()},
    ];

    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return GestureDetector(
            onTap: () {
              if (categories[index]['page'] != null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => categories[index]['page'] as Widget));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                categories[index]['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroBanner() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: AssetImage(
                  index == 0 
                    ? 'lib/assets/images/home page/dress.png' 
                    : index == 1 
                      ? 'lib/assets/images/home page/bag.png'
                      : 'lib/assets/images/home page/shoe.png'
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.bottomLeft,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text('FLASH SALE', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 4),
                  const Text('Summer Collection 2027', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Text('Shop Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductSections() {
    return StreamBuilder<List<ProductModel>>(
      stream: context.read<ProductService>().getAllProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        var products = snapshot.data!;
        if (searchQuery.isNotEmpty) {
          products = products.where((p) => p.name.toLowerCase().contains(searchQuery)).toList();
        }

        final trending = products.where((p) => p.isTrending).toList();
        final newArrivals = products.reversed.toList();

        return Column(
          children: [
            _buildSectionHeader('Trending Now'),
            const SizedBox(height: 16),
            _buildProductList(trending),
            const SizedBox(height: 32),
            _buildSectionHeader('New Arrivals'),
            const SizedBox(height: 16),
            _buildProductList(newArrivals),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: () {}, child: const Text('See All')),
      ],
    );
  }

  Widget _buildProductList(List<ProductModel> products) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: 16),
        itemBuilder: (context, index) => SizedBox(width: 160, child: ProductCard(product: products[index])),
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
          currentIndex: _selectedIndex,
          onTap: (i) {
            setState(() => _selectedIndex = i);
            if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (context) => const SaveItemPage()));
            if (i == 3) Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Saved'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
