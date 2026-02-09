import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import './providers/auth_provider.dart';
import './providers/property_provider.dart';
import './providers/booking_provider.dart';
import './providers/wishlist_provider.dart';
import './providers/payment_provider.dart';
import './providers/theme_provider.dart';
import './providers/admin_provider.dart';
import './screens/onboarding_screen.dart';
import './screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const RentHomeApp(),
    ),
  );
}

class RentHomeApp extends StatelessWidget {
  const RentHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'RentHome',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D64FF),
          primary: const Color(0xFF2D64FF),
          secondary: const Color(0xFFFF5A5F),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D64FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D64FF),
          brightness: Brightness.dark,
          primary: const Color(0xFF2D64FF),
          secondary: const Color(0xFFFF5A5F),
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D64FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
