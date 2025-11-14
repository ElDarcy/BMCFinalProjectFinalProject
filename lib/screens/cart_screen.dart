import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList(); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Supplements Cart'),
        backgroundColor: const Color(0xFF424242), 
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF424242)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Your cart is empty.',
                        style: TextStyle(fontSize: 18, color: Colors.white), 
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartItems[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color: const Color(0xFF424242).withOpacity(0.8), 
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.greenAccent, 
                              child: Text(
                                cartItem.name.isNotEmpty
                                    ? cartItem.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.black), 
                              ),
                            ),
                            title: Text(
                              cartItem.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white, 
                              ),
                            ),
                            subtitle: Text(
                              'Qty: ${cartItem.quantity}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₱${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, 
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.greenAccent), 
                                  onPressed: () {
                                    cart.removeItem(cartItem.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              color: const Color(0xFF424242).withOpacity(0.8), 
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal:', cart.subtotal),
                    const SizedBox(height: 8),
                    _buildSummaryRow('VAT (12%):', cart.vat),
                    const Divider(height: 20, thickness: 1, color: Colors.white70), 
                    _buildSummaryRow(
                      'Total:',
                      cart.totalPrice, 
                      isBold: true,
                      color: Colors.greenAccent, 
                      fontSize: 20,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.greenAccent, 
                  foregroundColor: Colors.black, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: cartItems.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              totalAmount: cart.totalPrice,
                            ),
                          ),
                        );
                      },
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 18, color: Colors.black), 
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSummaryRow(
    String label,
    double value, {
    bool isBold = false,
    Color? color,
    double fontSize = 16,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
          ),
        ),
        Text(
          '₱${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? Colors.white, 
          ),
        ),
      ],
    );
  }
}