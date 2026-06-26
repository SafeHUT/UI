class RoomsModel {
  final String id;
  final String token;
  final String name;
  final DateTime expiresAt;
  final DateTime createdAt;

  const RoomsModel({
    required this.id,
    required this.token,
    required this.name,
    required this.expiresAt,
    required this.createdAt,
  });

  factory RoomsModel.fromJson(Map<String, dynamic> json) {
    return RoomsModel(
      id: json['id'],
      token: json['token'], 
      name: json['name'], 
      expiresAt: DateTime.parse(json['expiresAt']), 
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}