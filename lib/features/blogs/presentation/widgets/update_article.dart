import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../blogs/state/blogs_controller.dart';
import '../../../profiles/state/profiles_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/models/blogs_model.dart';

class UpdateArticleScreen extends ConsumerStatefulWidget {
  final Article article;

  const UpdateArticleScreen({super.key, required this.article});

  @override
  ConsumerState<UpdateArticleScreen> createState() => _UpdateArticleScreenState();
}

class _UpdateArticleScreenState extends ConsumerState<UpdateArticleScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? errorMessage;

  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  List<String> existingImages = [];
  List<String> removedImages = [];

  @override
  void initState() {
    super.initState();
    titleController.text = widget.article.title;
    contentController.text = widget.article.content;

    existingImages = List.from(widget.article.images);
  }

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void removeExistingImage(int index) {
    setState(() {
      removedImages.add(existingImages[index]);
      existingImages.removeAt(index);
    });
  }

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty) {
      setState(() {
        errorMessage = "Title and content are required.";
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    try {
      await ref
          .read(blogsControllerProvider.notifier)
          .updateArticle(
            id: widget.article.id,
            title: titleController.text.trim(),
            content: contentController.text.trim(),
            files: selectedImages,
            removedImages: removedImages,
          );

      await ref
          .read(blogsControllerProvider.notifier)
          .fetchArticles(page: 1, limit: 5);

      if (!mounted) return;

      AppSnackBar.show(
        context,
        "Article updated successfully!✏️",
        type: SnackType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = "Article update failed.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profilesControllerProvider).asData?.value;
    final blogState = ref.watch(blogsControllerProvider);
    final isLoading =
        blogState.updateArticleLoadingById[widget.article.id] ?? false;

    return Scaffold(
      appBar: AppBar(),

      resizeToAvoidBottomInset: true,

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Update your thoughts",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Share your latest insights, stories, or ideas with your audience.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),

                const SizedBox(height: 24),

                /// ERROR MESSAGE
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

                /// TITLE
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
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

                /// CONTENT
                TextField(
                  controller: contentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: "Content",
                    border: OutlineInputBorder(borderRadius: BorderRadius.zero),
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

                const SizedBox(height: 16),

                /// IMAGE PICKER
                ElevatedButton.icon(
                  onPressed: pickImages,
                  icon: const Icon(Icons.image),
                  label: const Text("Add Images"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// IMAGE PREVIEW
                if (existingImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: existingImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              height: 100,
                              child: Image.network(
                                existingImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 4,
                              child: GestureDetector(
                                onTap: () => removeExistingImage(index),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black,
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                if (selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              height: 100,
                              child: Image.file(
                                selectedImages[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 4,
                              child: GestureDetector(
                                onTap: () => removeImage(index),
                                child: const CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.black,
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                /// METADATA
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Publishing as ${profile?.fullName ?? 'You'}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      /// FOOTER
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          // decoration: const BoxDecoration(
          //   border: Border(
          //     top: BorderSide(color: Colors.black),
          //   ),
          // ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(isLoading ? "SAVING..." : "SAVE"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text("CANCEL"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
