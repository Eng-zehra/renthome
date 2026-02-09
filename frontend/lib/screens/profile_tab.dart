import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'admin_add_property.dart';
import 'settings_screen.dart';
import 'payment_methods_screen.dart';
import 'help_center_screen.dart';
import 'admin_dashboard_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isUploading = false;

  Future<void> _pickAndUploadAvatar() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null) {
      setState(() => _isUploading = true);
      final bytes = result.files.first.bytes;
      final name = result.files.first.name;

      if (bytes != null) {
        final url = await ApiService.uploadImage(bytes, name);
        if (url != null) {
          final success = await Provider.of<AuthProvider>(context, listen: false).updateProfile({'avatar': url});
          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated!'), backgroundColor: Colors.green),
            );
          }
        }
      }
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isAdmin = user?.role == 'admin';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2D64FF), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                      child: _isUploading 
                          ? const CircularProgressIndicator(color: Colors.black) 
                          : (user?.avatar == null ? const Icon(LineIcons.user, size: 60, color: Colors.grey) : null),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickAndUploadAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2D64FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LineIcons.camera, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                user?.name ?? 'Guest User',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Text(
                user?.email ?? 'Connect to see profile',
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              if (isAdmin)
                _buildOption(LineIcons.userShield, 'Admin Dashboard', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
                }),
              
              if (isAdmin)
                _buildOption(LineIcons.plus, 'Add Property', () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminAddPropertyScreen()));
                }),
              
              _buildOption(LineIcons.cog, 'Settings', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              }),
              
              _buildOption(LineIcons.creditCard, 'Payment Methods', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
              }),
              
              _buildOption(LineIcons.questionCircle, 'Help Center', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
              }),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => authProvider.logout(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text('Log Out', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 17)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
