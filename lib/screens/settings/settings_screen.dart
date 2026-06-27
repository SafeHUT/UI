import 'package:flutter/material.dart';
import 'package:ui/data/user_demo_data.dart';
import 'package:ui/screens/settings/notification_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centers the avatar
            children: [
              if (demoUser != null) ...[
                const CircleAvatar(
                  radius: 50,
                  child: Icon(
                    Icons.person,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "ID: ${demoUser?.anonymousId}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Joined: ${demoUser?.createdAt}",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
                const Icon(Icons.account_circle, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  "Not connected",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],

              const SizedBox(height: 24),
              const Divider(thickness: 1, indent: 24, endIndent: 24),
              const SizedBox(height: 16),

              _buildSettingsSection(
                title: "Preferences",
                children: [
                  _buildListTile(
                    icon: Icons.thumb_up_alt_sharp,
                    title: "Donate to SafeHUT",
                    onTap: () {
                      // TODO: Navigate to donation screen or open URL
                    },
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
                          builder: (context) => const NotificationScreen()
                        )
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
                ],
              ),

              const SizedBox(height: 40),

              if (demoUser != null)
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
                      label: const Text("Destroy Session / Logout"),
                      onPressed: () {
                        // TODO: Handle logout logic
                      },
                    ),
                  ),
                ),
                
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create category headers
  Widget _buildSettingsSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
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
      leading: Icon(icon, color: Colors.white),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 22, color: Colors.white38),
      onTap: onTap,
    );
  }
}