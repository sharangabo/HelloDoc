import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/facilities',
        builder: (context, state) => const FacilitiesScreen(),
      ),
      GoRoute(
        path: '/doctors',
        builder: (context, state) => const DoctorsScreen(),
      ),
      GoRoute(
        path: '/appointments',
        builder: (context, state) => const AppointmentsScreen(),
      ),
      GoRoute(
        path: '/features',
        builder: (context, state) => const FeaturesScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/contact',
        builder: (context, state) => const ContactScreen(),
      ),
    ],
  );
}

// Enhanced Home Screen with Helium Health-inspired design
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HelloDoc'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/features'),
            child: const Text('Features'),
          ),
          TextButton(
            onPressed: () => context.go('/about'),
            child: const Text('About'),
          ),
          TextButton(
            onPressed: () => context.go('/contact'),
            child: const Text('Contact'),
          ),
          ElevatedButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'THE #1 HEALTHTECH PROVIDER',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'We provide dynamic digital tools and facilitate healthcare connections, empowering patients and healthcare providers to improve lives.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => context.go('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            // Statistics Section
            Container(
              padding: const EdgeInsets.all(40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard('500+', 'Healthcare Providers'),
                  _buildStatCard('10K+', 'Health Workers'),
                  _buildStatCard('1M+', 'Patients Served'),
                ],
              ),
            ),
            
            // Features Section
            Container(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  const Text(
                    'Our Healthcare Solutions',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          'Provider Management',
                          'Streamline healthcare facility operations with our comprehensive management system.',
                          Icons.local_hospital,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildFeatureCard(
                          'Patient Connect',
                          'Seamless provider-patient interaction and appointment booking.',
                          Icons.people,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HelloDoc Dashboard'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to HelloDoc',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    'Find Facilities',
                    'Locate nearby healthcare providers',
                    Icons.location_on,
                    () => context.go('/facilities'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardCard(
                    'Book Appointments',
                    'Schedule your medical visits',
                    Icons.calendar_today,
                    () => context.go('/appointments'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                    'Find Doctors',
                    'Connect with healthcare professionals',
                    Icons.medical_services,
                    () => context.go('/doctors'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardCard(
                    'Health Records',
                    'Access your medical information',
                    Icons.folder,
                    () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enhanced Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to HelloDoc'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 64,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to access your healthcare services',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: const Text("Don't have an account? Sign Up"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  String gender = 'male';
  String preferredLanguage = 'en';
  final TextEditingController emergencyNameController = TextEditingController();
  final TextEditingController emergencyPhoneController = TextEditingController();
  final TextEditingController emergencyRelationController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      drawer: buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email',
              ),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value != null && value.length >= 6 ? null : 'Password too short',
              ),
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              DropdownButtonFormField<String>(
                value: gender,
                items: ['male', 'female', 'other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => gender = val!),
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              DropdownButtonFormField<String>(
                value: preferredLanguage,
                items: ['en', 'rw', 'fr'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                onChanged: (val) => setState(() => preferredLanguage = val!),
                decoration: const InputDecoration(labelText: 'Preferred Language'),
              ),
              const Divider(),
              const Text('Emergency Contact', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: emergencyNameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: emergencyPhoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: emergencyRelationController,
                decoration: const InputDecoration(labelText: 'Relationship'),
                validator: (value) => value != null && value.isNotEmpty ? null : 'Required',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          // TODO: Integrate with backend registration API
                          Future.delayed(const Duration(seconds: 2), () {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registration successful!')),
                            );
                          });
                        }
                      },
                child: isLoading ? const CircularProgressIndicator() : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FacilitiesScreen extends StatelessWidget {
  const FacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Healthcare Facilities')),
      body: const Center(child: Text('Facilities Screen')),
    );
  }
}

class DoctorsScreen extends StatelessWidget {
  const DoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctors')),
      body: const Center(child: Text('Doctors Screen')),
    );
  }
}

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: const Center(child: Text('Appointments Screen')),
    );
  }
}

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> features = [
      {
        'title': 'GPS-powered Facility Finder',
        'desc': 'Locate nearby hospitals and clinics within a 20km radius.'
      },
      {
        'title': 'Real-time Doctor Availability',
        'desc': 'See which doctors are available for consultations right now.'
      },
      {
        'title': 'Appointment Booking System',
        'desc': 'Schedule, reschedule, or cancel appointments directly through the app.'
      },
      {
        'title': 'Navigation Integration',
        'desc': 'Get turn-by-turn directions to your selected healthcare facility.'
      },
      {
        'title': 'Multi-language Support',
        'desc': 'Use the app in Kinyarwanda, English, or French.'
      },
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Features')),
      drawer: buildDrawer(context),
      body: ListView.builder(
        itemCount: features.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(features[index]['title']!),
            subtitle: Text(features[index]['desc']!),
          );
        },
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String aboutMe =
        'I am passionate about leveraging technology to improve healthcare accessibility in Rwanda. My mission is to connect patients with nearby healthcare facilities and provide real-time doctor availability, reducing waiting times and enhancing the patient experience. With a focus on Kigali, I aim to empower users with tools for easy appointment booking, accurate facility location, and multi-language support. This project is a step towards a healthier, more connected Rwanda.';
    return Scaffold(
      appBar: AppBar(title: const Text('About HelloDoc')),
      drawer: buildDrawer(context),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(aboutMe, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    const String instagram = '@nc.bebeto';
    const String phone = '+250782734169';
    const String email = 'edwardsharangabo@gmail.com';
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      drawer: buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text(email),
              onTap: () => _launchURL('mailto:$email'),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text(phone),
              onTap: () => _launchURL('tel:$phone'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(instagram),
              onTap: () => _launchURL('https://instagram.com/nc.bebeto'),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildDrawer(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: const Text('HelloDoc', style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () => context.go('/'),
        ),
        ListTile(
          leading: const Icon(Icons.featured_play_list),
          title: const Text('Features'),
          onTap: () => context.go('/features'),
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () => context.go('/about'),
        ),
        ListTile(
          leading: const Icon(Icons.contact_mail),
          title: const Text('Contact'),
          onTap: () => context.go('/contact'),
        ),
        ListTile(
          leading: const Icon(Icons.app_registration),
          title: const Text('Register'),
          onTap: () => context.go('/register'),
        ),
        const Divider(),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (val) {
            themeProvider.setTheme(val ? ThemeMode.dark : ThemeMode.light);
          },
          secondary: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
        ),
      ],
    ),
  );
} 