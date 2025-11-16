import 'package:flutter/material.dart';

const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242); 

class ProductCard extends StatelessWidget {
  final String productName;
  final double price;
  final String imageUrl;
  final int stock;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.onTap,
  });

  String _getStockStatus() {
    if (stock == 0) return 'Out of stock';
    if (stock < 10) return 'Low stock';
    return 'In stock';
  }

  Color _getStockColor() {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      splashColor: theme.colorScheme.primary.withOpacity(0.2),
      child: Card(
        elevation: 4,
        color: kMetallicGray.withOpacity(0.9), 
        shadowColor: Colors.black.withOpacity(0.3), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: kNeonAccent)); 
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.white54),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white, 
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '₱${price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        color: kNeonAccent, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _getStockStatus(),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStockColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}