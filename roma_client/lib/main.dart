import 'package:flutter/material.dart';
import 'package:roma_client/features/auth/welcome_screen.dart';
import 'package:roma_shared/widgets/launch_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roma_shared/constants/app_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(child: RomaClientApp()));
}

class RomaClientApp extends StatelessWidget {
  const RomaClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROMA Uniforms',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // We will customize this later
      home: const SplashHandler(),
    );
  }
}

class SplashHandler extends StatefulWidget {
  const SplashHandler({super.key});

  @override
  State<SplashHandler> createState() => _SplashHandlerState();
}

class _SplashHandlerState extends State<SplashHandler> {
  bool _showSplash = true;

  void _finishSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Requires an asset at assets/logo.png
    if (_showSplash) {
      return LaunchSplash(
        logoPath: 'assets/logo.png', 
        onTimerFinished: _finishSplash,
      );
    }
    return const WelcomeScreen();
  }
}
