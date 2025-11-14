import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateOrderStatus(String orderId, String newStatus, String userId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': 'Order Status Updated',
        'body': 'Your order ($orderId) has been updated to "$newStatus".',
        'orderId': orderId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order status updated and notification sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  void _showStatusDialog(String orderId, String currentStatus, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        const statuses = ['Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: statuses.map((status) {
              return ListTile(
                title: Text(status),
                trailing: currentStatus == status ? const Icon(Icons.check) : null,
                onTap: () {
                  _updateOrderStatus(orderId, status, userId);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
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
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white), 
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No orders found.',
                  style: TextStyle(fontSize: 18, color: Colors.white), 
                ),
              );
            }

            final orders = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16.0), 
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final orderData = order.data() as Map<String, dynamic>;
                final Timestamp? timestamp = orderData['createdAt'] as Timestamp?;
                final String formattedDate = timestamp != null
                    ? DateFormat('MM/dd/yyyy hh:mm a').format(timestamp.toDate())
                    : 'Date unavailable';
                final String status = orderData['status'] ?? 'Unknown';
                final String userId = orderData['userId'] ?? 'Unknown User';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0), 
                  elevation: 4, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  color: const Color(0xFF424242).withOpacity(0.8), 
                  child: ListTile(
                    leading: const Icon(Icons.shopping_cart, color: Colors.greenAccent), 
                    title: Text(
                      'Order ID: ${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white), 
                    ),
                    subtitle: Text(
                      'User: $userId\n'
                      'Total: ₱${(orderData['totalPrice'] as num).toDouble().toStringAsFixed(2)}\n'
                      'Date: $formattedDate',
                      style: const TextStyle(color: Colors.white70), 
                    ),
                    isThreeLine: true,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: status == 'Pending'
                            ? Colors.orange
                            : status == 'Processing'
                                ? Colors.blue
                                : status == 'Shipped'
                                    ? Colors.purple
                                    : status == 'Delivered'
                                        ? Colors.green
                                        : Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    onTap: () => _showStatusDialog(order.id, status, userId),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}