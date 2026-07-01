import 'package:flutter/material.dart';
import 'package:ui/data/user_demo_data.dart';
import 'package:intl/intl.dart';
import 'package:ui/models/rooms_model.dart';

class ChatRoomScreen extends StatefulWidget{
  final RoomsModel room;
  const ChatRoomScreen({super.key, required this.room}); 

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();

}
class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController(); 
  final List<Map<String, dynamic>> _dbMessages = [
    {
      "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "room_id": "room_1",
      "user_id": "system_user",
      "content": "Welcome to the room!",
      "createdAt": DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String()
    },
    {
      "id": "b1ffbc99-9c0b-4ef8-bb6d-6bb9bd380a22",
      "room_id": "room_1",
      "user_id": "another_user_id", // Someone else
      "content": "Hey everyone, what's up?",
      "createdAt": DateTime.now().subtract(const Duration(minutes: 2)).toIso8601String()
    },
  ];

  @override  
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if(text.isNotEmpty) {
      setState(() {
        _dbMessages.add({
          "id": UniqueKey().toString(),
          "room_id": "room1",
          "user_id": demoUser?.anonymousId ?? "unknown",
          "content": text,
          "createdAt": DateTime.now().toIso8601String(),
        });
      });
      _messageController.clear();
    }
  }

  String _formatTime(String isoString) {
    final DateTime dt = DateTime.parse(isoString).toLocal();
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final roomTitle = widget.room.name.isEmpty  ? "Unnamed room": widget.room.name;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Text(
                roomTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
              "Token: ${widget.room.token}",
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dbMessages.length,
              itemBuilder: ((context, index) {
                final message = _dbMessages[index];
                final isMe = message["user_id"] == demoUser?.anonymousId;

                return Align(
                  alignment: isMe ? Alignment.centerRight: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe? Colors.blueAccent: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isMe ? 12 : 0),
                        bottomRight: Radius.circular(isMe ? 0 : 12),
                      ),
                    ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end: CrossAxisAlignment.start,
                    children: [
                      if(!isMe) 
                        Text(
                          "Anon-${message["user_id"].toString().substring(0, 4)}",
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if(!isMe)
                        const SizedBox(height: 2,),
                      Text(
                        message['content'],
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),

                      const SizedBox(height: 4 ,),

                      Text(
                        _formatTime(message["createdAt"]),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.white38, 
                            fontSize: 10
                        ),
                      ),
                    ],
                  ),
                  )
                );
              }),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8) ,
            color: Color(0xFF1E1E1E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "message...",
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none ,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12)
                    ),
                  ) 
                ),
                IconButton(
                  onPressed: _sendMessage , 
                  icon: const Icon(Icons.send,color: Colors.blueAccent,)
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}