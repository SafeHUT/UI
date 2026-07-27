import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../services/api_service.dart';
import 'room_details_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> room;
  const ChatRoomScreen({super.key, required this.room}); 

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController(); 
  
  IO.Socket? _socket;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  final String _currentUserId = ApiService().currentUser?['id'] ?? '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _initSocket();
  }

  @override  
  void dispose() {
    _messageController.dispose();
    if (_socket != null) {
      _socket!.emit('leave_room', widget.room['id']);
      _socket!.disconnect();
      _socket!.dispose();
    }
    super.dispose();
  }

  Future<void> _loadHistory() async {
    try {
      final pastMessages = await ApiService().getRoomMessages(widget.room['id']);
      if (mounted) {
        setState(() {
          _messages = pastMessages;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Failed to load history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initSocket() {
    final String serverUrl = ApiService().baseUrl.replaceAll('/api/v1', '');
    
    _socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': ApiService().currentToken}) // Authenticate!
      .disableAutoConnect()
      .build()
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket Connected');
      _socket!.emit('join_room', widget.room['id']);
    });

    _socket!.on('receive_message', (data) {
      if (mounted) {
        setState(() {
          _messages.insert(0, data); 
        });
      }
    });

    _socket!.on('room_error', (data) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty && _socket != null) {
      _socket!.emit('send_message', {
        'roomId': widget.room['id'],
        'content': text,
      });
      _messageController.clear();
    }
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return '';
    final DateTime dt = DateTime.parse(isoString).toLocal();
    return DateFormat('h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final roomName = widget.room['name']?.toString().isEmpty ?? true ? "Unnamed room" : widget.room['name'];
    final roomToken = widget.room['token'] ?? widget.room['room_code'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title:InkWell(
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (_) => RoomDetailsScreen(room: widget.room))
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(roomName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Token: $roomToken", style: const TextStyle(fontSize: 12, color: Colors.white54)),
            ],
          ),
        )
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
              : ListView.builder(
                  reverse: true, 
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: ((context, index) {
                    final message = _messages[index];
                    final isMe = message['sender_id'] == _currentUserId;
                    
                    final senderDisplay = message['sender_name'] ?? "Anon-${message['sender_anonymous_id']?.toString().substring(0,4) ?? 'User'}"; 

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: Radius.circular(isMe ? 12 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 12),
                          ),
                        ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe) 
                            Text(
                              "Anon-${senderDisplay.toString().length >= 4 ? senderDisplay.toString().substring(0, 4) : senderDisplay}",
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          if (!isMe) const SizedBox(height: 2),
                          Text(
                            message['content'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(message['created_at'] ?? message['createdAt']),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: const Color(0xFF1E1E1E),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12)
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ) 
                  ),
                  IconButton(
                    onPressed: _sendMessage, 
                    icon: const Icon(Icons.send, color: Colors.blueAccent)
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}