import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final double price;
  final String category;
  final String subCategory;
  final List<String> images;
  final String description;
  final List<String> size;
  final List<String> colors;
  final int stock;
  final DateTime createdAt;
  final int views;
  final bool isTrending;

  ProductModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.category,
    required this.subCategory,
    required this.images,
    required this.description,
    required this.size,
    required this.colors,
    required this.stock,
    required this.createdAt,
    required this.views,
    required this.isTrending,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      productId: documentId,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: data['category'] ?? '',
      subCategory: data['subCategory'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      description: data['description'] ?? '',
      size: List<String>.from(data['size'] ?? []),
      colors: List<String>.from(data['colors'] ?? []),
      stock: data['stock'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: data['views'] ?? 0,
      isTrending: data['isTrending'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'subCategory': subCategory,
      'images': images,
      'description': description,
      'size': size,
      'colors': colors,
      'stock': stock,
      'createdAt': Timestamp.fromDate(createdAt),
      'views': views,
      'isTrending': isTrending,
    };
  }
}
