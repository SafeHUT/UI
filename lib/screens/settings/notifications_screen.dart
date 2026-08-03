import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  
  bool _enableAll = true;
  bool _showPreviews = false; 
  bool _playSound = true;
  bool _vibrate = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _enableAll = prefs.getBool('notif_enable_all') ?? true;
        _showPreviews = prefs.getBool('notif_show_previews') ?? false;
        _playSound = prefs.getBool('notif_sound') ?? true;
        _vibrate = prefs.getBool('notif_vibrate') ?? true;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(String key, bool value, Function(bool) updateState) async {
    setState(() => updateState(value));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Notifications", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                SwitchListTile(
                  activeThumbColor: Colors.blueAccent,
                  title: const Text("Allow Notifications", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Pause all alerts from the app", style: TextStyle(color: Colors.white54)),
                  value: _enableAll,
                  onChanged: (val) => _updateSetting('notif_enable_all', val, (v) => _enableAll = v),
                ),
                
                const Divider(color: Colors.white10, height: 32, thickness: 1),
                
                Opacity(
                  opacity: _enableAll ? 1.0 : 0.4,
                  child: IgnorePointer(
                    ignoring: !_enableAll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("PRIVACY", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        SwitchListTile(
                          activeColor: Colors.blueAccent,
                          title: const Text("Show Previews", style: TextStyle(color: Colors.white)),
                          subtitle: const Text("Display message text on lock screen", style: TextStyle(color: Colors.white54)),
                          value: _showPreviews,
                          onChanged: (val) => _updateSetting('notif_show_previews', val, (v) => _showPreviews = v),
                        ),
                        
                        const SizedBox(height: 16),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text("ALERTS", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        SwitchListTile(
                          activeThumbColor: Colors.blueAccent,
                          title: const Text("Sound", style: TextStyle(color: Colors.white)),
                          value: _playSound,
                          onChanged: (val) => _updateSetting('notif_sound', val, (v) => _playSound = v),
                        ),
                        SwitchListTile(
                          activeThumbColor: Colors.blueAccent,
                          title: const Text("Vibrate", style: TextStyle(color: Colors.white)),
                          value: _vibrate,
                          onChanged: (val) => _updateSetting('notif_vibrate', val, (v) => _vibrate = v),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}