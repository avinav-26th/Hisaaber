// In lib/providers/profile_provider.dart
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/api_services/database_service.dart';
import 'package:hisaaber_v1/models/user_profile_model.dart';

class ProfileProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  UserProfileModel? _userProfile;
  bool _isLoading = false;

  UserProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  ProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    _userProfile = await _databaseService.getUserProfile();
    _isLoading = false;
    notifyListeners();
  }
}