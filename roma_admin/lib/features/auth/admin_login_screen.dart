import 'package:flutter/material.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roma_admin/services/biometric_service.dart';
import 'package:roma_admin/features/dashboard/admin_dashboard.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool allowed = await BiometricService.isDeviceSupported();
    setState(() => _canCheckBiometrics = allowed);
  }

  Future<void> _handleBiometricLogin() async {
    bool authenticated = await BiometricService.authenticate();
    if (authenticated) {
      // TODO: Here you would validate the stored session token
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Identity Verified. Welcome, Director.")),
      );
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const AdminDashboard())
      );
    }
  }

  void _handleManualLogin() {
    // For now, bypass validation for testing flow
     Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => const AdminDashboard())
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Admin Shield/Logo
              Icon(
                Icons.security, 
                size: 64, 
                color: RomaColors.ferrariRed
              ).animate().scale(duration: 600.ms),
              
              const SizedBox(height: 20),
              
              Text(
                "RACE CONTROL",
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),

              const SizedBox(height: 40),

              // 2. Manual Login Fields (Fallback)
              _buildTextField("Admin ID (Email)", _emailController, false),
              const SizedBox(height: 16),
              _buildTextField("Access Code", _passwordController, true),

              const SizedBox(height: 30),

              // 3. Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RomaColors.ferrariRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: _handleManualLogin,
                  child: Text("INITIATE SESSION", style: GoogleFonts.orbitron(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 40),

              // 4. Biometric Trigger
              if (_canCheckBiometrics) ...[
                const Divider(color: RomaColors.carbonFiber),
                const SizedBox(height: 20),
                
                InkWell(
                  onTap: _handleBiometricLogin,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                      border: Border.all(color: RomaColors.electricBlue.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                      color: RomaColors.pitLaneGrey.withOpacity(0.3),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.fingerprint, size: 40, color: RomaColors.electricBlue),
                        const SizedBox(height: 10),
                        Text(
                          "BIOMETRIC ACCESS",
                          style: GoogleFonts.roboto(
                            color: RomaColors.electricBlue,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: RomaColors.pitLaneGrey,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: RomaColors.carbonFiber),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: RomaColors.ferrariRed),
        ),
      ),
    );
  }
}
