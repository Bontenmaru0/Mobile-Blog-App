import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/comment_model.dart';
import '../../../comments/state/comments_controller.dart';
import '../image_widgets/app_image_grid.dart';
import '../image_widgets/image_gallery_page.dart';
import '../../../../core/constants/time_ago.dart';

class CommentItem extends ConsumerWidget {
  final CommentModel comment;

  const CommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsControllerProvider);
    final isEdited = comment.updatedAt != null;

    final isUpdating =
        state.value?.updateCommentLoadingById[comment.id] ?? false;

    return Stack(
      children: [
        // main comment container
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.zero,
            border: Border.all(color: Colors.black)
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (isEdited)
                    Text(
                      "edited",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              AppImageGrid(
                images: comment.images,
                onImageTap: (imageUrl, index) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageGalleryPage(
                        images: comment.images,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
              ),

              if (comment.content != null && comment.content!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  comment.content!,
                  style: const TextStyle(fontSize: 14),
                ),
              ],

              const SizedBox(height: 6),

              // Footer
              Text(
                timeAgo(comment.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        if (isUpdating)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
