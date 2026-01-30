import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roma_shared/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roma_client/features/auth/welcome_screen.dart'; // To navigate on logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _client = Supabase.instance.client;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final userId = _client.auth.currentUser!.id;
    final data = await _client.from('profiles').select().eq('id', userId).single();
    if (mounted) {
      setState(() {
        _nameCtrl.text = data['full_name'] ?? '';
        _phoneCtrl.text = data['phone_number'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final userId = _client.auth.currentUser!.id;
      await _client.from('profiles').update({
        'full_name': _nameCtrl.text,
        'phone_number': _phoneCtrl.text,
      }).eq('id', userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _client.auth.signOut();
    // Navigate back to Welcome or Login logic
    if (mounted) {
       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RomaColors.asphaltBlack,
      appBar: AppBar(
        title: Text("DRIVER PROFILE", style: GoogleFonts.orbitron()),
        backgroundColor: RomaColors.pitLaneGrey,
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout, color: Colors.red))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(radius: 50, backgroundColor: RomaColors.pitLaneGrey, child: Icon(Icons.person, size: 50, color: Colors.white)),
          const SizedBox(height: 30),
          _buildField("Full Name", _nameCtrl),
          const SizedBox(height: 20),
          _buildField("Phone Number", _phoneCtrl),
          const SizedBox(height: 40),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: RomaColors.electricBlue),
              onPressed: _isLoading ? null : _updateProfile,
              child: _isLoading ? const CircularProgressIndicator() : const Text("SAVE CHANGES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true, fillColor: RomaColors.pitLaneGrey,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        )
      ],
    );
  }
}
