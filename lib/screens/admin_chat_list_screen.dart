import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/chat_screen.dart';
import 'package:flutter/material.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Chats'),
        backgroundColor: const Color(0xFF424242), 
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
          stream: FirebaseFirestore.instance
              .collection('chats')
              .orderBy('lastMessageAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error} \n\n (Have you created the Firestore Index?)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white), 
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No active chats.',
                  style: TextStyle(fontSize: 18, color: Colors.white), 
                ),
              );
            }

            final chatDocs = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                final chatDoc = chatDocs[index];
                final chatData = chatDoc.data() as Map<String, dynamic>;

                final String userId = chatDoc.id;
                final String userEmail = chatData['userEmail'] ?? 'User ID: $userId';
                final String lastMessage = chatData['lastMessage'] ?? '...';

                final int unreadCount = chatData['unreadByAdminCount'] ?? 0;

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
                      child: const Icon(Icons.fitness_center, color: Colors.black), 
                    ),
                    title: Text(
                      userEmail,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, 
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70), 
                    ),
                    trailing: unreadCount > 0
                        ? Badge(
                            label: Text('$unreadCount'),
                            child: const Icon(Icons.arrow_forward_ios, color: Colors.greenAccent), 
                          )
                        : const Icon(Icons.arrow_forward_ios, color: Colors.greenAccent), 
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatRoomId: userId,
                            userName: userEmail,
                          ),
                        ),
                      );
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