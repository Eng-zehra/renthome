import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showEditProfileDialog(BuildContext context, AuthProvider auth) {
    final nameController = TextEditingController(text: auth.user?.name);
    final phoneController = TextEditingController(text: auth.user?.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await auth.updateProfile({
                'name': nameController.text,
                'phone': phoneController.text,
              });
              if (success && mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated!'), backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Security', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Password change feature will be available in the next update.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, AuthProvider auth) {
    final emailController = TextEditingController(text: auth.user?.email);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Email', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your new email address'),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.isNotEmpty && emailController.text.contains('@')) {
                final success = await auth.updateProfile({
                  'email': emailController.text,
                });
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email updated successfully!'), backgroundColor: Colors.green),
                  );
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update email. It may already be in use.'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingItem(
            LineIcons.user, 
            'Edit Profile', 
            'Change your name and info',
            onTap: () => _showEditProfileDialog(context, authProvider),
          ),
          _buildSettingItem(
            LineIcons.lock, 
            'Security', 
            'Password and security',
            onTap: () => _showSecurityDialog(context),
          ),
          _buildSettingItem(
            LineIcons.envelope, 
            'Change Email', 
            'Update your email address',
            onTap: () => _showChangeEmailDialog(context, authProvider),
          ),
          
          _buildToggleItem(
            LineIcons.bell, 
            'Notifications', 
            'Control your alerts',
            _notificationsEnabled,
            (val) => setState(() => _notificationsEnabled = val),
          ),
          
          const SizedBox(height: 30),
          _buildSectionHeader('Preferences'),
          _buildSettingItem(LineIcons.globe, 'Language', 'English (US)'),
          
          _buildToggleItem(
            LineIcons.moon, 
            'Dark Mode', 
            'Switch between light and dark',
            themeProvider.isDarkMode,
            (val) => themeProvider.toggleTheme(),
          ),
          
          const SizedBox(height: 30),
          _buildSectionHeader('Danger Zone'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(LineIcons.trash, color: Colors.red),
            ),
            title: Text('Delete Account', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
            subtitle: const Text('This action is permanent'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion is restricted for demo users.'), backgroundColor: Colors.orange),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2D64FF),
      ),
    );
  }
}
