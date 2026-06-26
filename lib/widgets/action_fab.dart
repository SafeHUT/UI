import 'package:flutter/material.dart';
import 'package:ui/screens/chat/create_room_dialog.dart';
import 'package:ui/screens/chat/join_room_dialog.dart';

class ActionFab extends StatelessWidget{
  const ActionFab({super.key});

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      backgroundColor:const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24)
        )
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Quick Action",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 20,),
              ListTile(
                leading: const Icon(
                  Icons.group_add,
                ),
                title: const Text(
                  "Create room",
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context, 
                    barrierColor: Colors.black.withValues(alpha:0.4),
                    builder:(context) => const CreateRoomDialog(), 
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.autorenew,
                ),
                title: Text(
                  "New uid",
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Token change code
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.login,
                ),
                title: Text(
                  "Join Room",
                ),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withValues(alpha: 0.4),
                    builder: (context) => JoinRoomDialog()
                  );
                },
              ),
            ],
          ),
        );
      }
    );
  }
  @override
    Widget build(BuildContext context) {
      return FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed:() => _showActions(context),
        child: const Icon(
          Icons.add,
        ),
      );
    }
}