import 'package:flutter/material.dart';
import 'package:ui/auth/app_lock_wrapper.dart';
import 'package:ui/screens/browser/browse_screen.dart';
import 'package:ui/screens/chat/home_screen.dart';
import 'package:ui/screens/vpn/vpn_screen.dart';
import 'package:ui/widgets/app_bar.dart';
import 'package:ui/widgets/nav_bar.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});

  @override 
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  final pages = [
    HomeScreen(),
    BrowseScreen(),
    VpnScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppLockWrapper(
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: CustomNavBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          } 
        ),
      ),
    );
  }
}