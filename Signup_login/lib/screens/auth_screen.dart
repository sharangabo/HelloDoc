import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _agreed = false;
  String? _error;
  bool _showPhoneAuth = false;
  String? _verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Sign In' : 'Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _showPhoneAuth ? _buildPhoneAuth() : _buildEmailAuth(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailAuth() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_isLogin ? 'Sign in to your account' : 'Create new account',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email Address'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (!_isLogin && value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          if (!_isLogin) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (val) => setState(() => _agreed = val ?? false),
                ),
                const Expanded(child: Text('By signing up, you agree to our Terms & Conditions')),
              ],
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_isLogin ? 'Sign In' : 'Sign Up'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_isLogin ? "Don't have an account? " : 'Already have an account? '),
              GestureDetector(
                onTap: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? 'Sign Up' : 'Sign In',
                    style: const TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Or connect with'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.g_mobiledata, size: 32, color: Colors.red),
                onPressed: _isLoading ? null : _signInWithGoogle,
              ),
              IconButton(
                icon: const Icon(Icons.phone, size: 28, color: Colors.green),
                onPressed: _isLoading ? null : () => setState(() => _showPhoneAuth = true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneAuth() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Phone Authentication', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone Number', hintText: '+2507XXXXXXXX'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        if (_verificationId == null) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendCode,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Code'),
            ),
          ),
        ] else ...[
          TextField(
            controller: _smsController,
            decoration: const InputDecoration(labelText: 'SMS Code'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _verifyCode,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify & Sign In'),
            ),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : () => setState(() { _showPhoneAuth = false; _verificationId = null; }),
          child: const Text('Back to Email/Google'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isLogin && !_agreed) {
      setState(() => _error = 'You must agree to the terms and conditions.');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendCode() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) Navigator.pushReplacementNamed(context, '/home');
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() { _error = e.message; _isLoading = false; });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() { _verificationId = verificationId; _isLoading = false; });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() { _verificationId = verificationId; });
        },
      );
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _verifyCode() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _smsController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }
} 