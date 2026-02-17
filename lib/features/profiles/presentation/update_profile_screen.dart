import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/state/auth_controller.dart';
import '../state/profiles_controller.dart';
import '../../../core/utils/app_snackbar.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState
    extends ConsumerState<UpdateProfileScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isUpdating = false;
  String? errorMessage;
 
  final ImagePicker _picker = ImagePicker();
  String? originalAvatarUrl; // DB avatar URL
  File? selectedImage;        // new picked file
  bool isAvatarRemoved = false; // tracks if user removed avatar


  @override
  void initState() {
    super.initState();
    // pre-fill the fields from existing profile
    final profile = ref.read(profilesControllerProvider).asData?.value;
    if (profile != null) {
      fullNameController.text = profile.fullName;
      nickNameController.text = profile.nickname;
      bioController.text = profile.bio;
      originalAvatarUrl = profile.avatarUrl;
    }
  }

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
        isAvatarRemoved = false;
      });
    }
  }

  void _removeAvatar() {
    setState(() {
      selectedImage = null;
      isAvatarRemoved = true;
    });
  }

  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).value;

    if (user == null) {
      setState(() {
        errorMessage = "User not authenticated";
      });
      return;
    }

    setState(() {
      isUpdating = true;
      errorMessage = null;
    });

    try {
      // if both selectedImage & originalAvatarUrl are null => delete avatar
      final deleteAvatar = isAvatarRemoved && selectedImage == null;

      await ref.read(profilesControllerProvider.notifier).updateProfile(
        id: user.id,
        fullName: fullNameController.text.trim(),
        nickName: nickNameController.text.trim(),
        bio: bioController.text.trim(),
        avatarFile: selectedImage,
        deleteOldAvatar: deleteAvatar,
      );

      if (!mounted) return;

      AppSnackBar.show(
        context,
        "Profile updated! 🚀",
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
          isUpdating = false;
        });
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await ref.read(authControllerProvider.notifier).logout();
      // ignore: use_build_context_synchronously
      AppSnackBar.show( context, "Logged out successful! See you later!👋", type: SnackType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profilesControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: profileState.when(
          data: (profile) {
            final nickname = profile?.nickname.isNotEmpty == true
                ? "@${profile!.nickname}'s Profile"
                : "@ronin";
            return Text(nickname);
          },
          loading: () => const Text("Loading..."),
          error: (e, st) => const Text("Profile"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
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
                    "Update Your Profile",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Text(
                    "You may modify your profile details and save changes.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 194, 0, 0),
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
                                : (!isAvatarRemoved && originalAvatarUrl != null && originalAvatarUrl!.isNotEmpty)
                                    ? NetworkImage(originalAvatarUrl!)
                                    : null,
                            child: selectedImage == null &&
                                    (isAvatarRemoved || originalAvatarUrl == null || originalAvatarUrl!.isEmpty)
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
                        // delete avatar button
                        if (selectedImage != null || (!isAvatarRemoved && originalAvatarUrl != null && originalAvatarUrl!.isNotEmpty))
                          TextButton.icon(
                            onPressed: _removeAvatar,
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            label: const Text(
                              "Remove Avatar",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // full name
                  TextFormField(
                    controller: fullNameController,
                    maxLength: 50,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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

                  // nickname / tag
                  TextFormField(
                    controller: nickNameController,
                    maxLength: 10,
                    onChanged: (value) {
                      final lower = value.toLowerCase();
                      if (value != lower) {
                        nickNameController.value = TextEditingValue(
                          text: lower,
                          selection: TextSelection.collapsed(offset: lower.length),
                        );
                      }
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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

                  // bio
                  TextFormField(
                    controller: bioController,
                    maxLines: 3,
                    maxLength: 500,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
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
                    onPressed: isUpdating ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Update Profile",
                            style: TextStyle(color: Colors.white),
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
