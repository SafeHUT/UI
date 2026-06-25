import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/user_model.dart';

class UserService {
  Future<UserModel> getCurrentUser() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/user_demo_data.json'
    );
    final List<dynamic> data = jsonDecode(jsonString);
    return UserModel.fromJson(data.first);
  }
}
