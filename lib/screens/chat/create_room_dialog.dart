import 'dart:ui';

import 'package:flutter/material.dart';

class CreateRoomDialog extends StatelessWidget{
  const CreateRoomDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 8.0,
        sigmaY: 8.0
      ), 
      child: AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Create new room',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        content: const Text(
          "A new room will be created instantly. you can invite friends and change name later.",
          style: TextStyle(
            color: Colors.white70,
            height: 1.4
          ),
        ),
        actions: [
          TextButton(
            onPressed:() => Navigator.pop(context), 
            child: const Text(
              "Cancel", 
              style: TextStyle(
                color: Colors.white54,
              ),
            )
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)
            ),
            ),
            onPressed: (){
              Navigator.pop(context);
              // TODO: create room 
              print("room created...");
            },
            child: const Text(
              "Create"
            ),
          ),
        ],
      ),
    ); 
  }
}