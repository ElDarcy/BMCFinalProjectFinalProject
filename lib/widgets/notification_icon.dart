import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242);

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final hasUnread = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
        final unreadCount = snapshot.data?.docs.length ?? 0;

        return Badge(
          label: Text('$unreadCount'),
          isLabelVisible: hasUnread,
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white), 
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}