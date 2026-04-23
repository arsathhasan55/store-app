import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String brand;
  final String name;
  final String size;
  final double price;
  final String image;
  final String align; // 'left' or 'right'
  int quantity;

  CartItem({
    required this.id,
    required this.brand,
    required this.name,
    required this.size,
    required this.price,
    required this.image,
    required this.align,
    this.quantity = 1,
  });
}

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _items = [
    CartItem(
      id: '1',
      brand: 'H&M',
      name: 'Floral Midi Dress',
      size: 'M',
      price: 325.0,
      quantity: 2,
      image: 'lib/assets/images/cart/yelow girl.png',
      align: 'left',
    ),
    CartItem(
      id: '2',
      brand: 'Nike',
      name: 'Air Max Fit',
      size: '7',
      price: 1490.0,
      quantity: 1,
      image: 'lib/assets/images/cart/shoes.png',
      align: 'right',
    ),
  ];

  List<CartItem> get items => _items;

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void addItem(CartItem newItem) {
    int index = _items.indexWhere((item) => item.id == newItem.id);
    if (index >= 0) {
      _items[index].quantity += newItem.quantity;
    } else {
      _items.add(newItem);
    }
    notifyListeners();
  }

  void incrementQuantity(String id) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String id) {
    int index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
