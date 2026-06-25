
class UserModel {
  final String id;
  final String anonymousId;
  final String name;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.anonymousId,
    required this.name,
    required this.createdAt,
  });
  
  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      anonymousId: json['anonymousId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}