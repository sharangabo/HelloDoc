import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../main.dart';
import 'package:flutter/foundation.dart';
import 'package:signup_login/screens/appointment_booking_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _userData;
  bool _isLoading = true;
  // Track hover state for each card
  final List<bool> _isHovered = [false, false, false];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Text(
              'HelloDoc',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          // Language selector dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Locale>(
                value: context.locale,
                icon: const Icon(Icons.language, color: Colors.white),
                dropdownColor: Theme.of(context).colorScheme.primary,
                style: GoogleFonts.poppins(color: Colors.white),
                onChanged: (Locale? locale) {
                  if (locale != null) {
                    context.setLocale(locale);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Text('EN', style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: const Locale('rw'),
                    child: Text('RW', style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: const Locale('fr'),
                    child: Text('FR', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          // Dark mode toggle
          Row(
            children: [
              Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
              Switch(
                value: themeProvider.isDarkMode,
                onChanged: (val) => themeProvider.toggleTheme(),
                activeColor: Colors.white,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.white24,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).colorScheme.primary.withAlpha((255 * 0.15).toInt()),
                            child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 32),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData?.name ?? 'User',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _userData?.email ?? FirebaseAuth.instance.currentUser?.email ?? 'No email',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    tr('dashboard'),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Book Appointment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(tr('book_appointment'), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.poppins(fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AppointmentBookingScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Feature Cards with hover effect
                  _featureCard(
                    context,
                    index: 0,
                    icon: Icons.map,
                    title: tr('find_hospitals'),
                    subtitle: tr('find_hospitals_desc'),
                    color: const Color(0xFF00C9A7),
                    onTap: () {
                      _showFeatureDialog(context, tr('find_hospitals'),
                          tr('feature_coming_soon'));
                    },
                  ),
                  const SizedBox(height: 16),
                  _featureCard(
                    context,
                    index: 1,
                    icon: Icons.medical_services,
                    title: tr('doctor_availability'),
                    subtitle: tr('doctor_availability_desc'),
                    color: const Color(0xFF6C63FF),
                    onTap: () {
                      _showFeatureDialog(context, tr('doctor_availability'),
                          tr('feature_coming_soon'));
                    },
                  ),
                  const SizedBox(height: 16),
                  _featureCard(
                    context,
                    index: 2,
                    icon: Icons.access_time,
                    title: tr('wait_time'),
                    subtitle: tr('wait_time_desc'),
                    color: const Color(0xFF222B45),
                    onTap: () {
                      _showFeatureDialog(context, tr('wait_time'),
                          tr('feature_coming_soon'));
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _featureCard(BuildContext context, {required int index, required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return MouseRegion(
      onEnter: (_) {
        if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux) {
          setState(() => _isHovered[index] = true);
        }
      },
      onExit: (_) {
        if (kIsWeb || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux) {
          setState(() => _isHovered[index] = false);
        }
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Card(
          elevation: _isHovered[index] ? 12 : 2,
          shadowColor: _isHovered[index] ? color.withOpacity(0.4) : Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: color.withAlpha((255 * 0.15).toInt()),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(message, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 