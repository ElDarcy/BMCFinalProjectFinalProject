import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/widgets/order_card.dart';

const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242); 

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Supplement Orders'), 
        backgroundColor: kMetallicGray, 
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black, 
        ),
        child: user == null
            ? const Center(child: Text('Please log in to see your orders.', style: TextStyle(color: Colors.white)))
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('userId', isEqualTo: user.uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: kNeonAccent)); 
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('You have not placed any orders yet.', style: TextStyle(color: Colors.white)));
                  }
                  final orderDocs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: orderDocs.length,
                    itemBuilder: (context, index) {
                      final doc = orderDocs[index];
                      final orderData = doc.data() as Map<String, dynamic>;
                      orderData['id'] = doc.id;
                      return OrderCard(orderData: orderData);
                    },
                  );
                },
              ),
      ),
    );
  }
}