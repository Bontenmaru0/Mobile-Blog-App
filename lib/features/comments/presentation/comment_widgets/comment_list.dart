import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/comment_model.dart';
import '../../state/comments_controller.dart';
import 'comment_item.dart';

class CommentList extends ConsumerWidget {
  final List<CommentModel> comments;

  const CommentList({
    super.key,
    required this.comments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentsControllerProvider);

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: comments.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final comment = comments[index];

        final isDeleting =
            state.value?.deleteCommentLoadingById[comment.id] ?? false;
        final isUpdating =
            state.value?.updateCommentLoadingById[comment.id] ?? false;

        return Stack(
          children: [
            CommentItem(comment: comment),
            if (isDeleting || isUpdating)
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
      },
    );
  }
}