import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_controller.dart';
import '../../../core/utils/app_snackbar.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isRegistering = false;
  String? registrationErrorMessage;

  bool get passwordsMatch {
    final String passwordValue = passwordController.text;
    final String verifyPasswordValue = verifyPasswordController.text;

    if (passwordValue.isEmpty || verifyPasswordValue.isEmpty) {
      return true;
    }

    return passwordValue == verifyPasswordValue;
  }

  bool get shouldShowPasswordMismatchError {
    final String passwordValue = passwordController.text;
    final String verifyPasswordValue = verifyPasswordController.text;

    return passwordValue.isNotEmpty &&
        verifyPasswordValue.isNotEmpty &&
        passwordValue != verifyPasswordValue;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    verifyPasswordController.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!passwordsMatch) return;

    setState(() {
      isRegistering = true;
      registrationErrorMessage = null;
    });

    try {
      final registeredUser = await ref
          .read(authControllerProvider.notifier)
          .register(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

      if (!mounted) return;

      if (registeredUser != null) {
        Navigator.pop(context);

        AppSnackBar.show( context, "Welcome aboard 👋", type: SnackType.success,);
      }
    } catch (error) {
      setState(() {
        registrationErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isRegistering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.zero,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Modern Samurai",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text(
                    "Begin your discipline",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // password mismatch error
                  if (shouldShowPasswordMismatchError)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        "Passwords do not match",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  if (registrationErrorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        registrationErrorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 194, 0, 0),
                          fontSize: 13,
                        ),
                      ),
                    ),

                  // email Field
                  TextFormField(
                    controller: emailController,
                    onChanged: (_) => setState(() {}),
                    validator: (String? emailValue) {
                      if (emailValue == null || emailValue.trim().isEmpty) {
                        return "Email is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // password Field
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    validator: (String? passwordValue) {
                      if (passwordValue == null || passwordValue.isEmpty) {
                        return "Password is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // verify Password Field
                  TextFormField(
                    controller: verifyPasswordController,
                    obscureText: true,
                    onChanged: (_) => setState(() {}),
                    validator: (String? verifyPasswordValue) {
                      if (verifyPasswordValue == null || verifyPasswordValue.isEmpty) {
                        return "Verify password is required";
                      }

                      if (verifyPasswordValue != passwordController.text) {
                        return "Passwords do not match";
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Verify Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // button
                  ElevatedButton(
                    onPressed: isRegistering || !passwordsMatch
                        ? null
                        : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isRegistering
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Begin",
                            style:
                                TextStyle(color: Colors.white),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/login_screen'),
                        child: const Text(
                          "Already have an account?",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("|", style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false),
                        child: const Text(
                          "Back to Blog",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
