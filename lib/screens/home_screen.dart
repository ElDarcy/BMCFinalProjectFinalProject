import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/order_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecommerce_app/widgets/product_card.dart';
import 'package:ecommerce_app/screens/admin_panel_screen.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/profile_screen.dart';
import 'package:ecommerce_app/widgets/notification_icon.dart';
import 'package:ecommerce_app/screens/chat_screen.dart';


const kMetallicGray = Color(0xFF424242); 
const kNeonAccent = Colors.greenAccent; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  String _userRole = 'user';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    if (_currentUser == null) return;
    try {
      final doc =
          await _firestore.collection('users').doc(_currentUser.uid).get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _userRole = doc['role'] ?? 'user';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: kNeonAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kMetallicGray.withOpacity(0.1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kMetallicGray, 
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Image.asset(
          'assets/images/splash_logo.png',
          height: 50,
        ),
        actions: [

          const NotificationIcon(),

          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),


          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),

          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    tooltip: 'Cart',
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: kNeonAccent, 
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.black, 
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),


      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, kMetallicGray],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _currentUser != null
                    ? 'Welcome, ${_currentUser.email!.split('@')[0]}!'
                    : 'Welcome!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, 
                ),
              ),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('products')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: kNeonAccent)); 
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white), 
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No products found. Add some in the Admin Panel!',
                        style: TextStyle(color: Colors.white), 
                      ),
                    );
                  }

                  final products = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final productDoc = products[index];
                      final productData =
                          productDoc.data() as Map<String, dynamic>? ?? {};

                      return ProductCard(
                        productName: productData['name'] ?? 'Unnamed Product',
                        price: (productData['price'] ?? 0).toDouble(),
                        imageUrl: productData['imageUrl'] ??
                            'https://via.placeholder.com/150',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                productData: productData,
                                productId: productDoc.id,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(_currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final unreadCount =
                    (snapshot.data?.data() as Map?)?['unreadByUserCount'] ?? 0;
                return Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: FloatingActionButton.extended(
                    backgroundColor: kNeonAccent, 
                    foregroundColor: Colors.black, 
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Support'), 
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatScreen(chatRoomId: _currentUser.uid),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : null,
    );
  }
}