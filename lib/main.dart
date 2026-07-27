import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'services/api_service.dart';

void main() async {

  // Required when doing async work before runApp 
  WidgetsFlutterBinding.ensureInitialized();

  await ApiService().loadSavedToken();

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
          backgroundColor: Color(0xFF111111),
          indicatorColor: Colors.blueAccent,
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier'
            ),
          ),
        ),

        listTileTheme: ListTileThemeData(
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
            subtitleTextStyle: const TextStyle(
              fontSize: 13,
              fontFamily: 'Courier', // Gives the token a subtle developer/code look
              color: Colors.grey,
            ),
            iconColor: Colors.blueAccent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
