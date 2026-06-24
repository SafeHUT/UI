
class UserModel {
  final String id;
  final String anonymousId;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.anonymousId,
    required this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
      id: json['id'],
      anonymousId: json['anonymousId'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}