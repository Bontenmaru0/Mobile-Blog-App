import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/models/comment_model.dart';
import '../../state/comments_controller.dart';

class EditCommentPanel extends ConsumerStatefulWidget {
  final CommentModel comment;
  final String articleId;
  final String? imageId;
  final ScrollController scrollController;

  const EditCommentPanel({
    super.key,
    required this.comment,
    required this.articleId,
    this.imageId,
    required this.scrollController,
  });

  @override
  ConsumerState<EditCommentPanel> createState() => _EditCommentPanelState();
}

class _EditCommentPanelState extends ConsumerState<EditCommentPanel> {
  final TextEditingController _controller = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<File> selectedImages = [];
  List<String> existingImages = [];
  List<String> removedImages = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.comment.content ?? "";
    existingImages = List.from(widget.comment.images);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        selectedImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  void removeNewImage(File file) {
    setState(() {
      selectedImages.remove(file);
    });
  }

  void removeExistingImage(String url) {
    setState(() {
      removedImages.add(url);
      existingImages.remove(url);
    });
  }

  Future<void> submit() async {
    final controller = ref.read(commentsControllerProvider.notifier);
    await controller.updateComment(
      commentId: widget.comment.id,
      articleId: widget.articleId,
      imageId: widget.imageId,
      content: _controller.text.trim(),
      newFiles: selectedImages,
      removedImages: removedImages,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(commentsControllerProvider);

    final isLoading = state.maybeWhen(
      data: (data) => data.updateCommentLoadingById[widget.comment.id] ?? false,
      orElse: () => false,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // draggable handle
          Container(
            width: 50,
            height: 5,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Edit Comment",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
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

                  ElevatedButton.icon(
                    onPressed: isLoading ? null : pickImages,
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

                  if (existingImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: existingImages.map((img) {
                          return Stack(
                            key: ValueKey(img),
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                child: Image.network(img, fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 8,
                                top: 4,
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () => removeExistingImage(img),
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

                  if (selectedImages.isNotEmpty)
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: selectedImages.map((file) {
                          return Stack(
                            key: ValueKey(file.path),
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 100,
                                height: 100,
                                child: Image.file(file, fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 8,
                                top: 4,
                                child: GestureDetector(
                                  onTap: isLoading
                                      ? null
                                      : () => removeNewImage(file),
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

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text("CANCEL"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: isLoading ? null : submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text(isLoading ? "SAVING..." : "SAVE"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
