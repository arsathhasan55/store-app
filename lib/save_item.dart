import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'profile.dart';

import 'home_page.dart';
import 'product_details_page.dart';
import 'services/user_service.dart';
import 'services/auth_service.dart';
import 'models/product_model.dart';


class SaveItemPage extends StatefulWidget {
  const SaveItemPage({super.key});

  @override
  State<SaveItemPage> createState() => _SaveItemPageState();
}

class _SaveItemPageState extends State<SaveItemPage> {
  int _selectedIndex = 2; // "Saved" tab

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249);
    const Color backgroundColor = Color(0xFF1A1A1A);
    const Color fieldColor = Color(0xFFE4E4E4);
    const Color cardColor = Color(0xFF6B6B6B);
    const Color yellowColor = Color(0xFFFFB300); // Bright yellow for chips

    String uid = context.read<AuthService>().currentUser?.uid ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: SafeArea(
          child: Column(
            children: [
              // Top Bar with Back Button
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      }
                    },
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
                ),
              ),
              const SizedBox(height: 16),
              
              // Title "Save Items"
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Save Items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: fieldColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const TextField(
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: 'search in your save items',
                      hintStyle: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Georgia',
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.black54, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Filters Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFilterChip('Recent', yellowColor),
                    _buildFilterChip('Most Viewed', yellowColor),
                    _buildFilterChip('Favourite', yellowColor),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Product Grid via StreamBuilder
              Expanded(
                child: uid.isEmpty ? const Center(child: Text("Please Login to see Saved Items", style: TextStyle(color: Colors.white))) : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: StreamBuilder<List<ProductModel>>(
                    stream: context.read<UserService>().getUserWishlist(uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(child: CircularProgressIndicator(color: primaryColor));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                         return const Center(child: Text('No saved items.', style: TextStyle(color: Colors.white)));
                      }
                      var savedItems = snapshot.data!;

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75, // Adjust to match image proportions
                        ),
                        itemCount: savedItems.length,
                        itemBuilder: (context, index) {
                          final item = savedItems[index];
                          String imagePath = item.images.isNotEmpty ? item.images.first : 'lib/assets/images/Save items/saved.png';
                          bool isNetwork = imagePath.startsWith('http');

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsPage(product: item)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image & Heart
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: Container(
                                          height: 110,
                                          width: double.infinity,
                                          color: Colors.white,
                                          child: isNetwork ? Image.network(imagePath, fit: BoxFit.cover) : Image.asset(
                                            imagePath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(Icons.image, color: Colors.grey, size: 40),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () async {
                                              final scaffoldMessenger = ScaffoldMessenger.of(context);
                                              await context.read<UserService>().removeFromWishlist(uid, item.productId);
                                              scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Removed!')));
                                          },
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Details
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Georgia',
                                              height: 1.1,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text(
                                              'Rs. ${item.price.toInt()}',
                                              style: const TextStyle(
                                                color: primaryColor,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Georgia',
                                              ),
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
                        },
                      );
                    }
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: backgroundColor,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryColor,
          unselectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                (route) => false,
              );
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Category'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontFamily: 'Georgia',
          fontSize: 15,
        ),
      ),
    );
  }
}
