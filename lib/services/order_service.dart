import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<OrderModel>> getUserOrders(String uid) {
    if (uid.isEmpty) return Stream.value([]);
    return _firestore.collection('orders').where('userId', isEqualTo: uid).snapshots().map((snapshot) {
      final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data(), doc.id)).toList();
      // Sort in-memory to avoid requiring a composite index
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection('orders').add(order.toMap());
  }

  Future<void> cancelOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Cancelled',
    });
  }

  Future<void> returnOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'Returned',
    });
  }
}
