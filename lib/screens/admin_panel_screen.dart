import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_app/screens/admin_order_screen.dart';
import 'package:ecommerce_app/screens/admin_chat_list_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _uploadProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _firestore.collection('products').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product uploaded successfully!')),
      );

      _formKey.currentState!.reset();
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _imageUrlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload product: $e')),
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
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Color(0xFF424242)], 
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                    'Add New Supplement',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white), 
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Image URL',
                      labelStyle: TextStyle(color: Colors.white), 
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)), 
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)), 
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
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)), 
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)), 
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
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)), 
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)), 
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
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)), 
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)), 
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white), 
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter a price';
                      if (double.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
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
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.black)) 
                        : const Text('Upload Supplement'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}