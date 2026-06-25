import 'package:flutter/material.dart';
import 'package:ui/models/user_model.dart';
import 'package:ui/services/user_service.dart';

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
      body: FutureBuilder<UserModel>(
        future: UserService().getCurrentUser(),
        builder: (context, snapshot) {
          print(snapshot.connectionState);
          print(snapshot.data);
          print(snapshot.error);

          final user = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: [
                if(user != null ) ...[
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
                      "ID: ${user.anonymousId}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8,),

                    Text(
                      "CreatedAt: ${user.createdAt}",
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
          );
        }
      ),
    );
  }
}