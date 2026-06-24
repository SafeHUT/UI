import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeHUT',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: const Color(0xFF111111),
          indicatorColor: const Color(0xFF1E88E5),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          iconColor: Colors.white
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Colors.white,
            fontSize: 16
          ),
          bodyMedium: TextStyle(
            color: Colors.white,
            fontSize: 14
          )
        )
      ),

      home:MainScreen(), 
    );
  }
}
