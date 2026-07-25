import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'chat_room_screen.dart';

class CreateRoomDialog extends StatefulWidget{

  const CreateRoomDialog({super.key});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();

}

class _CreateRoomDialogState extends State<CreateRoomDialog> {

  bool _isLoading = false;
  void _createRoom() async {

    setState( () => _isLoading = true );
    try {

      final roomData = await ApiService().createRoom(expiresIn: "1d"); 
      if( !mounted ) return;
      Navigator.pop(context);

    } catch(e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create room.")),
      );

    }  finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }  

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 8.0, 
        sigmaY: 8.0
      ),
      child: AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create new room',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
        content: const Text(
          'A new room will be created instantly',
          style: TextStyle(color: Colors.white70, height: 1.4),  
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54),)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: _isLoading ? null : _createRoom, 
            child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),) 
              : const Text("Create")
          ),
        ],
      )
    );
  }
}