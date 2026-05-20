import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _darkMode = true;
  bool _location = false;

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF131313);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Georgia')),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('Preferences'),
            _buildSwitchTile('Enable Notifications', _notifications, (val) => setState(() => _notifications = val)),
            _buildSwitchTile('Dark Mode', _darkMode, (val) => setState(() => _darkMode = val)),
            _buildSwitchTile('Location Services', _location, (val) => setState(() => _location = val)),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Account'),
            _buildActionTile('Change Password', Icons.lock_outline, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent to email')));
            }),
            _buildActionTile('Privacy Policy', Icons.privacy_tip_outlined, () {}),
            _buildActionTile('Terms of Service', Icons.description_outlined, () {}),
            
            const SizedBox(height: 40),
            Center(
              child: TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  await context.read<AuthService>().signOut();
                  navigator.popUntil((route) => route.isFirst);
                },
                child: const Text('Deactivate Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.white24, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(color: Color(0xFFC9A249), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFC9A249),
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
    );
  }
}
