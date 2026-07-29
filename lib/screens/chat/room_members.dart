import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class RoomMembersScreen extends StatefulWidget {
  final String roomId;
  final String roomName;

  const RoomMembersScreen({super.key, required this.roomId, required this.roomName});

  @override
  State<RoomMembersScreen> createState() => _RoomMembersScreenState();
}

class _RoomMembersScreenState extends State<RoomMembersScreen> {
  late Future<List<dynamic>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = ApiService().getMembers(widget.roomId);
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    final DateTime dt = DateTime.parse(isoString).toLocal();
    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Members", style: TextStyle(fontSize: 18)),
            Text(widget.roomName, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load members", style: TextStyle(color: Colors.redAccent)));
          }

          final members = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final isMe = member['id'] == ApiService().currentUser?['id'];
              
              // Handle the custom name fallback logic
              final displayName = member['name'] ?? "Anon-${member['anonymous_id']?.toString().substring(0, 4) ?? 'User'}";

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isMe ? Colors.blueAccent : const Color(0xFF1E1E1E),
                  child: Icon(
                    Icons.person,
                    color: isMe ? Colors.white : Colors.white70,
                  ),
                ),
                title: Row(
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text("YOU", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ]
                  ],
                ),
                subtitle: Text(
                  "Joined ${_formatDate(member['joined_at'])}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              );
            },
          );
        },
      ),
    );
  }
}