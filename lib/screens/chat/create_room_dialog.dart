import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CreateRoomDialog extends StatefulWidget{
  const CreateRoomDialog({super.key});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  bool _isLoading = false;
  
  String _selectedDuration = '1d'; 

  void _createRoom() async {
    setState( () => _isLoading = true );
    try {
      final roomData = await ApiService().createRoom(
        expiresIn: _selectedDuration,
      ); 
      
      if( !mounted ) return;
      
      Navigator.pop(context, true); 

    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create room.")),
      );
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }  

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 8.0, 
        sigmaY: 8.0
      ),
      child: AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create new room',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,),),
        
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A new room will be created instantly.',
              style: TextStyle(color: Colors.white70, height: 1.4),  
            ),
            const SizedBox(height: 16),
            
            const Text("Expires In:", style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedDuration,
                  dropdownColor: const Color(0xFF1E1E1E),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: '1h', child: Text("1 Hour")),
                    DropdownMenuItem(value: '4h', child: Text("4 Hours")),
                    DropdownMenuItem(value: '1d', child: Text("24 Hours")),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedDuration = newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54),)
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            ),
            onPressed: _isLoading ? null : _createRoom, 
            child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),) 
              : const Text("Create")
          ),
        ],
      )
    );
  }
}