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
  @override
  Widget build(BuildContext context) {
    final user = ApiService().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if(user != null) ...[
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user['name'] ?? "Anon-${user['anonymous_id']?.toString().substring(0,4) ?? ""}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blueAccent, size: 20,),
                      onPressed:() => _showEditNameDialog(context), 
                    )
                  ],
                ),
                const SizedBox(height: 4,),
                Text(
                  "ID: ${user['anonymous_id']}",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontFamily: 'Courier',
                  ),
                ),
                const SizedBox(height: 4,),
                Text(
                  "Joined: ${user['created_at']}",
                  style: const TextStyle(
                    color:Colors.grey,
                    fontSize: 13,
                    fontFamily: 'Courier',
                  ),
                ),
              ]else ...[
                const SizedBox(height: 16),
                const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Not connected",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 24,),
              const Divider(thickness: 1,indent: 24, endIndent: 24,),
              const SizedBox(height: 16,),
              
              _buildSettingsSection(
                title:"Preferences",
                children: [
                  _buildListTile(
                    icon: Icons.thumb_up_alt_sharp, 
                    title: "Donate to SafeHUT", 
                    onTap: () {} 
                  ),
                  _buildListTile(
                    icon: Icons.security,
                    title: "Security",
                    onTap: () {
                      // TODO: Navigate to security screen
                    },
                  ),
                  _buildListTile(
                    icon: Icons.notifications_none,
                    title: "Notifications",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: "About",
                    onTap: () {
                      // TODO: Navigate to about screen
                    },
                  ),
                ] 
              ),
              const SizedBox(height: 24,),
              if( user != null ) 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 14), 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      onPressed: () => _handleLogout(), 
                      label: const Text("Destroy Session/ Logout"),
                    ),
                  ),
                ),
                const SizedBox(height: 24,)
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2
            ),
          ),
        ),
        ...children,
      ],
      
    );
  }
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 22, color: Colors.white38),
      onTap: onTap,
    );
  }
}