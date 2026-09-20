import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../admin/admin_layout.dart';
import '../pages/home_page.dart';

class LoginPage extends StatefulWidget {
  final Widget? redirectPage;
  
  const LoginPage({super.key, this.redirectPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between Login and Sign Up

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _authService.signInWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _authService.signUpWithEmailPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      // 1. Get Firebase ID Token
      final token = await _authService.getIdToken();
      if (token == null) throw Exception("Failed to retrieve authentication token.");

      // 2. Fetch MongoDB Profile
      try {
        final profile = await _apiService.getCurrentUserProfile(token);
        
        // 3. Determine Routing
        if (mounted) {
          if (profile.status != 'active') {
            await _authService.signOut();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your account is disabled', style: TextStyle(color: Color(0xFF1E293B))), backgroundColor: Colors.red));
            return;
          }

          if (profile.role == 'super_admin' || profile.role == 'content_admin' || profile.role == 'viewer') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminLayout()));
          } else {
            // Normal user (no admin roles)
            if (widget.redirectPage != null) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.redirectPage!));
            } else {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
            }
          }
        }
      } catch (e) {
        // User not found in MongoDB or API failed -> Show error so we can debug
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching admin profile: $e', style: const TextStyle(color: Color(0xFF1E293B))), backgroundColor: Colors.red),
          );
          // Fallback to home page
          if (widget.redirectPage != null) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => widget.redirectPage!));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString(), style: const TextStyle(color: Color(0xFF1E293B))), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first.')),
      );
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(color: Color(0xFF1E293B))),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(48.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Color(0x1F1E293B)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), letterSpacing: -0.5),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Color(0xFF475569)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x3D1E293B)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2563EB)), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Color(0xFF475569)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x3D1E293B)), borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color(0xFF2563EB)), borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF2563EB))),
                  ),
                ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF2563EB))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Need an account? Sign Up' : 'Already have an account? Login',
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
