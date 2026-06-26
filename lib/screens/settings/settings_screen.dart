import 'package:flutter/material.dart';
import 'package:ui/data/user_demo_data.dart';

class SettingsScreen extends StatelessWidget{

  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
            child: Column(
              children: [
                if(demoUser != null ) ...[
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
                      "ID: ${demoUser?.anonymousId}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8,),

                    Text(
                      "CreatedAt: ${demoUser?.createdAt}",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
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
          )
      );
  }
}