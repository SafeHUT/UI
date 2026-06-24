import 'package:flutter/material.dart';
import 'package:ui/screens/settings_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'SafeHUT',
        style: TextStyle(
          color: const Color(0xFF1E88E5),
          fontWeight: FontWeight(700),
          fontStyle: FontStyle.italic,
          fontSize: 28
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(
                  anonymousId: "123",
                  createdAt: "15 Feb 2026"
                ),
              ),   
            );
          } ,
          icon: const Icon(Icons.settings), 
          iconSize: 28,
        ),
      ],
    );
  }

  @override  
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}