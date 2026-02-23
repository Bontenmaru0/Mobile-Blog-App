import 'package:blog_app/features/profiles/presentation/create_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:blog_app/shared/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/blogs/presentation/home_screen.dart';
import 'features/profiles/presentation/profile_screen.dart';
import 'features/profiles/presentation/update_profile_screen.dart';

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (e) => const AuthWrapper());
          case '/login_screen':
            return MaterialPageRoute(builder: (e) => const LoginScreen());
          case '/register_screen':
            return MaterialPageRoute(builder: (e) => const RegisterScreen());
          case '/profile_screen':
            final args = settings.arguments as Map<String, dynamic>?;
            final userId = args?['userId'] as String?;
            return MaterialPageRoute(builder: (e) => ProfileScreen(userId: userId));
          case '/create_profile_screen':
            return MaterialPageRoute(builder: (e) => const CreateProfileScreen());
          case '/update_profile_screen':
            return MaterialPageRoute(builder: (e) => const UpdateProfileScreen());
          default:
            return MaterialPageRoute(builder: (e) => const AuthWrapper());
        }
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
