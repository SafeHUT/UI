import 'package:flutter/material.dart';
import 'package:ui/screens/chat/room_members.dart';
import '../../services/api_service.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> room;
  const RoomDetailsScreen({super.key, required this.room});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  bool _isLeaving = false;
  late Map<String, dynamic> _roomData;
  late bool _isMuted;

  @override 
  void initState() {
    super.initState();
    _roomData = Map<String, dynamic>.from(widget.room);
    _isMuted = _roomData['is_muted'] == true;
  }
  void _showEditNameDialog() {

    final TextEditingController nameController = TextEditingController(
      text: _roomData['name'] ?? ''
    );

    showDialog(
      context: context, 
      builder:(context) => AlertDialog(
       backgroundColor: const Color(0xFF121212), 
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
       title: const Text('Edit Room Name', style: TextStyle(color: Colors.white),),
       content: TextField(
        controller: nameController,
        style: TextStyle(color: Colors.white),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: "Enter room name...",
          hintStyle: const TextStyle(color:Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
        ),
       ),
       actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.white54),),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white
          ),
          onPressed: () async {
            final newName = nameController.text.trim();
            if( newName.isNotEmpty ) {
              try{
                await ApiService().updateRoomName(widget.room['id'], newName);
                if(context.mounted) {
                  Navigator.pop(context);
                  setState(() {
                    _roomData['name'] = newName; 
                  });
                }
              } catch(e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update room name"))
                );
              }
            }
          },
          child: const Text("Save"), 
        ),
       ],
      )

    );
  }

  void _leaveRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text("Leave Room?", style: TextStyle(color: Colors.white)),
        content: const Text("You will stop receiving messages and lose access unless you have the token to rejoin.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Leave"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLeaving = true);
    
    try {
      await ApiService().leaveRoom(widget.room['id']);

      if (mounted) {
        // Pop the details screen
        Navigator.pop(context);
        // Pop the ChatRoomScreen to go back to the Home/Rooms list
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to leave room")));
        setState(() => _isLeaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomName = widget.room['name']?.toString().isEmpty ?? true ? "Unnamed room" : widget.room['name'];
    final roomToken = widget.room['token'] ?? widget.room['room_code'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Room Details"),
      ),
      body: _isLeaving
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.tag, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  roomName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  "Token: $roomToken",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Courier'),
                ),
                
                const SizedBox(height: 32),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text("SETTINGS", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.edit),
                  title: const Text("Change Room Name"),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: _showEditNameDialog,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: const Icon(Icons.people_outline),
                  title: const Text("View Members"),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomMembersScreen(
                          roomId: _roomData['id'], 
                          roomName: roomName,
                        ),
                      ),
                    );
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: Icon(
                    _isMuted ? Icons.notifications_off : Icons.notifications_none,
                  ),
                  title: const Text("Mute Notifications"),
                  trailing: Switch(
                    value: _isMuted, 
                    activeThumbColor: Colors.blueAccent,
                    onChanged: (val) async {
                      setState(() => _isMuted = val);
                      try {

                        await ApiService().toggleRoomMute(_roomData['id'], val);
                        _roomData['is_muted'] = val;
                      }catch (e) {
                        if (mounted) {
                          setState(() => _isMuted = !val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to update settings"))
                          );
                        }
                      }
                    }
                  ),
                ),
                
                const SizedBox(height: 32),
                const Divider(thickness: 1, indent: 24, endIndent: 24),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text("Leave Room"),
                    onPressed: _leaveRoom,
                  ),
                )
              ],
            ),
    );
  }
}