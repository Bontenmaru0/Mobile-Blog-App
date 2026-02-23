import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/comment_model.dart';
import '../../state/comments_controller.dart';
import '../../../../shared/widgets/image/comment_image_grid.dart';
import '../../../../core/constants/time_ago.dart';
import 'update_comment_panel.dart';
import '../../../profiles/presentation/widgets/profile_link.dart';
import '../../../auth/state/auth_controller.dart';

class CommentItem extends ConsumerWidget {
  final CommentModel comment;

  const CommentItem({super.key, required this.comment});

  void _openEditCommentPanel(BuildContext context) {
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
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsControllerProvider);
    final isEdited = comment.status == 'edited';
    final isLoading =
        state.value?.updateCommentLoadingById[comment.id] == true ||
        state.value?.deleteCommentLoadingById[comment.id] == true;

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
                              if (value == 'edit'){
                                _openEditCommentPanel(context);
                              }
                              if (value == 'delete') {
                                ref
                                    .read(commentsControllerProvider.notifier)
                                    .deleteComment(
                                      commentId: comment.id,
                                      removedImages: comment.images,
                                    );
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
