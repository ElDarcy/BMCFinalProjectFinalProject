import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_order_screen.dart';
import 'package:ecommerce_app/screens/admin_chat_list_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool _isActive = true;
  String _selectedCategory = 'Whey Protein';
  String? _editingProductId;

  final List<String> _categories = [
    'Whey Protein',
    'Creatine',
    'Multi-vitamins',
    'L-carnitine',
    'Pre-workout',
    'Mass Gainer',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final ordersToday = await _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .get();

    final allOrders = await _firestore.collection('orders').get();
    final users = await _firestore.collection('users').get();
    final products = await _firestore.collection('products').get();

    double totalSales = 0;
    Map<String, int> bestSellers = {};
    List<double> revenueData = List.filled(7, 0);

    for (var order in allOrders.docs) {
      totalSales += order['totalPrice'];

      final orderDate = (order['createdAt'] as Timestamp).toDate();
      final daysAgo = now.difference(orderDate).inDays;

      if (daysAgo < 7) {
        revenueData[6 - daysAgo] += order['totalPrice'];
      }

      for (var item in order['items']) {
        bestSellers[item['name']] =
          (bestSellers[item['name']] ?? 0) +
          ((item['quantity'] ?? 0) as num).toInt();
      }
    }

    return {
      'totalSales': totalSales,
      'ordersToday': ordersToday.docs.length,
      'totalUsers': users.docs.length,
      'bestSellers': bestSellers,
      'revenueData': revenueData,
      'totalProducts': products.docs.length,
    };
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': _imageUrlController.text.trim(),
        'category': _selectedCategory,
        'stock': int.tryParse(_stockController.text.trim()) ?? 0,
        'isActive': _isActive,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_editingProductId != null) {
        await _firestore.collection('products').doc(_editingProductId).update(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        await _firestore.collection('products').add(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product uploaded successfully!')),
        );
      }

      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
      _stockController.clear();
      _editingProductId = null;

      setState(() => _isActive = true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save product: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF424242),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF424242)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: _fetchStats(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.greenAccent),
                      );
                    }

                    final stats = snapshot.data!;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard('Total Sales', '₱${stats['totalSales'].toStringAsFixed(2)}'),
                            _buildStatCard('Orders Today', '${stats['ordersToday']}'),
                            _buildStatCard('Total Users', '${stats['totalUsers']}'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Revenue (Last 7 Days)',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    7,
                                    (i) => FlSpot(i.toDouble(), stats['revenueData'][i]),
                                  ),
                                  isCurved: true,
                                  color: Colors.greenAccent,
                                  barWidth: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Best-Selling Products',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        ...stats['bestSellers'].entries.take(5).map(
                          (entry) => Text(
                            '${entry.key}: ${entry.value}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Divider(height: 40, thickness: 1, color: Colors.white70),

                ElevatedButton.icon(
                  icon: const Icon(Icons.receipt_long, color: Colors.black),
                  label: const Text('Manage All Orders'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminOrderScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                  label: const Text('View User Chats'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AdminChatListScreen()),
                    );
                  },
                ),

                const Divider(height: 40, thickness: 1, color: Colors.white70),

                Text(
                  _editingProductId != null ? 'Edit Product' : 'Add New Supplement',
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        dropdownColor: const Color(0xFF424242),
                        style: const TextStyle(color: Colors.white),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCategory = value!),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        keyboardType: TextInputType.url,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter an image URL';
                          if (!value.startsWith('http')) return 'Please enter a valid URL';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Supplement Name',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a price';
                          if (double.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock Quantity',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.greenAccent),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter stock quantity';
                          if (int.tryParse(value) == null) return 'Please enter a valid number';
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      SwitchListTile(
                        title: const Text('Active (Enable Product)', style: TextStyle(color: Colors.white)),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        activeThumbColor: Colors.greenAccent,
                      ),

                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _uploadProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(Colors.black),
                              )
                            : Text(_editingProductId != null ? 'Update Supplement' : 'Upload Supplement'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: const Color(0xFF424242),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
            Text(value, style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}