import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}

class CartProvider with ChangeNotifier {
  String? _userId;
  StreamSubscription<User?>? _authSubscription;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, CartItem> _items = {};

  CartProvider() {
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _userId = null;
        _items.clear();
      } else {
        _userId = user.uid;
        _fetchCart();
      }
      notifyListeners();
    });
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  double get subtotal {
    double total = 0.0;
    _items.forEach((_, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  double get vat => subtotal * 0.12;
  double get totalPrice => subtotal + vat;

  void addItem(String productId, String name, double price, int quantity) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += quantity;
    } else {
      _items[productId] = CartItem(
        id: productId,
        name: name,
        price: price,
        quantity: quantity,
      );
    }
    _saveCart();
    notifyListeners();
  }

  void decreaseItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else {
      _items.remove(productId);
    }
    _saveCart();
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _items.clear();
    if (_userId != null) {
      await _firestore
          .collection('userCarts')
          .doc(_userId)
          .set({'cartItems': []});
    }
    notifyListeners();
  }

  Future<void> _fetchCart() async {
    if (_userId == null) return;
    try {
      final doc =
          await _firestore.collection('userCarts').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final List<dynamic> cartData = data['cartItems'] ?? [];
        _items = {
          for (var item in cartData)
            (item['id'] as String):
                CartItem.fromJson(Map<String, dynamic>.from(item))
        };
      } else {
        _items = {};
      }
    } catch (e) {
      debugPrint('Error fetching cart: $e');
      _items = {};
    }
    notifyListeners();
  }

  Future<void> _saveCart() async {
    if (_userId == null) return;
    try {
      final cartData = _items.values.map((item) => item.toJson()).toList();
      await _firestore
          .collection('userCarts')
          .doc(_userId)
          .set({'cartItems': cartData});
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }


    Future<void> placeOrder() async {
    if (_userId == null || _items.isEmpty) {
      throw Exception('Cart is empty or user not logged in.');
    }

    try {
      final cartData = _items.values.map((item) => item.toJson()).toList();


      final double roundedSubtotal = double.parse(subtotal.toStringAsFixed(2));
      final double roundedVat = double.parse((roundedSubtotal * 0.12).toStringAsFixed(2));
      final double roundedTotalPrice = double.parse((roundedSubtotal + roundedVat).toStringAsFixed(2));

      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData,
        'subtotal': roundedSubtotal,
        'vat': roundedVat,
        'totalPrice': roundedTotalPrice,
        'itemCount': itemCount,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await clearCart();
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }


  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
