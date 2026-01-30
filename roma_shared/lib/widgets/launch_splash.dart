import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:roma_shared/theme/app_colors.dart'; // Ensure you export this in your library

class LaunchSplash extends StatefulWidget {
  final VoidCallback onTimerFinished;
  final String logoPath; // Pass 'assets/logo.png'

  const LaunchSplash({
    super.key,
    required this.onTimerFinished,
    required this.logoPath,
  });

  @override
  State<LaunchSplash> createState() => _LaunchSplashState();
}

class _LaunchSplashState extends State<LaunchSplash> {
  @override
  void initState() {
    super.initState();
    // The "Tyre Warmer" delay - 3 seconds before launch
    Future.delayed(const Duration(milliseconds: 3000), () {
      widget.onTimerFinished();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The Logo - Pulsing like an engine
            Image.asset(
              widget.logoPath,
              width: 150,
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              duration: 1000.ms,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1), // Slight engine rev breathing
              curve: Curves.easeInOutQuad,
            )
            .then() // After pulse, huge Zoom out transition (handled by nav usually, but we animate opacity here)
            .fadeOut(delay: 2500.ms, duration: 500.ms),
            
            const SizedBox(height: 50),
            
            // The Loading Indicator - F1 Style Progress Bar
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                color: RomaColors.ferrariRed,
                backgroundColor: RomaColors.carbonFiber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
