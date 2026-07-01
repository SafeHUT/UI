import 'package:flutter/material.dart';
import 'package:ui/screens/chat/rooms_screen.dart';
import 'package:ui/widgets/action_fab.dart';
import '../../data/user_demo_data.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if(demoUser == null){
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {},
            child: const Text("Generate UID"),
          ),
        ),
      );
    }
    return const Scaffold(
      body:  RoomsScreen(),
    floatingActionButton: ActionFab(),
    );
  }
}