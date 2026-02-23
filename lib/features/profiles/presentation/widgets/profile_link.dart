// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/profiles_controller.dart';
import '../../../../core/utils/app_snackbar.dart';

class ProfileLink extends ConsumerWidget {
  final String userId;
  final String displayName;
  final Color? textColor;

  const ProfileLink({
    super.key,
    required this.userId,
    required this.displayName,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        try {
          // fetch public profile
          final profile = await ref
              .read(profilesControllerProvider.notifier)
              .fetchProfile(userId: userId);

          if (profile == null) {
            AppSnackBar.show(context, "Profile not found",
                type: SnackType.error);
            return;
          }

          // open profile screen
          Navigator.pushNamed(context, '/profile_screen',
              arguments: {'userId': userId});
        } catch (e) {
          AppSnackBar.show(context, "Failed to load profile",
              type: SnackType.error);
        }
      },
      child: Text(
        displayName,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}