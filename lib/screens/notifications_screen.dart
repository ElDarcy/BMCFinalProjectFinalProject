import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242); 

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _markAsRead(String id, bool isRead) async {
    if (!isRead) {
      await _firestore.collection('notifications').doc(id).update({
        'isRead': true,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        backgroundColor: kMetallicGray, 
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black, 
        ),
        child: _user == null
            ? const Center(child: Text('Please log in.', style: TextStyle(color: Colors.white)))
            : StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('notifications')
                    .where('userId', isEqualTo: _user.uid)
                    .where('isRead', isEqualTo: false)  
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: kNeonAccent)); 
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }


                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: kNeonAccent),
                    );
                  }

                  final docs = snapshot.data!.docs;


                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'You have no notifications.',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final timestamp = data['createdAt'] as Timestamp?;
                      final formattedDate = timestamp != null
                          ? DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(timestamp.toDate())
                          : 'Unknown date';
                      final isRead = data['isRead'] ?? false;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isRead
                              ? kMetallicGray.withOpacity(0.1) 
                              : kNeonAccent.withOpacity(0.2), 
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            isRead
                                ? Icons.notifications_none_rounded
                                : Icons.notifications_active_rounded,
                            color: isRead ? Colors.white70 : kNeonAccent, 
                          ),
                          title: Text(
                            data['title'] ?? 'No Title',
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${data['body'] ?? ''}\n$formattedDate',
                              style: const TextStyle(height: 1.3, color: Colors.white70),
                            ),
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            await _markAsRead(doc.id, isRead);
                          },
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