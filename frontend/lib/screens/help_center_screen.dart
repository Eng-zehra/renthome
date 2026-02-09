import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Help Center', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D64FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(LineIcons.headset, color: Color(0xFF2D64FF), size: 40),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How can we help?', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('We are available 24/7 to assist you.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text('Popular Topics', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildHelpItem('How to book a home?'),
          _buildHelpItem('Cancellation policy'),
          _buildHelpItem('Payment security'),
          _buildHelpItem('Becoming a host'),
          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () {},
              child: Text('Contact Support', style: GoogleFonts.outfit(color: const Color(0xFF2D64FF), fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
