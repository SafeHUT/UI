import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityScreen extends StatefulWidget{

  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLockEnabled = false;
  bool _canCheckBiometrics = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkHardwareAndSettings();
  }
  
  Future <void> _checkHardwareAndSettings() async {
    // 1. Checking if phone has fingerprint/FaceID hardware
    final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    
    // 2. Checking if user previously turned the lock on
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('app_lock_enabled') ?? false;

    if (mounted) {
      setState(() {
        _canCheckBiometrics = canAuthenticate;
        _isLockEnabled = isEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLock(bool enable) async {
    if (enable) {
      try {
        final didAuthenticate = await _auth.authenticate(
          localizedReason: 'Please authenticate to enable App Lock',
          biometricOnly: false,
          persistAcrossBackgrounding: true,
        );

        if (didAuthenticate) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('app_lock_enabled', true);
          setState(() => _isLockEnabled = true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Authentication failed.")),
          );
        }
      }
    } else {
      // If turning OFF, just save it
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_lock_enabled', false);
      setState(() => _isLockEnabled = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Security")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                if (!_canCheckBiometrics)
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      "Your device does not support biometric authentication or it is not set up.",
                      style: TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: const Icon(Icons.fingerprint, size: 28, color: Colors.blueAccent),
                    title: const Text("Require Biometrics/PIN", style: TextStyle(color: Colors.white, fontSize: 16)),
                    subtitle: const Text("Lock the app when you close it", style: TextStyle(color: Colors.white54)),
                    trailing: Switch(
                      value: _isLockEnabled,
                      activeThumbColor: Colors.blueAccent,
                      onChanged: _toggleLock,
                    ),
                  ),
              ],
            ),
    );
  }
}
