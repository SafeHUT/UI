import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/screens/main_screen.dart';
import 'theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final savedColorName = prefs.getString('app_accent_color') ?? 'Blue';
  
  final Map colorMap = {
    'Blue': Colors.blueAccent,
    'Purple': Colors.purpleAccent,
    'Green': Colors.greenAccent,
    'Orange': Colors.orangeAccent,
    'Red': Colors.redAccent,
  };
  
  appColorNotifier.value = colorMap[savedColorName] ?? Colors.blueAccent;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: appColorNotifier,
      builder: (context, currentColor, child) {
        return MaterialApp(
          title: 'SafeHUT',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true, 
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.dark(
              primary: currentColor,
              secondary: currentColor,
              surface: const Color(0xFF1E1E1E), 
              
            ),
          ),
          home: const MainScreen(), 
        );
      }
    );
  }
}