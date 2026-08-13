import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ui/screens/browser/browse_screen.dart';
import '../../services/api_service.dart';
import 'room_details_screen.dart';
import 'dart:async';
import '../../services/crypto_service.dart';
import 'dart:isolate';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> room;
  const ChatRoomScreen({super.key, required this.room}); 

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  String? _roomKey;
  final TextEditingController _messageController = TextEditingController(); 
  Color _myBubbleColor = Colors.blueAccent;
  // expire counter
  Timer? _countDownTimer;
  String _timeLeft = '';
  // typing show
  Timer? _typingTimer;
  bool _isMeTyping = false;
  bool _isSomeoneElseTyping = false;
  
  IO.Socket? _socket;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  final String _currentUserId = ApiService().currentUser?['id'] ?? '';

  @override
  void initState() {
    
    super.initState();
    ApiService().markRoomAsRead(widget.room['id']); 
    _calculateTimeLeft();
    _countDownTimer = Timer.periodic(const Duration(minutes: 1),(_) {
      _calculateTimeLeft();
    });
    _loadThemeColor();
    _loadHistory();
    _initSocket();
  }
  Future<void> _loadThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorName = prefs.getString('app_accent_color') ?? 'Blue';
    
    final Map<String, Color> colorMap = {
      'Blue': Colors.blueAccent,
      'Purple': Colors.purpleAccent,
      'Green': Colors.greenAccent,
      'Orange': Colors.orangeAccent,
      'Red': Colors.redAccent,
    };

    if (mounted) {
      setState(() {
        _myBubbleColor = colorMap[colorName] ?? Colors.blueAccent;
      });
    }
  }
  void _calculateTimeLeft() {

    if( widget.room['expires_at'] == null ) return;

    final expiresAt = DateTime.parse(widget.room['expires_at']).toLocal();
    final difference = expiresAt.difference(DateTime.now());

    if (mounted) {
      setState(() {
        if (difference.isNegative) {
          _timeLeft = "Expired";
          // Optional: You could even trigger Navigator.pop(context) here to auto-kick them!
        } else {
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          
          if (hours > 0) {
            _timeLeft = "${hours}h ${minutes}m left";
          } else {
            _timeLeft = "${minutes}m left"; // Only show minutes if under an hour
          }
        }
      });
    }
  }

  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context, 
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text("Edit Message", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text("Delete Message", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _socket!.emit('delete_message', {
                  'messageId': message['id'],
                  'roomId': widget.room['id'],
                });
              },
            ),
          ],
        ),
      )
    );
  }

  void _showEditDialog(Map<String, dynamic> message) {
    final TextEditingController editController = TextEditingController(text: message['content']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text("Edit Message", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: editController,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: () async { 
              if (editController.text.trim().isNotEmpty && _roomKey != null) {
                
                final encryptedEdit = await CryptoService.encryptMessage(
                  plaintext: editController.text.trim(),
                  roomkeyBase64: _roomKey!,
                );

                _socket!.emit('edit_message', {
                  'messageId': message['id'],
                  'roomId': widget.room['id'],
                  'newContent': encryptedEdit, 
                });
                
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onTextChanged(String text) {
    if (text.isNotEmpty) {
      if (!_isMeTyping && _socket != null) {
        _isMeTyping = true;
        _socket!.emit('typing', widget.room['id']);
      }
      
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _isMeTyping = false;
        _socket?.emit('stop_typing', widget.room['id']);
      });
    } else {
      if (_isMeTyping && _socket != null) {
        _isMeTyping = false;
        _typingTimer?.cancel();
        _socket!.emit('stop_typing', widget.room['id']);
      }
    }
  }
  @override  
  void dispose() {
    _countDownTimer?.cancel();
    _typingTimer?.cancel();
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
      _roomKey = await ApiService().getRoomKey(widget.room['id']);

      if (_roomKey == null) {
        if (mounted) setState(() => _isLoading = false);
        return; 
      }

      final pastMessages = await ApiService().getRoomMessages(widget.room['id']);
      
      for (var msg in pastMessages) {
        msg['content'] = await CryptoService.decryptMessage(
          encryptedPayload: msg['content'],
          roomkeyBase64: _roomKey!,
        );
      }

      if (mounted) {
        setState(() {
          _messages = pastMessages;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to load history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initSocket() {
    final String serverUrl = ApiService().baseUrl.replaceAll('/api/v1', '');
    
    _socket = IO.io(serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .setAuth({'token': ApiService().currentToken}) 
      .disableAutoConnect()
      .build()
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket Connected');
      _socket!.emit('join_room', widget.room['id']);
    });

    _socket!.on('receive_message', (data) async {
      if (_roomKey != null) {
        data['content'] = await CryptoService.decryptMessage(
          encryptedPayload: data['content'],
          roomkeyBase64: _roomKey!,
        );
      }
      if (mounted) {
        setState(() {
          _messages.insert(0, data); 
        });
      }
    });

    _socket!.on('room_error', (data) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
    });

    _socket!.on('user_typing', (_) {
      if (mounted) setState(() => _isSomeoneElseTyping = true);
    });

    _socket!.on('user_stopped_typing', (_) {
      if (mounted) setState(() => _isSomeoneElseTyping = false);
    });

    _socket!.on('message_deleted',(messageId) {
      if( mounted ) {
        setState(() {
          _messages.removeWhere( (msg) => msg['id'] == messageId);
        });
      }
    });

    _socket!.on('message_edited', (updatedMsg) async {
      if (_roomKey != null) {
        updatedMsg['content'] = await CryptoService.decryptMessage(
          encryptedPayload: updatedMsg['content'],
          roomkeyBase64: _roomKey!,
        );
      }
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((msg) => msg['id'] == updatedMsg['id']);
          if (index != -1) {
            _messages[index]['content'] = updatedMsg['content'];
          }
        });
      }
    });
    _socket!.on('new_user_joined', (data) async {
      if (_roomKey != null) {
        final targetUserId = data['userId'];
        final targetPublicKey = data['publicKey']; 
        
        final myPrivateKey = await ApiService().getPrivateKey();
        
        final wrappedKey = await CryptoService.wrapRoomKey(
          myPrivateKeyBase64: myPrivateKey!,
          theirPublicKeyBase64: targetPublicKey,
          roomKeyBase64: _roomKey!,
        );

        _socket!.emit('share_room_key', {
          'roomId': widget.room['id'],
          'targetUserId': targetUserId,
          'wrappedKey': wrappedKey,
        });
      }
    });

    _socket!.on('receive_room_key', (data) async {
      if (_roomKey == null) {
        final senderPublicKey = data['senderPublicKey'];
        final wrappedKey = data['wrappedKey'];
        
        final myPrivateKey = await ApiService().getPrivateKey();

        try {
          final unwrappedRoomKey = await CryptoService.unwrapRoomKey(
            myPrivateKeyBase64: myPrivateKey!,
            theirPublicKeyBase64: senderPublicKey,
            wrappedKeyPayload: wrappedKey,
          );

          await ApiService().saveRoomKey(widget.room['id'], unwrappedRoomKey);
          
          if (mounted) {
            setState(() {
              _roomKey = unwrappedRoomKey;
              _loadHistory(); 
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("🔒 Room Key received. Connection secure.")),
            );
          }
        } catch (e) {
          debugPrint("Failed to unwrap room key.");
        }
      }
    });
  }
  void _sendMessage() async {
    final text = _messageController.text.trim();
    
    if (text.isNotEmpty && _socket != null && _roomKey != null) {
      
      final String currentText = text;
      final String currentKey = _roomKey!;

      final encryptedText = await Isolate.run(() async {
        return await CryptoService.encryptMessage(
          plaintext: currentText,
          roomkeyBase64: currentKey,
        );
      });

      _socket!.emit('send_message', {
        'roomId': widget.room['id'],
        'content': encryptedText, 
      });
      
      _messageController.clear();
      if (_isMeTyping) {
        _isMeTyping = false;
        _typingTimer?.cancel();
        _socket!.emit('stop_typing', widget.room['id']);
      }
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
              const SizedBox(width: 8),
                  if (_timeLeft.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _timeLeft,
                        style: const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
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
                      child:GestureDetector(
                        onLongPress: isMe ? () => _showMessageOptions(message): null, 
                        child:Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Theme.of(context).colorScheme.primary: const Color(0xFF1E1E1E),
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
                          Linkify(
                            onOpen: (link) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BrowseScreen(initialUrl: link.url),
                                ),
                              );
                            },
                            text: message['content'],
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.white70,
                              fontSize: 16,
                            ),
                            linkStyle: const TextStyle(
                              color: Colors.blueAccent, 
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                            options: const LinkifyOptions(humanize: false),
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
                      )
                    );
                  }),
                ),
          ),
          if (_isSomeoneElseTyping)
            const Padding(
              padding: EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Someone is typing...", 
                  style: TextStyle(
                    color: Colors.blueAccent, 
                    fontSize: 12, 
                    fontStyle: FontStyle.italic
                  )
                ),
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
                      onChanged: _onTextChanged,
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