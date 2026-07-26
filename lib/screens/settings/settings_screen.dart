import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'notification_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _showEditNameDialog(BuildContext context) {

    final TextEditingController nameController = TextEditingController(
      text: ApiService().currentUser?['name'] ?? '',
    );

    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit display name',style: TextStyle(color: Colors.white),),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "Enter your name...",
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide.none)
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel', style: TextStyle(color: Colors.white54),), 
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white
            ),
            onPressed: () async {
              final newName = nameController.text.trim();
              if( newName.isNotEmpty ) {
                try {

                  await ApiService().updateDisplayName(newName);
                  if(context.mounted) {
                    Navigator.pop(context);
                    setState(() {});
                  }
                } catch(e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to update name"))
                    );
                  }
                }
              } 
            }, 
            child: const Text('Save'), 
          )
        ],
      )
    );
  }

  void _handleLogout() async {
    await ApiService().logout();
    if(mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      setState((){});
    }
  }

}