import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget{
  const NotificationScreen({super.key});

  @override 

  State<NotificationScreen> createState() => _NotificationScreenState(); 
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _pushNotification = true;
  bool _roomNotification = true;
  bool _browserNotification = true;
  bool _vpnNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notification",
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader("App alerts"),
          SwitchListTile(
            title: const Text(
              "Push Notification",
            ),
            subtitle: const Text(
              "Recive alerts on your device when your app is closed...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            value: _pushNotification, 
            activeThumbColor: Colors.blueAccent,
            onChanged: (bool value) {
              setState(() {
                _pushNotification = value;
              });
            }
          ),
          SwitchListTile(
            title: const Text(
              "Room Notification",
            ),
            subtitle: const Text(
              "Get notified when someone messages you...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            value: _roomNotification, 
            activeThumbColor: Colors.blueAccent, 
            onChanged: (bool value) {
              setState(() {
                _roomNotification = value;
              }); 
            }
          ),
          SwitchListTile(
            title: const Text(
              "Browser Notification",
            ),
            subtitle: const Text(
              "To recive notification from the browser...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            activeThumbColor: Colors.blueAccent,
            value: _browserNotification, 
            onChanged: (bool value) {
              setState(() {
                _browserNotification = value;
              });
            }
          ),
          SwitchListTile(
            title: const Text(
              "Vpn Notification",
            ),
            subtitle: const Text(
              "Notification from vpn...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15
              ), 
            ),
            activeThumbColor: Colors.blueAccent,
            value: _vpnNotification, 
            onChanged: (bool value) {
              setState(() {
                _vpnNotification = value;
              });
            }
          )
        ],
      ),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 18.0,
        right: 24.0,
        bottom: 8.0,
        top: 8.0
      ) ,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 23,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2
        ),
      ), 
    );
  }
}