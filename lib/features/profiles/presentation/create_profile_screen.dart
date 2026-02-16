import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../state/profiles_controller.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../shared/widgets/nav_user_menu.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState
    extends ConsumerState<CreateProfileScreen> {
  final TextEditingController fullNameController =
      TextEditingController();
  final TextEditingController bioController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isCreating = false;
  String? errorMessage;

  @override
  void dispose() {
    fullNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user =
        ref.read(authControllerProvider).value;

    if (user == null) {
      setState(() {
        errorMessage = "User not authenticated";
      });
      return;
    }

    setState(() {
      isCreating = true;
      errorMessage = null;
    });

    try {
      await ref
          .read(profilesControllerProvider.notifier)
          .createProfile(
            id: user.id,
            fullName: fullNameController.text.trim(),
            bio: bioController.text.trim(),
          );

      if (!mounted) return;

      AppSnackBar.show(
        context,
        "Profile created! 🚀",
        type: SnackType.success,
      );

      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(
            title: const Text('Modern Samurai'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: NavUserMenu(),
              ),
            ],
          ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width:
                MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.zero,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Create Your Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text(
                    "Create your identity to begin blogging.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (errorMessage != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 12),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(
                              255, 194, 0, 0),
                          fontSize: 13,
                        ),
                      ),
                    ),

                  // FULL NAME
                  TextFormField(
                    controller: fullNameController,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Full name is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.zero,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black),
                        borderRadius:
                            BorderRadius.zero,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black,
                            width: 2),
                        borderRadius:
                            BorderRadius.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // BIO
                  TextFormField(
                    controller: bioController,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Bio is required";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Bio",
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.zero,
                      ),
                      enabledBorder:
                          OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black),
                        borderRadius:
                            BorderRadius.zero,
                      ),
                      focusedBorder:
                          OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.black,
                            width: 2),
                        borderRadius:
                            BorderRadius.zero,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BUTTON
                  ElevatedButton(
                    onPressed:
                        isCreating ? null : submitProfile,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black,
                      shape:
                          const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.zero,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                              vertical: 14),
                    ),
                    child: isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Create Profile",
                            style: TextStyle(
                                color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
