import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/widgets/chat_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String? userName;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  Future<void> _markMessagesAsRead() async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    if (currentUser.uid == widget.chatRoomId) {
      await _firestore.collection('chats').doc(widget.chatRoomId).set({
        'unreadByUserCount': 0,
      }, SetOptions(merge: true));
    } else {
      await _firestore.collection('chats').doc(widget.chatRoomId).set({
        'unreadByAdminCount': 0,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final String messageText = _messageController.text.trim();
    _messageController.clear();

    final timestamp = FieldValue.serverTimestamp();

    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'text': messageText,
        'createdAt': timestamp,
        'senderId': currentUser.uid,
        'senderEmail': currentUser.email,
      });

      Map<String, dynamic> parentDocData = {
        'lastMessage': messageText,
        'lastMessageAt': timestamp,
      };

      if (currentUser.uid == widget.chatRoomId) {
        parentDocData['userEmail'] = currentUser.email;
        parentDocData['unreadByAdminCount'] = FieldValue.increment(1);
      } else {
        parentDocData['unreadByUserCount'] = FieldValue.increment(1);
      }

      await _firestore
          .collection('chats')
          .doc(widget.chatRoomId)
          .set(parentDocData, SetOptions(merge: true));


      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName ?? 'Contact Support'), 
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
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .doc(widget.chatRoomId)
                    .collection('messages')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}\n\n(Have you created the Firestore Index?)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white), 
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Say hello!',
                        style: TextStyle(fontSize: 18, color: Colors.white), 
                      ),
                    );
                  }

                  final messages = snapshot.data!.docs;

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageData = messages[index].data() as Map<String, dynamic>;
                      return ChatBubble(
                        message: messageData['text'] ?? '',
                        isCurrentUser: messageData['senderId'] == currentUser!.uid,
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: const TextStyle(color: Colors.white70), 
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white), 
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.white), 
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(color: Colors.greenAccent), 
                        ),
                        filled: true,
                        fillColor: const Color(0xFF424242).withOpacity(0.5), 
                      ),
                      style: const TextStyle(color: Colors.white), 
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.greenAccent), 
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}