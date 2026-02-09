import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Placeholder or Gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2D64FF), Color(0xFF1A1A1A)],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),
                  // Logo Placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.home_work, color: Color(0xFF2D64FF), size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Find your perfect\nhome with ease',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Explore thousands of luxury apartments,\nvillas, and studios at your fingertips.',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  // Social Login Buttons
                  _socialButton(
                    context,
                    'Continue with Google',
                    Icons.g_mobiledata,
                    Colors.white,
                    Colors.black,
                  ),
                  const SizedBox(height: 12),
                  _socialButton(
                    context,
                    'Continue with ID',
                    Icons.person_outline,
                    Colors.white.withOpacity(0.1),
                    Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5A5F),
                      ),
                      child: const Text('Sign In with Email'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'By continuing you agree to our Terms & Privacy',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(BuildContext context, String text, IconData icon, Color bg, Color textCol) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: bg == Colors.white ? null : Border.all(color: Colors.white24),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textCol, size: 28),
              const SizedBox(width: 12),
              Text(
                text,
                style: GoogleFonts.outfit(
                  color: textCol,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
