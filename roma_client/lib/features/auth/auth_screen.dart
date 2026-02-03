import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:roma_client/features/home/main_layout.dart';

enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  final AuthMode initialMode;
  final bool isRedirect; 

  const AuthScreen({
    super.key, 
    this.initialMode = AuthMode.login,
    this.isRedirect = false,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController(); // For Signup & Login
  final _nameCtrl = TextEditingController(); // For Signup

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      if (_mode == AuthMode.login) {
        // LOGIN
        await supabase.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        // SIGNUP
        await supabase.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          data: {'full_name': _nameCtrl.text.trim()},
        );
      }

      // Success
      if (mounted) {
        if (widget.isRedirect) {
          Navigator.of(context).pop(true); // Return success
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainLayout()),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError("An unexpected error occurred: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == AuthMode.login;

    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        title: Text(isLogin ? "LOGIN" : "JOIN TEAM", style: GoogleFonts.orbitron()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.isRedirect 
            ? IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()) 
            : null,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  isLogin ? "WELCOME BACK\nDRIVER" : "START YOUR\nCAREER",
                  style: GoogleFonts.orbitron(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.2, end: 0),

                const SizedBox(height: 48),

                // Name (Signup Only)
                if (!isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDec("Full Name", Icons.person_outline),
                      validator: (v) => v!.isEmpty ? "Name is required" : null,
                    ).animate().fadeIn(),
                  ),

                // Email
                TextFormField(
                  controller: _emailCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDec("Email Address", Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : "Invalid Email",
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDec("Password", Icons.lock_outline),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? "Min 6 characters" : null,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RomaColors.ferrariRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isLogin ? "ENTER PADDOCK" : "SIGN UP",
                            style: GoogleFonts.orbitron(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                  ),
                ).animate().scale(delay: 300.ms),

                const SizedBox(height: 24),

                // Toggle Mode
                TextButton(
                  onPressed: () {
                    setState(() {
                      _mode = isLogin ? AuthMode.signup : AuthMode.login;
                    });
                  },
                  child: Text.rich(
                    TextSpan(
                      text: isLogin ? "New to the team? " : "Already have a seat? ",
                      style: const TextStyle(color: Colors.white60),
                      children: [
                        TextSpan(
                          text: isLogin ? "Join Now" : "Login",
                          style: const TextStyle(
                            color: RomaColors.electricBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: RomaColors.electricBlue),
      filled: true,
      fillColor: RomaColors.pitLaneGrey,
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: RomaColors.carbonFiber)),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: RomaColors.electricBlue)),
    );
  }
}
