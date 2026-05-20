import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<UserModel?> getUserProfile(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Future<void> uploadProfileImage(String uid, File imageFile) async {
    String path = 'users/$uid/profile.jpg';
    var ref = _storage.ref().child(path);
    await ref.putFile(imageFile);
    String downloadUrl = await ref.getDownloadURL();
    
    await _firestore.collection('users').doc(uid).update({
      'profileImage': downloadUrl,
    });
  }

  Stream<List<ProductModel>> getUserWishlist(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _firestore.collection('users').doc(uid).collection('wishlist').snapshots().asyncMap((snapshot) async {
      List<ProductModel> wishlistProducts = [];
      for(var doc in snapshot.docs) {
        String productId = doc.id;
        var productDoc = await _firestore.collection('products').doc(productId).get();
        if (productDoc.exists) {
          wishlistProducts.add(ProductModel.fromMap(productDoc.data()!, productDoc.id));
        }
      }
      return wishlistProducts;
    });
  }

  Future<void> addToWishlist(String uid, String productId) async {
    await _firestore.collection('users').doc(uid).collection('wishlist').doc(productId).set({
      'addedAt': FieldValue.serverTimestamp(),
      'productId': productId,
    });
  }

  Future<void> removeFromWishlist(String uid, String productId) async {
    await _firestore.collection('users').doc(uid).collection('wishlist').doc(productId).delete();
  }

  Stream<bool> isProductInWishlist(String uid, String productId) {
    if (uid.isEmpty || productId.isEmpty) return Stream.value(false);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Address Management
  Stream<List<Map<String, dynamic>>> getUserAddresses(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('addresses')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> addAddress(String uid, Map<String, dynamic> address) async {
    await _firestore.collection('users').doc(uid).collection('addresses').add(address);
  }

  Future<void> updateAddress(String uid, String addressId, Map<String, dynamic> address) async {
    await _firestore.collection('users').doc(uid).collection('addresses').doc(addressId).update(address);
  }

  Future<void> deleteAddress(String uid, String addressId) async {
    await _firestore.collection('users').doc(uid).collection('addresses').doc(addressId).delete();
  }

  // Payment Management
  Stream<List<Map<String, dynamic>>> getPaymentMethods(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('payment_methods')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> addPaymentMethod(String uid, Map<String, dynamic> payment) async {
    await _firestore.collection('users').doc(uid).collection('payment_methods').add(payment);
  }

  Future<void> deletePaymentMethod(String uid, String paymentId) async {
    await _firestore.collection('users').doc(uid).collection('payment_methods').doc(paymentId).delete();
  }
}
