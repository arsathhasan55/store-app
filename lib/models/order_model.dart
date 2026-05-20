import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartItemModel> items; // Can simplify to a list of maps, but for local state this is fine
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final DateTime deliveryDate;
  final bool isDelivered;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.deliveryDate,
    required this.isDelivered,
  });

  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    var itemsList = data['items'] as List? ?? [];
    List<CartItemModel> mappedItems = itemsList.map((i) {
      return CartItemModel.fromMap(i as Map<String, dynamic>, i['itemId'] ?? '');
    }).toList();

    return OrderModel(
      orderId: documentId,
      userId: data['userId'] ?? '',
      items: mappedItems,
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Processing',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deliveryDate: (data['deliveryDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 20)),
      isDelivered: data['isDelivered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((i) => i.toMap()..['itemId'] = i.itemId).toList(), // Add itemId for reconstructing
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'isDelivered': isDelivered,
    };
  }
}
