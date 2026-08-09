import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ui/services/crypto_service.dart';

class ApiService {

    static final ApiService _instance = ApiService._internal();
    factory ApiService() => _instance;

    late Dio dio;
    final FlutterSecureStorage _storage = FlutterSecureStorage();

    final String baseUrl = "http://10.0.2.2:4000/api/v1";
    
    String? _accessToken;
    Map<String, dynamic>? currentUser;

    ApiService._internal(){ 
        dio = Dio(
            BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
            ),
        );
        dio.interceptors.add(InterceptorsWrapper( onRequest:(options, handler) {
                if(_accessToken != null) {
                    options.headers['Authorization'] = 'Bearer $_accessToken';
                }
                return handler.next(options);
            },
        ));
    }

    // loading accessToken
    Future<bool> loadSavedToken() async {

      _accessToken = await _storage.read(key: 'jwt_token');
      if(_accessToken != null) {
        try{

          final response = await dio.get('/user/current-user');
          currentUser = response.data['data'];

          return true;

        } catch(e) {

          await _storage.delete(key: 'jwt_token');
          _accessToken = null;
          return false;
        }
      }

      return false;
    }

   Future<void> refreshAnonymousId() async {
      try {
        final response = await dio.patch('/user/refresh-id');
        final data = response.data['data']; 
        
        currentUser = data['user']; 
        _accessToken = data['accessToken'];
        
        await _storage.write(key: 'jwt_token', value: _accessToken);
        
      } catch (e) {
        print("Error refreshing UID: $e");
        rethrow;
      }
    }

    Future<void> destroyAccount() async {
      try {
        await dio.delete('/user/current-user'); 
      } catch (e) {
        print("Error destroying account on server: $e");
        rethrow;
      } finally {
        await logout(); 
      }
    }

    // generate UID 
    Future <void> generateNewUser() async {
      try {
        final keys = await CryptoService.generateKeyPair();
        final publicKey = keys['publicKey']!; 
        final privateKey = keys['privateKey']!;
        
        final response = await dio.post('/user',data: {
          'publicKey': publicKey
        });

        final data = response.data['data'];
        
        _accessToken = data['accessToken'];
        currentUser = data['user'];

        await _storage.write(key: 'jwt_token', value: _accessToken);
        await _storage.write(key: 'private_key', value: privateKey);
      } catch(e) {

        print("Error generating user: $e");
        rethrow;
      }
    } 

    // Private key for message descryption
    Future<String?> getPrivateKey() async {
      return await _storage.read(key: 'private_key');
    }

    // logout
    Future <void> logout() async {

      await _storage.delete(key: 'jwt_token');
      _accessToken = null;
      currentUser = null;
    }

    // update user name
    Future <void> updateDisplayName(String name) async {

      final response = await dio.patch("/user/name", data: {
        "name": name,
      });
      currentUser = response.data['data'];
    }

    // create new room 
    Future<Map<String, dynamic>> createRoom({String expiresIn = "1d"}) async {
    final roomKey = await CryptoService.generateRoomKey();

    final response = await dio.post('/room/create', data: {
      "expires_in": expiresIn,
    });

    final roomData = response.data['data'];
    final String roomId = roomData['id'];

    await saveRoomKey(roomId, roomKey);

    return roomData;
  }

    // Join existing room 
    Future <Map<String, dynamic>> joinRoom( String roomCode ) async {

      final response = await dio.post('/room/join',data: {
        "room_code": roomCode,
      });
      return response.data['data'];

    }

    // get room members
    Future <List<dynamic>> getMembers(String roomId) async {
      final response = await dio.get('/room/$roomId/members');
      return response.data['data'] ?? [];
    }

    // leave room 
    Future <void> leaveRoom(String roomId) async {
      await dio.delete('/room/$roomId/leave');
    }

    // update room name
    Future <void> updateRoomName(String roomId, String name) async {
      await dio.patch('/room/$roomId/name', data: {
        "name": name
      });
    }

    // messages mark as read
    Future<void> markRoomAsRead(String roomId) async {
      try {
        await dio.patch('/room/$roomId/read');
      } catch (e) {
        print("Failed to mark as read: $e");
      }
    }

    // Notification mute for specific room
    Future<void> toggleRoomMute(String roomId, bool isMuted) async {
      await dio.patch('/room/$roomId/mute', data: {
        "isMuted": isMuted,
      });
    }
    // Fetch all room of current user

    Future <List<dynamic>> getMyRooms() async {

      final response = await dio.get('/room/my-rooms');
      return response.data['data'];

    }
    
    String? get currentToken => _accessToken;
    Future <List<dynamic>> getRoomMessages(String roomId, {int page = 1}) async {
      final response = await dio.get("/room/$roomId/messages", queryParameters: {
        'page':page,
        'limit': 50,
      });
      return response.data['data']['messages'] ?? [];

    }

    // Save AES room locally
    Future<void> saveRoomKey(String roomId, String roomKey) async {
      await _storage.write(key: 'room_key_$roomId', value: roomKey);
    }
    // Retrieve Room AES Key locally
    Future<String?> getRoomKey(String roomId) async {
      return await _storage.read(key: 'room_key_$roomId');
    }
}