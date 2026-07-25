import 'package:flutter/material.dart';
import 'chat_room_screen.dart';
import '../../services/api_service.dart';

class RoomsScreen extends StatefulWidget{
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomsScreen> {

  late Future<List<dynamic>> _roomsFuture;

  @override 
  void initState() {
    super.initState();
    _fetchRooms();
  }

  void _fetchRooms() {
    setState(() {
      _roomsFuture = ApiService().getMyRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _roomsFuture, 
      builder: (context, snapshot) {
        if( snapshot.connectionState == ConnectionState.waiting ) {
          return const Center( child: CircularProgressIndicator(color: Colors.blueAccent,),);
        } 

        if (snapshot.hasError) {
          return const Center(child: Text("Failed to load rooms", style: TextStyle(color: Colors.redAccent)));
        }
      
        final rooms = snapshot.data ?? [];

        if (rooms.isEmpty) {
          return const Center(
            child: Text("No rooms joined yet", style: TextStyle(color: Colors.white54, fontSize: 16)),
          );
        }

        return RefreshIndicator(
          color: Colors.blueAccent,
          backgroundColor: const Color(0xFF1E1E1E),
          onRefresh: () async {
            _fetchRooms();
            await _roomsFuture;
          }, 
          child: ListView.builder(
            itemCount: rooms.length,
            padding: EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final room = rooms[index];
              final token = room['token'] ?? '';
              final name = room['name'] ?? '';
              
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.tag, color: Colors.white,),
                ),
                title: Text(
                  name.isEmpty ? "Unnamed room" : name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                ),
                subtitle: Text("Token: $token", style: const TextStyle(color: Colors.grey),),
                trailing: const Icon(Icons.chevron_right, color: Colors.white30,),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatRoomScreen(room: room)) 
                  );
                  _fetchRooms();
                },
              );
            }
          ), 
        );
      } 
    );
  }
}