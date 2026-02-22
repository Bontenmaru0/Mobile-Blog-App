import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../comments/state/comments_controller.dart';
import '../../../../core/enums/comment_context_type.dart';
import 'comment_list.dart';

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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(commentsControllerProvider.notifier).fetchComments(
            articleId: widget.articleId,
            imageId: widget.imageId,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(commentsControllerProvider);

    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Failed to load comments',
          style: TextStyle(color: Colors.red[400]),
        ),
      ),
      data: (state) {
        final comments = widget.type == CommentContextType.image
            ? state.imageComments[widget.imageId] ?? []
            : state.articleComments[widget.articleId] ?? [];

        if (comments.isEmpty) {
          return const Center(child: Text("No comments yet."));
        }

        return CommentList(comments: comments);
      },
    );
  }
}