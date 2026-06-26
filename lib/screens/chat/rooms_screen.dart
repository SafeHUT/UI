import 'package:flutter/material.dart';
import 'package:ui/data/rooms_demo_data.dart';
import 'package:ui/models/rooms_model.dart';

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
      itemBuilder: (context, index) {

      final room = rooms[index];

      return ListTile(
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
        onTap: () => {},
      );
      },
    );

  }
}