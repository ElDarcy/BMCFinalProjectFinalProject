import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    final String category = widget.productData['category'] ?? '';
    final int stock = widget.productData['stock'] ?? 0;

    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: kMetallicGray,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                const SizedBox(height: 16),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '₱${price.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white70),
                const SizedBox(height: 12),
                Text(description, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 12),
                Text(
                  stock == 0
                      ? 'Out of stock'
                      : stock < 10
                          ? 'Low stock'
                          : 'In stock',
                  style: TextStyle(
                    color: stock == 0
                        ? Colors.red
                        : stock < 10
                            ? Colors.orange
                            : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
                  onPressed: stock >= _quantity
                      ? () {
                          try {
                            cart.addItem(
                                widget.productId, name, price, _quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Added $_quantity x $name to cart!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      : null,
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
                const SizedBox(height: 20),
                const Text(
                  'Similar Products',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('products')
                      .where('category', isEqualTo: category)
                      .where('isActive', isEqualTo: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final products = snapshot.data!.docs
                        .map((doc) => doc.data() as Map<String, dynamic>)
                        .toList();

                    final currentCategory =
                        (widget.productData['category'] ?? '')
                            .toString()
                            .trim()
                            .toLowerCase();

                    final similarProducts = products.where((p) {
                      final pCategory =
                          (p['category'] ?? '').toString().trim().toLowerCase();
                      return pCategory == currentCategory &&
                          p['name'] != widget.productData['name'];
                    }).toList();

                    return SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarProducts.length,
                        itemBuilder: (context, index) {
                          final prod = similarProducts[index];
                          return _buildSimilarProductCard(prod, context);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimilarProductCard(
      Map<String, dynamic> product, BuildContext context) {
    final String name = product['name'] ?? 'Product';
    final String imageUrl = product['imageUrl'] ?? '';
    final String productId = product['id'] ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            productData: product,
            productId: productId,
          ),
        ),
      ),
      child: Card(
        color: kMetallicGray.withOpacity(0.8),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: 100,
          height: 140,
          child: Column(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  imageUrl,
                  height: 80,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image,
                          size: 40, color: Colors.white54),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
