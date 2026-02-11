import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/state/auth_controller.dart';

class NavUserMenu extends ConsumerWidget {
  const NavUserMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => const Icon(Icons.error),
      data: (user) {
        if (user == null) {
          return IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.pushNamed(context, '/login_screen');
            },
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
    return PopupMenuButton<String>(
      offset: const Offset(0, 45),
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'posts':
            Navigator.pushNamed(context, '/my-posts');
            break;
          case 'logout':
            ref.read(authControllerProvider.notifier).logout();
            break;
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.black,
            child: Text(
              user.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(color: Colors.white),
            ),
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
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Text('My Profile'),
        ),
        const PopupMenuItem(
          value: 'posts',
          child: Text('My Posts'),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Text('Logout'),
        ),
      ],
    );
  }
}

