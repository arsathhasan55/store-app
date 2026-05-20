import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CartItemModel>> getUserCart(String uid) {
    return _firestore.collection('carts').doc(uid).collection('items').snapshots().asyncMap((snapshot) async {
      List<CartItemModel> items = [];
      for(var doc in snapshot.docs) {
        CartItemModel item = CartItemModel.fromMap(doc.data(), doc.id);
        if(doc.data().containsKey('productId')) {
           var productDoc = await _firestore.collection('products').doc(item.productId).get();
           if(productDoc.exists) {
             item = CartItemModel.fromMap(doc.data(), doc.id, product: ProductModel.fromMap(productDoc.data()!, productDoc.id));
           }
        }
        items.add(item);
      }
      return items;
    });
  }

  Future<void> addToCart(String uid, CartItemModel item) async {
    await _firestore.collection('carts').doc(uid).collection('items').add(item.toMap());
  }

  Future<void> updateCartItemQuantity(String uid, String itemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeFromCart(uid, itemId);
    } else {
      await _firestore.collection('carts').doc(uid).collection('items').doc(itemId).update({
        'quantity': newQuantity,
      });
    }
  }

  Future<void> removeFromCart(String uid, String itemId) async {
    await _firestore.collection('carts').doc(uid).collection('items').doc(itemId).delete();
  }

  Future<void> clearCart(String uid) async {
    var items = await _firestore.collection('carts').doc(uid).collection('items').get();
    for (var doc in items.docs) {
      await doc.reference.delete();
    }
  }
}
