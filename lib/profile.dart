import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import 'home_page.dart';
import 'save_item.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'models/user_model.dart';
import 'my_orders_page.dart';
import 'address_page.dart';
import 'payment_methods_page.dart';
import 'settings_page.dart';
import 'user_reviews_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; 

  Future<void> _pickAndUploadImage(String uid) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading image...')));
      try {
         await context.read<UserService>().uploadProfileImage(uid, File(image.path));
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated')));
      } catch (e) {
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFC9A249);
    const Color backgroundColor = Color(0xFF131313); // dark grey completely matching mockup overlay

    String uid = context.read<AuthService>().currentUser?.uid ?? '';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,

        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Profile',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Georgia', letterSpacing: 1.0),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                if (uid.isEmpty)
                   const Padding(
                     padding: EdgeInsets.all(20.0),
                     child: Text('Please login to view profile', style: TextStyle(color: Colors.white)),
                   )
                else
                   StreamBuilder<UserModel?>(
                     stream: context.read<UserService>().getUserProfile(uid),
                     builder: (context, snapshot) {
                        UserModel? user = snapshot.data;
                        String userName = user?.name ?? 'Arsath Hasan';
                        String userEmail = user?.email ?? '';
                        String profileImageUrl = user?.profileImage ?? '';

                        return Column(
                          children: [
                            // Avatar
                            GestureDetector(
                              onTap: () => _pickAndUploadImage(uid),
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: profileImageUrl.isNotEmpty
                                      ? DecorationImage(image: NetworkImage(profileImageUrl), fit: BoxFit.cover)
                                      : const DecorationImage(image: AssetImage('lib/assets/images/profile/my photo.png'), fit: BoxFit.cover),
                                  border: Border.all(color: const Color(0xFF2E8B57), width: 3), // Subtle green edge matching photo tone
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Name & Email
                            Text(
                              userName,
                              style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                     }
                   ),

                // Gold Member Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Gold Member',
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'Georgia'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                _buildMenuItem(
                  iconPath: 'lib/assets/images/profile/review.png', 
                  fallbackIcon: Icons.rate_review_outlined,
                  title: 'My Reviews',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UserReviewsPage()));
                  },
                ),
                const SizedBox(height: 32),

                // List Tiles
                _buildMenuItem(
                  iconPath: 'lib/assets/images/profile/location.png', 
                  fallbackIcon: Icons.inventory_2_outlined,
                  title: 'My Orders',
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const MyOrdersPage()));
                  },
                ),
                _buildMenuItem(
                  iconPath: 'lib/assets/images/profile/location.png', 
                  fallbackIcon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressPage()));
                  },
                ),
                _buildMenuItem(
                  iconPath: 'lib/assets/images/profile/atm.jpg', 
                  fallbackIcon: Icons.payment,
                  title: 'Payment Methods',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsPage()));
                  },
                ),
                _buildMenuItem(
                  iconPath: 'lib/assets/images/profile/lock.jpg', 
                  fallbackIcon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                  },
                ),
                
                // Sign Out
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A1A),
                        title: const Text('Sign Out', style: TextStyle(color: Colors.white, fontFamily: 'Georgia')),
                        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final navigator = Navigator.of(context);
                              await context.read<AuthService>().signOut();
                              navigator.popUntil((route) => route.isFirst);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                            child: const Text('Sign Out', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.double_arrow, color: Colors.white, size: 24),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Sign Out',
                            style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SaveItemPage()));
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
              icon: Icon(Icons.favorite_border), // Uses standard saved icon per other views
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildMenuItem({required String iconPath, required IconData fallbackIcon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(fallbackIcon, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Georgia'),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
