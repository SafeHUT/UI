import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ui/data/rooms_demo_data.dart';
import 'package:ui/models/rooms_model.dart';
import 'package:ui/screens/chat/chat_room_screen.dart';

class RoomsScreen extends StatefulWidget{
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomsScreen>{

  @override
  Widget build(BuildContext context) {
  final List<RoomsModel> rooms = List.from(demoRooms);

    if(rooms.isEmpty) {
      return const Center(
        child: Text(
          "No rooms joined yet"
        ),
      );
    }
    return ListView.builder(
      itemCount: rooms.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final room = rooms[index];

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.tag,color: Colors.white,),
          ),
          title: Text(
            room.name.isEmpty ? "Unnamed room": room.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )
          ),
          subtitle: Text(
            "Token: ${room.token}"
          ),
          trailing: const Icon(Icons.chevron_right,color: Colors.white30,),
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(room: room) 
              ), 
            );
          },
        );
      },
    );

  }
}