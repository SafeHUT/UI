import 'dart:ui';

import 'package:flutter/material.dart';

class JoinRoomDialog extends StatefulWidget{
  JoinRoomDialog({super.key});

  @override
  State<JoinRoomDialog> createState() => _JoinRoomDialogState(); 
}

class _JoinRoomDialogState extends State<JoinRoomDialog> {
  final TextEditingController _tokenController = TextEditingController();

  @override
  void dispose() {
    _tokenController.dispose(); //Prevent memory leaks
    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
      child: AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Join room",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _tokenController,
          style: const TextStyle(
            color: Colors.white,
          ),
            decoration: InputDecoration(
              hintText: "Input room token...",
              hintStyle: const TextStyle(
                color: Colors.white54
              ),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16)
            ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Cancel", 
            style: TextStyle(
              color: Colors.white54
            )
          ), 
        ),
        ElevatedButton(
          onPressed: () {
            final token = _tokenController.text.trim();
            if(token.isNotEmpty) {
              Navigator.pop(context);
              // ToDo: logic

            print("Joining room ${token}");
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
          ),
          child: const Text(
            'join',
            style: TextStyle(
              color: Colors.white 
            ),
          ),
        ),
      ],
    ),
    );
  }
}