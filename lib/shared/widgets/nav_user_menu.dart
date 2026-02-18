import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../../features/profiles/state/profiles_controller.dart';
import '../../core/utils/app_snackbar.dart';

class NavUserMenu extends ConsumerWidget {
  const NavUserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // listen for auth state changes to navigate after logout
    ref.listen<AsyncValue<User?>>(authControllerProvider, (previous, next) {
      if (previous?.value != null && next.value == null) {
        // user just logged out
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        AppSnackBar.show( context, "Logged out successful! See you later!👋", type: SnackType.success);
      }
    });

    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.pushNamed(context, '/register_screen');
              },
            ),
            const SizedBox(width: 4),
            const Text("|", style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.pushNamed(context, '/login_screen');
              },
            ),
          ],
        );
      },
      data: (user) {
        if (user == null) {
          return Row(
            mainAxisSize: MainAxisSize.min, // important for AppBar
            children: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  Navigator.pushNamed(context, '/register_screen');
                },
              ),
              const SizedBox(width: 4),
              const Text("|", style: TextStyle(color: Colors.grey)),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.login),
                onPressed: () {
                  Navigator.pushNamed(context, '/login_screen');
                },
              ),
            ],
          );
        }

        return _LoggedInAvatar(user: user);
      },
    );

  }
}

class _LoggedInAvatar extends ConsumerWidget {
  final User user;

  const _LoggedInAvatar({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profilesControllerProvider);

    return profileState.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => _defaultAvatar(user),
      data: (profile) {
        final avatarUrl = profile?.avatarUrl;

        return PopupMenuButton<String>(
          offset: const Offset(0, 45),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                Navigator.pushNamed(context, '/profile_screen');
                break;
              case 'logout':
                ref.read(authControllerProvider.notifier).logout();
                break;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'profile',
              child: Text('My Profile'),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                RotationTransition(turns: animation, child: child),
            child: Stack(
              key: ValueKey(avatarUrl ?? 'default-${user.id}'),
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.black,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(
                          user.email?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
                const Positioned(
                  bottom: -2,
                  right: -2,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _defaultAvatar(User user) => CircleAvatar(
        radius: 18,
        backgroundColor: Colors.black,
        child: Text(
          user.email?.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(color: Colors.white),
        ),
      );
}



