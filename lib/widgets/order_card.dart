import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242); 

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderCard({super.key, required this.orderData});

  @override
  Widget build(BuildContext context) {
    final createdAt = orderData['createdAt'] != null
        ? (orderData['createdAt'] is Timestamp
            ? orderData['createdAt'].toDate()
            : orderData['createdAt'] as DateTime)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: kMetallicGray.withOpacity(0.8), 
      shadowColor: Colors.black.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListTile(
          title: Text(
            'Order ID: ${orderData['id'] ?? 'N/A'}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white), 
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                'Items: ${orderData['itemCount']}',
                style: const TextStyle(fontSize: 14, color: Colors.white70), 
              ),
              Text(
                'Total: ₱${(orderData['totalPrice'] ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 14, color: Colors.white70), 
              ),
              Text(
                'Status: ${orderData['status'] ?? 'Pending'}',
                style: TextStyle(
                  fontSize: 14,
                  color: (orderData['status'] == 'Delivered')
                      ? kNeonAccent 
                      : Colors.orangeAccent, 
                ),
              ),
              if (createdAt != null)
                Text(
                  'Date: ${DateFormat('MM/dd/yyyy - h:mm a').format(createdAt)}',
                  style: const TextStyle(fontSize: 13, color: Colors.white54), 
                ),
            ],
          ),
        ),
      ),
    );
  }
}