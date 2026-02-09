import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../providers/payment_provider.dart';
import '../models/payment_method.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PaymentProvider>(context, listen: false).fetchPaymentMethods());
  }

  void _showAddCardSheet() {
    final cardHolderController = TextEditingController();
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    String selectedCardType = 'Visa';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Add New Card', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: cardHolderController,
              decoration: InputDecoration(
                labelText: 'Card Holder Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(LineIcons.user),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(
                labelText: 'Card Number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(LineIcons.creditCard),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expiryController,
                    decoration: InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      prefixIcon: const Icon(LineIcons.calendar),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCardType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    items: ['Visa', 'Mastercard', 'Amex']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => selectedCardType = v!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (cardHolderController.text.isEmpty || cardNumberController.text.isEmpty) return;
                  
                  final success = await Provider.of<PaymentProvider>(context, listen: false).addPaymentMethod({
                    'card_type': selectedCardType,
                    'card_holder': cardHolderController.text,
                    'card_number': cardNumberController.text,
                    'expiry_date': expiryController.text,
                    'is_default': false,
                  });

                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Card added successfully!'), backgroundColor: Colors.green),
                    );
                  }
                },
                child: const Text('Save Card', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Payment Methods', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: paymentProvider.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saved Cards', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (paymentProvider.methods.isEmpty)
                    _buildEmptyState()
                  else
                    ...paymentProvider.methods.map((card) => _buildCardItem(card)),
                  
                  const SizedBox(height: 30),
                  Text('Other Methods', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildMethodItem(LineIcons.paypal, 'PayPal', 'Connect your account'),
                  _buildMethodItem(LineIcons.apple, 'Apple Pay', 'Set up Apple Pay'),
                  
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _showAddCardSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D64FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Add New Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(LineIcons.creditCard, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No saved cards', style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCardItem(PaymentMethod card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card.cardType == 'Visa' ? const Color(0xFF1E1E1E) : const Color(0xFF2D64FF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.cardType.toUpperCase(),
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, fontStyle: FontStyle.italic),
              ),
              GestureDetector(
                onTap: () => Provider.of<PaymentProvider>(context, listen: false).deletePaymentMethod(card.id),
                child: const Icon(LineIcons.trash, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            card.cardNumber.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} "),
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, letterSpacing: 3, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARD HOLDER', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                  Text(card.cardHolder.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPIRES', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1)),
                  Text(card.expiryDate, style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPayPalDialog() {
    showDialog(
      context: context,
      builder: (context) => PayPalDialog(
        onConnect: (email) async {
          final success = await Provider.of<PaymentProvider>(context, listen: false).addPaymentMethod({
            'card_type': 'PayPal',
            'card_holder': 'PayPal Account',
            'card_number': email,
            'expiry_date': 'N/A', // Not applicable for PayPal
            'is_default': false,
          });

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PayPal account $email connected!'), backgroundColor: Colors.green),
            );
          }
        },
      ),
    );
  }

  void _showApplePayMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(LineIcons.apple, color: Colors.black, size: 30),
            const SizedBox(width: 10),
            Text('Apple Pay', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text('Apple Pay setup is currently only available on supported iOS devices.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildMethodItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.black),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.add, size: 20),
      onTap: () {
        if (title == 'PayPal') {
          _showPayPalDialog();
        } else if (title == 'Apple Pay') {
          _showApplePayMessage();
        }
      },
    );
  }
}

class PayPalDialog extends StatefulWidget {
  final Function(String) onConnect;

  const PayPalDialog({super.key, required this.onConnect});

  @override
  State<PayPalDialog> createState() => _PayPalDialogState();
}

class _PayPalDialogState extends State<PayPalDialog> {
  final _emailController = TextEditingController();
  String? _errorText;
  bool _isValidEmail = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      if (email.isEmpty) {
        _errorText = null;
        _isValidEmail = false;
      } else if (!emailRegex.hasMatch(email)) {
        _errorText = 'Please enter a valid email address';
        _isValidEmail = false;
      } else {
        _errorText = null;
        _isValidEmail = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(LineIcons.paypal, color: Color(0xFF003087), size: 30),
          const SizedBox(width: 10),
          Text('PayPal Login', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter your PayPal email to connect your account.'),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            onChanged: _validateEmail,
            decoration: InputDecoration(
              hintText: 'email@example.com',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorText: _errorText,
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Example: john.doe@gmail.com',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isValidEmail
              ? () {
                  widget.onConnect(_emailController.text);
                  Navigator.pop(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isValidEmail ? const Color(0xFF003087) : Colors.grey,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
