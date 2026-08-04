import 'package:flutter/material.dart';
import 'package:ui/screens/chat/rooms_screen.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool _isLoading = false;
  bool _isInitializing = true;

  void initState() {
    super.initState();
    _checkExistingUser();
  }
  void _checkExistingUser() async {
    await ApiService().loadSavedToken(); 
    
    if (mounted) {
      setState(() {
        _isInitializing = false; 
      });
    }
  }

  void _generateUser() async {

    setState(() => _isLoading = true);

    try {

      await ApiService().generateNewUser();
      setState(() {});

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate user. Check server connection.'))
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override  
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), 
        ),
      );
    }
    if( ApiService().currentUser == null ) {
      return Scaffold(
        body: Center(
          child: _isLoading ? const CircularProgressIndicator() 
          : ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, 
              foregroundColor: Colors.white
            ),
            onPressed: _generateUser, 
            child: const Text("Generate UID") 
          ),
        ),
      );
    }
    
    return const Scaffold(
      body: RoomsScreen(),
    );
  }
}