import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../state/blogs_controller.dart';
import '../../../profiles/state/profiles_controller.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/models/blog_model.dart';
import '../../../../core/models/image_model.dart';
import '../../../../core/models/upload_file.dart';

class UpdateArticleScreen extends ConsumerStatefulWidget {
  final ArticleModel article;

  const UpdateArticleScreen({super.key, required this.article});

  @override
  ConsumerState<UpdateArticleScreen> createState() =>
      _UpdateArticleScreenState();
}

class _UpdateArticleScreenState extends ConsumerState<UpdateArticleScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String? errorMessage;

  final ImagePicker _picker = ImagePicker();
  List<UploadFile> selectedImages = [];

  List<ImageModel> existingImages = [];
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
      final picked = <UploadFile>[];
      for (final image in images) {
        picked.add(UploadFile(name: image.name, bytes: await image.readAsBytes()));
      }
      setState(() {
        selectedImages.addAll(picked);
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  void removeExistingImage(int index) {
    final removed = existingImages[index];
    setState(() {
      removedImages.add(removed.imageUrl);
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

      if (!mounted) return;

      AppSnackBar.show(
        context,
        "Article updated successfully!✏️",
        type: SnackType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
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
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      "Current images (kept unless removed)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                if (existingImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: existingImages.map((img) {
                        return Stack(
                          key: ValueKey(img.id),
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              height: 100,
                              child: Image.network(
                                img.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    removedImages.add(img.imageUrl);
                                    existingImages.removeWhere(
                                      (e) => e.id == img.id,
                                    );
                                  });
                                },
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
                      }).toList(),
                    ),
                  ),

                if (existingImages.isNotEmpty && selectedImages.isNotEmpty)
                  const SizedBox(height: 10),

                if (selectedImages.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      "New images (to upload)",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                if (selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: selectedImages.map((file) {
                          return Stack(
                            key: ValueKey('${file.name}-${file.bytes.length}'),
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                child: Image.memory(
                                  file.bytes,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                              ),
                            Positioned(
                              right: 8,
                              top: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedImages.remove(file);
                                  });
                                },
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
                      }).toList(),
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
