import 'package:flutter/material.dart';

class RomaColors {
  // The Track (Backgrounds)
  static const Color asphaltBlack = Color(0xFF121212); // Main BG
  static const Color pitLaneGrey = Color(0xFF1E1E1E);  // Cards/Surfaces
  
  // The Liveries (Accents)
  static const Color ferrariRed = Color(0xFFFF2800);   // Primary Action / Error
  static const Color safetyCarYellow = Color(0xFFFFD700); // Warnings / Highlights
  static const Color electricBlue = Color(0xFF00F0FF); // Cyberpunk accents / Links
  static const Color victoryWhite = Color(0xFFFFFFFF); // Text
  static const Color carbonFiber = Color(0xFF2C2C2C);  // Borders/Dividers
  
  // Gradients (Speed feel)
  static const LinearGradient redFade = LinearGradient(
    colors: [Color(0xFFFF2800), Color(0xFF8B0000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
