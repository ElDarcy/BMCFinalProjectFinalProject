import 'package:flutter/material.dart';
import 'package:ecommerce_app/screens/home_screen.dart';


const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242);

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Placed!'),
        automaticallyImplyLeading: false,
        backgroundColor: kMetallicGray, 
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black, 
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white, 
                  size: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thank You!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your supplement order has been placed successfully.', 
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: kNeonAccent, 
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}