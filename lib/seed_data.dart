import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // Clear existing products to ensure consistency for test
  debugPrint('Clearing existing products...');
  final existingProducts = await firestore.collection('products').get();
  for (var doc in existingProducts.docs) {
    await doc.reference.delete();
  }

  debugPrint('Generating comprehensive product catalog...');
  
  final List<Map<String, dynamic>> products = [];
  
  // Helper to create product
  void addProduct({
    required String name,
    required double price,
    required String category,
    required String subCategory,
    required List<String> images,
    required bool isTrending,
  }) {
    products.add({
      'name': name,
      'price': price,
      'category': category,
      'subCategory': subCategory,
      'images': images,
      'description': 'A premium $name designed for comfort and style. Perfect for your everyday collection.',
      'size': category == 'bags' ? ['One Size'] : ['S', 'M', 'L', 'XL'],
      'colors': ['Black', 'White', 'Navy'],
      'stock': 20,
      'createdAt': FieldValue.serverTimestamp(),
      'views': 100 + (price * 2).toInt(),
      'isTrending': isTrending,
    });
  }

  // --- WOMEN CATEGORY ---
  // Tops
  final womenTops = ['34.jpg', '35.jpg', '36.jpg', '37.png', '38.png', '39.png', '40.png'];
  for (int i = 0; i < womenTops.length; i++) {
    addProduct(
      name: 'Women Top Style ${i+1}',
      price: 1500.0 + (i * 200),
      category: 'women',
      subCategory: 'Tops',
      images: ['lib/assets/images/women category/top/${womenTops[i]}', if(i==0) 'lib/assets/images/women category/top/35.jpg'], // First one has 2 images
      isTrending: i % 2 == 0,
    );
  }
  
  // Pants
  final womenPants = ['24.jpg', '25.jpg', '26.jpg', '27.jpg'];
  for (int i = 0; i < womenPants.length; i++) {
    addProduct(
      name: 'Women Pants ${i+1}',
      price: 2500.0 + (i * 300),
      category: 'women',
      subCategory: 'Pants',
      images: ['lib/assets/images/women category/pants/${womenPants[i]}'],
      isTrending: i == 0,
    );
  }

  // Shoes
  final womenShoes = ['28.jpg', '29.jpg', '30.jpg', '31.jpg', '32.png', '33.png'];
  for (int i = 0; i < womenShoes.length; i++) {
    addProduct(
      name: 'Women Shoes ${i+1}',
      price: 3500.0 + (i * 500),
      category: 'women',
      subCategory: 'Shoes',
      images: ['lib/assets/images/women category/shoes/${womenShoes[i]}'],
      isTrending: i % 3 == 0,
    );
  }

  // --- MEN CATEGORY ---
  // Caps
  final menCaps = ['2.webp', '3.jpg', '4.jpg', '5.png', '6.webp', '7.webp', 'cap.png'];
  for (int i = 0; i < menCaps.length; i++) {
    addProduct(
      name: 'Men Cap ${i+1}',
      price: 1500.0 + (i * 100),
      category: 'men',
      subCategory: 'Caps',
      images: ['lib/assets/images/men category/caps/${menCaps[i]}'],
      isTrending: i == 6,
    );
  }

  // Pants
  final menPants = ['10.webp', '11.webp', '12.webp', '13.png', '8.jpg', '9.jpg'];
  for (int i = 0; i < menPants.length; i++) {
    addProduct(
      name: 'Men Pants ${i+1}',
      price: 2800.0 + (i * 300),
      category: 'men',
      subCategory: 'Pants',
      images: ['lib/assets/images/men category/pants/${menPants[i]}'],
      isTrending: i % 2 != 0,
    );
  }

  // Shirts
  final menShirts = ['14.jpg', '15.jpg', '16.jpg', '17.webp', '18.webp', '19.webp', 'saved men.png', 'shirt.png'];
  for (int i = 0; i < menShirts.length; i++) {
    addProduct(
      name: 'Men Premium Shirt ${i+1}',
      price: 3200.0 + (i * 400),
      category: 'men',
      subCategory: 'Shirt', // Note: using 'Shirt' to match subCategory filters
      images: ['lib/assets/images/men category/shirts/${menShirts[i]}'],
      isTrending: i > 5,
    );
  }

  // T-Shirts
  final menTShirts = ['45.jpg', '52.jpg', '58.webp', '74.webp'];
  for (int i = 0; i < menTShirts.length; i++) {
    addProduct(
      name: 'Men Graphic T-Shirt ${i+1}',
      price: 1800.0 + (i * 250),
      category: 'men',
      subCategory: 'T-Shirt',
      images: ['lib/assets/images/men category/t-shirts/${menTShirts[i]}'],
      isTrending: i == 0,
    );
  }

  // --- BAGS CATEGORY ---
  final bags = ['bag.png', 'bages girl.png', 'bages.png', 'd.png'];
  for (int i = 0; i < bags.length; i++) {
    addProduct(
      name: 'Designer Bag ${i+1}',
      price: 5000.0 + (i * 1200),
      category: 'bags',
      subCategory: i % 2 == 0 ? 'Recent' : 'Most Viewed',
      images: ['lib/assets/images/bag category/${bags[i]}'],
      isTrending: true,
    );
  }

  // Seeding to Firestore
  debugPrint('Uploading ${products.length} products to Firestore...');
  for (var product in products) {
    await firestore.collection('products').add(product);
  }

  debugPrint('Seeding complete! ${products.length} products added successfully.');
}
