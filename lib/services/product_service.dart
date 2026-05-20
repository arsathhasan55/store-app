import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ProductModel>> getAllProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore.collection('products').where('category', isEqualTo: category).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<ProductModel>> getProductsByCategoryAndSubCategory(String category, String subCategory) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .where('subCategory', isEqualTo: subCategory)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
    });
  }
  
  Stream<List<ProductModel>> getRecentBags() {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: 'bags')
        .snapshots()
        .map((snapshot) {
      var products = snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
      // Sort locally to avoid requiring a composite index in Firestore
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  Stream<List<ProductModel>> getMostViewedBags() {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: 'bags')
        .snapshots()
        .map((snapshot) {
      var products = snapshot.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
      // Sort locally to avoid requiring a composite index in Firestore
      products.sort((a, b) => b.views.compareTo(a.views));
      return products;
    });
  }

  Future<void> incrementProductViews(String productId) async {
    await _firestore.collection('products').doc(productId).update({
      'views': FieldValue.increment(1),
    });
  }

  Future<ProductModel?> getProductById(String productId) async {
    var doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      return ProductModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }
}
