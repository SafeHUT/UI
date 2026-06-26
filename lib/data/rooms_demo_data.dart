import 'package:ui/models/rooms_model.dart';

final List<RoomsModel> demoRooms = [
  RoomsModel(
    id: "1",
    token: "tty",
    name: "Friends",
    expiresAt: DateTime.now().add(
      const Duration(days: 7),
    ),
    createdAt: DateTime.now(),
  ),
  RoomsModel(
    id: "2",
    token: "xtty",
    name: "",
    expiresAt: DateTime.now().add(
      const Duration(days: 1),
    ),
    createdAt: DateTime.now(),
  ),
];