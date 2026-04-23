import 'product_model.dart';

class CartItemModel {
  final String itemId;
  final String productId;
  final ProductModel? product; 
  int quantity;
  final String selectedSize;
  final String selectedColor;
  final double price;

  CartItemModel({
    required this.itemId,
    required this.productId,
    this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    required this.price,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> data, String documentId, {ProductModel? product}) {
    return CartItemModel(
      itemId: documentId,
      productId: data['productId'] ?? '',
      product: product,
      quantity: data['quantity'] ?? 1,
      selectedSize: data['selectedSize'] ?? '',
      selectedColor: data['selectedColor'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'price': price,
    };
  }
}
