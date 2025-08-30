// In lib/widgets/profile/edit_profile_modal.dart

import 'package:flutter/material.dart';
import 'package:hisaaber_v1/api_services/database_service.dart';
import 'package:hisaaber_v1/models/user_profile_model.dart';
import 'package:hisaaber_v1/widgets/primary_button.dart';
import 'package:hisaaber_v1/widgets/profile/avatar_selector.dart';
import 'package:provider/provider.dart';

import '../../providers/profile_provider.dart';

class EditProfileModal extends StatefulWidget {
  const EditProfileModal({super.key});

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatarId = 1; // Default to the first avatar
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _databaseService.getUserProfile();
    if (profile != null) {
      _nameController.text = profile.name;
      _selectedAvatarId = profile.avatarId;
    }
    setState(() => _isLoading = false);
  }

  void _onSubmit() async {
    // 1. Prepare data (no context used)
    final newProfile = UserProfileModel(
      name: _nameController.text.trim(),
      avatarId: _selectedAvatarId,
    );

    // 2. Perform the first async operation
    await _databaseService.saveUserProfile(newProfile);

    // 3. First safety check
    if (!mounted) return;

    // 4. Perform the second async operation (which uses context)
    await context.read<ProfileProvider>().loadProfile();

    // 5. Final safety check before navigating
    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Large display of the currently selected avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/avatars/$_selectedAvatarId.png'),
                      ),
                      const SizedBox(height: 24),
                      // The horizontal avatar selector
                      AvatarSelector(
                        selectedAvatarId: _selectedAvatarId,
                        onAvatarSelected: (newId) {
                          setState(() => _selectedAvatarId = newId);
                        },
                      ),
                      const SizedBox(height: 24),
                      // Name input field
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Submit button
                      PrimaryButton(text: 'Submit', onPressed: _onSubmit),
                    ],
                  ),
          ),
    );
  }
}