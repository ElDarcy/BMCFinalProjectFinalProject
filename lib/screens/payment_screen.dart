import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum PaymentMethod { card, gcash, bank }


const kNeonAccent = Colors.greenAccent;
const kMetallicGray = Color(0xFF424242); 

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.card;
  bool _isLoading = false;

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 3));
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.placeOrder();
      await cartProvider.clearCart();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTotal = '₱${widget.totalAmount.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Payment'),
        backgroundColor: kMetallicGray, 
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black, 
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Total Amount:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              Text(
                formattedTotal,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Divider(color: Colors.white70),

              Text(
                'Select Payment Method:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),

              RadioListTile<PaymentMethod>(
                title: const Text('Credit/Debit Card', style: TextStyle(color: Colors.white)),
                secondary: const Icon(Icons.credit_card, color: Colors.white),
                value: PaymentMethod.card,
                groupValue: _selectedMethod,
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
                activeColor: kNeonAccent, 
              ),

              RadioListTile<PaymentMethod>(
                title: const Text('GCash', style: TextStyle(color: Colors.white)),
                secondary: const Icon(Icons.phone_android, color: Colors.white),
                value: PaymentMethod.gcash,
                groupValue: _selectedMethod,
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
                activeColor: kNeonAccent, 
              ),

              RadioListTile<PaymentMethod>(
                title: const Text('Bank Transfer', style: TextStyle(color: Colors.white)),
                secondary: const Icon(Icons.account_balance, color: Colors.white),
                value: PaymentMethod.bank,
                groupValue: _selectedMethod,
                onChanged: (PaymentMethod? value) {
                  setState(() {
                    _selectedMethod = value!;
                  });
                },
                activeColor: kNeonAccent, 
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: kNeonAccent,
                  foregroundColor: Colors.black, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black), 
                      )
                    : Text('Pay Now ($formattedTotal)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}