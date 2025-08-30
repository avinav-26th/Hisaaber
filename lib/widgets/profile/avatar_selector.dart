// In lib/widgets/profile/avatar_selector.dart

import 'package:flutter/material.dart';

class AvatarSelector extends StatelessWidget {
  // A list of all available avatar images
  final List<String> avatarPaths = List.generate(6, (index) => 'assets/avatars/${index + 1}.png');

  final int selectedAvatarId;
  final Function(int) onAvatarSelected;

  AvatarSelector({
    super.key,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: avatarPaths.length,
        itemBuilder: (context, index) {
          final avatarId = index + 1;
          final isSelected = avatarId == selectedAvatarId;

          return GestureDetector(
            onTap: () => onAvatarSelected(avatarId),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Theme.of(context).primaryColor, width: 3)
                    : null,
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(avatarPaths[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}