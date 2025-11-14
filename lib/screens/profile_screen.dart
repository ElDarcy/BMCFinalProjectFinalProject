import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';


const kNeonAccent = Colors.greenAccent; 
const kMetallicGray = Color(0xFF424242); 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _currentUser!.updatePassword(_newPasswordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully!', style: TextStyle(color: Colors.black)),
          backgroundColor: kNeonAccent, 
        ),
      );
      _formKey.currentState!.reset();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password: ${e.message}', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent, 
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Logged out successfully!', style: TextStyle(color: Colors.black)),
        backgroundColor: kNeonAccent, 
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: kMetallicGray, 
        elevation: 4,
      ),
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black, 
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 45,
                  backgroundColor: kMetallicGray, 
                  child: Text(
                    _currentUser?.email?.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    _currentUser?.email ?? 'Not logged in',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Text('Change Password', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: const TextStyle(color: Colors.white),
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
                            borderSide: BorderSide(color: kNeonAccent), 
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter a password';
                          if (value.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(color: Colors.white),
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
                            borderSide: BorderSide(color: kNeonAccent), 
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != _newPasswordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: kNeonAccent, 
                    foregroundColor: Colors.black, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.black)) 
                      : const Text('Change Password'),
                ),
                const SizedBox(height: 40),
                const Divider(color: Colors.white70),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kNeonAccent,
                    foregroundColor: Colors.black, 
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}