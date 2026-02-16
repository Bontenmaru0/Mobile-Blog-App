import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../state/profiles_controller.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../shared/widgets/nav_user_menu.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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

  final TextEditingController nickNameController =
      TextEditingController();

  final TextEditingController bioController =
      TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isCreating = false;
  String? errorMessage;

  String? avatarPath;

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  @override
  void dispose() {
    fullNameController.dispose();
    nickNameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        avatarPath = image.path;
      });
    }
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
            nickName: nickNameController.text.trim(),
            bio: bioController.text.trim(),
            avatarFile: selectedImage,
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
      appBar: AppBar(
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

                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: selectedImage != null
                                ? FileImage(selectedImage!)
                                : null,
                            child: selectedImage == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 32,
                                    color: Colors.black,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Upload Avatar",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // full name
                  TextFormField(
                    controller: fullNameController,
                    maxLength: 50, // ✅ ADDED
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Full name is required";
                      }
                      if (value.trim().length > 50) {
                        return "Max 50 characters only";
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

                  // nickname / tag
                  TextFormField(
                    controller: nickNameController,
                    maxLength: 10,
                    onChanged: (value) {
                      final lower = value.toLowerCase();
                      if (value != lower) {
                        nickNameController.value =
                            TextEditingValue(
                          text: lower,
                          selection:
                              TextSelection.collapsed(
                                  offset: lower.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Tag/Nickname is required";
                      }
                      if (value.contains(" ")) {
                        return "No spaces allowed";
                      }
                      if (value.length > 10) {
                        return "Max 10 characters only";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: "Tag / NickName",
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

                  // bio
                  TextFormField(
                    controller: bioController,
                    maxLines: 3,
                    maxLength: 500, // ✅ ADDED
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Bio is required";
                      }
                      if (value.trim().length > 500) {
                        return "Max 500 characters only";
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

                  // button
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
