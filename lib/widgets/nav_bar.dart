import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget{
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.language_outlined),
          selectedIcon: Icon(Icons.language),
          label: 'Browser',
        ),
        NavigationDestination(
          icon: Icon(Icons.shield_outlined),
          selectedIcon: Icon(Icons.shield),
          label: 'VPN',
        ),
      ],
    );
  } 
}