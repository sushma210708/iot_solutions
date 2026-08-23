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
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your account is disabled', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
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
        // User not found in MongoDB or API failed -> Treat as normal user
        if (mounted) {
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
          SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
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
        backgroundColor: const Color(0xFF161E24),
        title: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF12181C),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E272D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B885))),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF14B885))),
                ),
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF14B885))),
                  ),
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF14B885))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14B885),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Login' : 'Sign Up', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Need an account? Sign Up' : 'Already have an account? Login',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
