import 'package:flutter/material.dart';

class ActionFab extends StatelessWidget{
  ActionFab({super.key});

  void _showActions(BuildContext context) {
   showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF121212),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Quick Actions",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(
                Icons.group_add,
                color: Colors.blue,
              ),
              title: const Text(
                "Create Room",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to create room page
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.autorenew,
                color: Colors.blue,
              ),
              title: const Text(
                "New uid",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Change token for the user
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.login,
                color: Colors.blue,
              ),
              title: const Text(
                "Join Room",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Join room
              },
            ),
            const SizedBox(height: 12,),
          ],
        ),
      );
    } 
  );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      onPressed: () => _showActions(context), 
      child: const Icon(Icons.add),
    );
  }
}