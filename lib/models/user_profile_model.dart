// In lib/models/user_profile_model.dart

import 'package:hive/hive.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 2) // Using a new unique typeId
class UserProfileModel {
  @HiveField(0)
  String name;

  @HiveField(1)
  int avatarId; // We'll use an ID (e.g., 1 to 6) to represent the chosen avatar

  UserProfileModel({
    required this.name,
    required this.avatarId,
  });
}