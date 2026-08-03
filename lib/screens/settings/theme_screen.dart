import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeScreen extends StatefulWidget{

  const ThemeScreen({super.key});

  @override   
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  
  String _selectedColorName = 'Blue';

  final Map<String, Color> _availableColors = {
    'Blue': Colors.blueAccent,
    'Purple': Colors.purpleAccent,
    'Green': Colors.greenAccent,
    'Orange': Colors.orangeAccent,
    'Red': Colors.redAccent,
  };
  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedColorName = prefs.getString('app_accent_color') ?? 'Blue';
      });
    }
  }
  Future<void> _saveTheme(String colorName) async {
    setState(() => _selectedColorName = colorName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_accent_color', colorName);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$colorName theme applied!"),
          backgroundColor: _availableColors[colorName],
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Appearance", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "CHAT BUBBLE & ACCENT COLOR",
              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          ..._availableColors.entries.map((entry) {
            final colorName = entry.key;
            final colorValue = entry.value;
            final isSelected = _selectedColorName == colorName;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: colorValue,
                radius: 12,
              ),
              title: Text(colorName, style: const TextStyle(color: Colors.white)),
              trailing: isSelected 
                  ? Icon(Icons.check_circle, color: colorValue) 
                  : null,
              onTap: () => _saveTheme(colorName),
            );
          }), 
        ],
      ),
    );
  }
}