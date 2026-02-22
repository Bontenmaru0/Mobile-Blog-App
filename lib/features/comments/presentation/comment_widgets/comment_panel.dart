import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/comments_controller.dart';
import '../../../../core/enums/comment_context_type.dart';
import 'comment_list.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/state/auth_controller.dart';
import '../../../../shared/widgets/app_refresh.dart';

class CommentPanel extends ConsumerStatefulWidget {
  final String articleId;
  final String? imageId;
  final CommentContextType type;

  const CommentPanel({
    super.key,
    required this.articleId,
    this.imageId,
    required this.type,
  });

  @override
  ConsumerState<CommentPanel> createState() => _CommentPanelState();
}

class _CommentPanelState extends ConsumerState<CommentPanel> {
  final TextEditingController _controller = TextEditingController();
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(commentsControllerProvider.notifier)
          .fetchComments(articleId: widget.articleId, imageId: widget.imageId);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _postComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    try {
      await ref
          .read(commentsControllerProvider.notifier)
          .createComment(
            articleId: widget.articleId,
            imageId: widget.imageId,
            content: text,
            files: _selectedImages,
          );

      await ref
          .read(commentsControllerProvider.notifier)
          .fetchComments(articleId: widget.articleId, imageId: widget.imageId);

      _controller.clear();
      setState(() => _selectedImages.clear());
    } catch (e) {
      print(
        'ERROR POSTING COMMENT: $e',
      );
    }
  }

  Future<void> _refreshComments() async {
    await ref
        .read(commentsControllerProvider.notifier)
        .fetchComments(articleId: widget.articleId, imageId: widget.imageId);
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsControllerProvider);
    final authState = ref.watch(authControllerProvider); // AsyncValue<User?>

    return commentsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Failed to load comments',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (state) {
        final isPosting = state.insertCommentLoading;

        final comments = widget.type == CommentContextType.comment
            ? state.imageComments[widget.imageId] ?? []
            : state.articleComments[widget.articleId] ?? [];

        return Column(
          children: [
            // comment list with pull-to-refresh
            Expanded(
              child: AppRefreshWrapper(
                onRefresh: _refreshComments,
                child: state.contentLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (comments.isEmpty
                        ? const Center(child: Text("No comments yet"))
                        : CommentList(comments: comments)),
              ),
            ),
            // selected image previews
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => Stack(
                    children: [
                      Image.file(
                        _selectedImages[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImages.removeAt(i)),
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // footer input
            authState.when(
              loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (user) {
                if (user == null) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: const Border(top: BorderSide(color: Colors.grey)),
                    ),
                    child: const Text(
                      "You must log in to post a comment.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: const Border(top: BorderSide(color: Colors.grey)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          color: Colors.black,
                          onPressed: _pickImages,
                          icon: const Icon(Icons.image),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText: "Write a comment...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          color: Colors.black,
                          onPressed: isPosting ? null : _postComment,
                          icon: isPosting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}