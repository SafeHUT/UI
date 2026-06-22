import 'package:flutter/material.dart';

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

          } ,
          icon: const Icon(Icons.settings), 
        ),
      ],
    );
  }

  @override  
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}