import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui/screens/chat/create_room_dialog.dart';
import 'package:ui/screens/chat/home_screen.dart';
import 'package:ui/screens/chat/join_room_dialog.dart';
import 'package:ui/screens/main_screen.dart';
import '../../services/api_service.dart'; 

class ActionFab extends StatelessWidget {
  final VoidCallback onRefresh;
  
  const ActionFab({super.key, required this.onRefresh});

  void _refreshUidConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text("Refresh Public UID?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Your old UID will become inactive. You will get a new public handle, but all your current rooms and messages will remain perfectly intact.", 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent, 
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); 
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                ),
              );
              
              try {
                await ApiService().refreshAnonymousId();
                
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("UID Refreshed! Your past chats are safe.")),
                  );
                  onRefresh(); 
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to refresh UID. Please try again.")),
                  );
                }
              }
            },
            child: const Text("Generate New Alias", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _destroyAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text("Destroy Account?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "This is irreversible. Your account, all rooms, and every message you've ever sent will be permanently deleted from the servers.", 
          style: TextStyle(color: Colors.white70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext); 
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(
                  child: CircularProgressIndicator(color: Colors.redAccent),
                ),
              );
              try {
                await ApiService().destroyAccount();
              } catch (e) {
                debugPrint("Error destroying account: $e");
              }

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen()), 
                  (route) => false,
                );
              }
            },
            child: const Text("Destroy Everything", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 10),
          child:SingleChildScrollView(
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
                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(Icons.group_add, color: Colors.white),
                  title: const Text("Create room", style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(sheetContext); 
                    final didCreate = await showDialog<bool>(
                      context: context, 
                      builder: (context) => const CreateRoomDialog(), 
                    );
                    if(didCreate == true) {
                      onRefresh();
                    }
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.login, color: Colors.white),
                  title: const Text("Join Room", style: TextStyle(color: Colors.white)),
                  onTap: () async { 
                    Navigator.pop(sheetContext); 
                    
                    final didJoin = await showDialog<bool>(
                      context: context, 
                      barrierColor: Colors.black.withValues(alpha: 0.4),
                      builder: (dialogContext) => const JoinRoomDialog() 
                    );
                    
                    if (didJoin == true) {
                      onRefresh();
                    }
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(color: Colors.white24, height: 32),
                ),

                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: Colors.blueAccent),
                  title: const Text("Refresh UID", style: TextStyle(color: Colors.blueAccent)),
                  subtitle: const Text("Get a new handle, keep your chats", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () {
                    Navigator.pop(sheetContext); 
                    _refreshUidConfirmation(context); 
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text("Destroy Account", style: TextStyle(color: Colors.redAccent)),
                  subtitle: const Text("Permanently delete all data", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () {
                    Navigator.pop(sheetContext); 
                    _destroyAccountConfirmation(context); 
                  },
                ),
              ],
            ),
        ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.primary, 
      foregroundColor: Colors.white,
      onPressed: () => _showActions(context),
      child: const Icon(Icons.add),
    );
  }
}