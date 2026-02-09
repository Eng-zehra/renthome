import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscureText = true;

  void _handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _phoneController.text.trim(),
    );

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // Go back to root which will now show HomeScreen
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join RentHome',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Fill in your details to start your journey.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleRegister,
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Register'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
