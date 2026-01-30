import 'package:flutter/material.dart';
import 'package:roma_admin/features/auth/admin_login_screen.dart';
import 'package:roma_shared/widgets/launch_splash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roma_shared/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(const RomaAdminApp());
}

class RomaAdminApp extends StatelessWidget {
  const RomaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROMA Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
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
    if (_showSplash) {
      return LaunchSplash(
        logoPath: 'assets/logo.png', // Make sure you add the logo to admin assets too!
        onTimerFinished: _finishSplash,
      );
    }
    return const AdminLoginScreen();
  }
}
