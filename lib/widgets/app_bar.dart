import 'package:flutter/material.dart';
import 'package:ui/screens/settings/settings_screen.dart';
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget{
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        'SafeHUT',
        style: TextStyle(
          color: Colors.blueAccent,
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
                builder: (_) => SettingsScreen(),
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