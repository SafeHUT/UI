import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
        // The Interceptor: automatically attaches the token to every request
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

    // generate UID 
    Future <void> generateNewUser() async {
      try {

        final response = await dio.post('/user');
        final data = response.data['data'];
        
        _accessToken = data['accessToken'];
        currentUser = data['user'];

        await _storage.write(key: 'jwt_token', value: _accessToken);

      } catch(e) {

        print("Error generating user: $e");
        rethrow;
      }
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
    Future <Map<String, dynamic>> createRoom({
      String expiresIn = "1d"
    }) async {

      final response = await dio.post('/room/create',data: {
        "expires_in": expiresIn,
      });
      return response.data['data'];

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
}