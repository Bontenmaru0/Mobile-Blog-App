import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(Supabase.instance.client);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>(
  (ref) => AuthController(ref.read(authServiceProvider)),
);

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthController(this._authService) : super(AsyncValue.data(_authService.currentUser));

   Future<User?> login(String email, String password) async {
    try {
      final res = await _authService.signIn(
        email: email,
        password: password,
      );

      state = AsyncValue.data(res.user);
      return res.user;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong';
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      final res = await _authService.signUp(
        email: email,
        password: password,
      );

      state = AsyncValue.data(res.user);
      return res.user;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Something went wrong';
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      // small delay so user sees the animation
      await Future.delayed(const Duration(milliseconds: 400));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error('Logout failed', st);
    }
  }
}
