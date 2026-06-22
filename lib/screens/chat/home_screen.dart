import 'package:flutter/material.dart';
import 'package:ui/widgets/action_fab.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Text('hello'),
      ), 
      floatingActionButton: ActionFab(),
    );
  }
}