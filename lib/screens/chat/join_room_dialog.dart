import 'dart:ui';
import '../../services/api_service.dart';
import 'package:flutter/material.dart';

class JoinRoomDialog extends StatefulWidget{
  const JoinRoomDialog({super.key});

  @override
  State<JoinRoomDialog> createState() => _JoinRoomDialogState(); 
}

class _JoinRoomDialogState extends State<JoinRoomDialog> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {

    _tokenController.dispose(); //Prevent memory leaks
    super.dispose();

  } 

  void _joinRoom() async {

    final token = _tokenController.text.trim();
    if(token.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      
      await ApiService().joinRoom(token);
      if( !mounted ) return;
      Navigator.pop(context, true); // passing 'true' so the ui knows to refresh the list
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid room code or room expired')),
      );
    } finally {

      if( mounted ) setState(() => _isLoading = false);
    }

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
          textCapitalization: TextCapitalization.characters,
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
          onPressed: () => _isLoading ? null : () => Navigator.pop(context),
          child: const Text(
            "Cancel", 
            style: TextStyle(
              color: Colors.white54
            )
          ), 
        ),
        ElevatedButton(
          onPressed: _isLoading ? null: _joinRoom,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)
              ),
          ),
          child: _isLoading 
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),) 
          : const Text('join'),
        ),
      ],
    ),
    );
  }
}