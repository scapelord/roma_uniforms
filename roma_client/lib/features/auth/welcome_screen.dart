import 'package:flutter/material.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roma_client/features/home/main_layout.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      body: Stack(
        children: [
          // 1. Background Mesh/Pattern (F1 Carbon Fiber feel)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    RomaColors.pitLaneGrey,
                    RomaColors.asphaltBlack,
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Entrance Text
                Text(
                  "RACE READY\nUNIFORMS",
                  style: GoogleFonts.orbitron( // Or Chakra Petch
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ).animate().slideX(begin: -0.2, end: 0, duration: 600.ms).fadeIn(),

                const SizedBox(height: 16),

                Text(
                  "Professional gear for the high-performance workforce.",
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 48),

                // Primary Button (Login)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RomaColors.ferrariRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4), // Sharp corners for speed
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (_) => const MainLayout())
                      );
                    },
                    child: Text(
                      "LOGIN TO PADDOCK",
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 1, end: 0, delay: 600.ms),

                const SizedBox(height: 16),

                // Secondary Button (Signup)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: RomaColors.electricBlue, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to Signup
                    },
                    child: Text(
                      "JOIN THE TEAM",
                      style: GoogleFonts.orbitron(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: RomaColors.electricBlue,
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 1, end: 0, delay: 800.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
