import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';


const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242);

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.productData['name'] ?? 'Product';
    final String description = widget.productData['description'] ?? '';
    final String imageUrl = widget.productData['imageUrl'] ?? '';
    final double price = (widget.productData['price'] ?? 0).toDouble();

    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: kMetallicGray, 
        elevation: 4,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black, 
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(imageUrl, height: 250, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('₱${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Colors.white)),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white70),
                      const SizedBox(height: 12),
                      Text(description, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.remove),
                            onPressed: _decrementQuantity,
                            style: IconButton.styleFrom(
                              backgroundColor: kMetallicGray.withOpacity(0.5), 
                              foregroundColor: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text('$_quantity', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          IconButton.filled(
                            icon: const Icon(Icons.add),
                            onPressed: _incrementQuantity,
                            style: IconButton.styleFrom(
                              backgroundColor: kNeonAccent,
                              foregroundColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          cart.addItem(
                            widget.productId,
                            name,
                            price,
                            _quantity,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added $_quantity x $name to cart!'), duration: const Duration(seconds: 2)),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_outlined),
                        label: const Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: kNeonAccent, 
                          foregroundColor: Colors.black, 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}