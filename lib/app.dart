import 'package:blog_app/features/profiles/presentation/create_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:blog_app/shared/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/home_screen.dart';
import 'features/profiles/presentation/profile_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppView();
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern Samurai',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login_screen': (context) => const LoginScreen(),
        '/register_screen': (context) => const RegisterScreen(),
        '/profile_screen': (context) => const ProfileScreen(),
        '/create_profile_screen': (context) => const CreateProfileScreen(),
      },
    );
  }
}

// initial view
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // return const LoginScreen();
    return const HomeScreen();
  }
}
