import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget{
  final String anonymousId;
  final String createdAt;

  const SettingsScreen({
    super.key,
    required this.anonymousId,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child:
         Column(
          children: [
            const SizedBox(height: 32),
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "ID: $anonymousId",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8,),

            Text(
              "CreatedAt: $createdAt",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 32,),
            
             ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Profile"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.security),
              title: const Text("Security"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text("Notifications"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text("Appearance"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}