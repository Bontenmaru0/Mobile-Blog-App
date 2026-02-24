import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/comment_model.dart';
import '../../state/comments_controller.dart';
import '../../../../shared/widgets/image/comment_image_grid.dart';
import '../../../../core/constants/time_ago.dart';
import '../../../../core/utils/app_snackbar.dart';
import 'update_comment_panel.dart';
import '../../../profiles/presentation/widgets/profile_link.dart';
import '../../../auth/state/auth_controller.dart';

class CommentItem extends ConsumerWidget {
  final CommentModel comment;
  final String articleId;
  final String? imageId;

  const CommentItem({
    super.key,
    required this.comment,
    required this.articleId,
    this.imageId,
  });

  void _openEditCommentPanel(BuildContext context) {
    final parentContext = context;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.zero),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return EditCommentPanel(
              comment: comment,
              articleId: articleId,
              imageId: imageId,
              scrollController: scrollController,
              parentContext: parentContext,
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteComment(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(commentsControllerProvider.notifier)
                    .deleteComment(
                      commentId: comment.id,
                      articleId: articleId,
                      imageId: imageId,
                      removedImages: comment.images,
                    );

                if (!context.mounted) return;
                AppSnackBar.show(
                  context,
                  "Comment deleted successfully!\u{1F5D1}\uFE0F",
                  type: SnackType.success,
                );
              } catch (_) {}
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsControllerProvider);
    final isEdited = comment.status == 'edited';
    final isLoading =
        state.updateCommentLoadingById[comment.id] == true ||
        state.deleteCommentLoadingById[comment.id] == true;

    return Stack(
      children: [
        // Main comment container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // author
                  ProfileLink(
                    userId: comment.userId,
                    displayName: comment.authorName,
                    textColor: Colors.black,
                  ),

                  Row(
                    children: [
                      if (isEdited)
                        Text(
                          "edited",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(width: 4),

                      // Check if current user owns the comment
                      Builder(
                        builder: (context) {
                          final authState = ref.watch(authControllerProvider);

                          // handle AsyncValue<User?> safely
                          final isOwner = authState.when(
                            data: (user) => user?.id == comment.userId,
                            loading: () => false,
                            error: (e, st) => false,
                          );

                          if (!isOwner) {
                            // maintain spacing even if not owner
                            return const SizedBox(width: 18);
                          }

                          return PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert, size: 18),
                            onSelected: (value) {
                              if (isLoading) return;
                              if (value == 'edit') {
                                _openEditCommentPanel(context);
                              }
                              if (value == 'delete') {
                                _confirmDeleteComment(context, ref);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              /// images
              if (comment.images.isNotEmpty) ...[
                const SizedBox(height: 2),
                CommentImageGrid(images: comment.images),
              ],

              /// content
              if (comment.content != null &&
                  comment.content!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(comment.content!, style: const TextStyle(fontSize: 14)),
              ],

              /// footer
              const SizedBox(height: 2),
              Text(
                timeAgo(comment.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        if (isLoading)
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
}
