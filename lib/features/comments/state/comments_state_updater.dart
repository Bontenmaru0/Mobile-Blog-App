import '../../../core/models/comment_model.dart';
import 'comments_state.dart';

class CommentsStateUpdater {
  static CommentModel? findCommentById(
    CommentsState current,
    String commentId,
  ) {
    for (final list in current.articleComments.values) {
      for (final c in list) {
        if (c.id == commentId) return c;
      }
    }
    for (final list in current.imageComments.values) {
      for (final c in list) {
        if (c.id == commentId) return c;
      }
    }
    return null;
  }

  static CommentsState replaceCommentById(
    CommentsState current,
    String commentId,
    CommentModel replacement,
  ) {
    final articleComments = <String, List<CommentModel>>{};
    current.articleComments.forEach((key, list) {
      articleComments[key] = list
          .map((c) => c.id == commentId ? replacement : c)
          .toList();
    });

    final imageComments = <String, List<CommentModel>>{};
    current.imageComments.forEach((key, list) {
      imageComments[key] = list
          .map((c) => c.id == commentId ? replacement : c)
          .toList();
    });

    return current.copyWith(
      articleComments: articleComments,
      imageComments: imageComments,
    );
  }

  static CommentsState removeCommentById(CommentsState current, String commentId) {
    final articleComments = <String, List<CommentModel>>{};
    current.articleComments.forEach((key, list) {
      articleComments[key] = list.where((c) => c.id != commentId).toList();
    });

    final imageComments = <String, List<CommentModel>>{};
    current.imageComments.forEach((key, list) {
      imageComments[key] = list.where((c) => c.id != commentId).toList();
    });

    return current.copyWith(
      articleComments: articleComments,
      imageComments: imageComments,
    );
  }

  static CommentModel mergeUpdatedComment({
    required CommentModel existing,
    required CommentModel server,
    String? submittedContent,
    required List<String> removedImages,
  }) {
    final mergedImages = server.images.isNotEmpty
        ? server.images
        : existing.images.where((img) => !removedImages.contains(img)).toList();

    return CommentModel(
      id: existing.id,
      articleId: existing.articleId,
      imageId: existing.imageId,
      userId: existing.userId,
      authorName: existing.authorName,
      parentId: existing.parentId,
      content: submittedContent ?? server.content ?? existing.content,
      status: server.status ?? 'edited',
      createdAt: existing.createdAt,
      updatedAt: server.updatedAt ?? DateTime.now(),
      depth: existing.depth,
      replyCount: server.replyCount,
      totalArticleComments: server.totalArticleComments,
      totalImageComments: server.totalImageComments,
      images: mergedImages,
    );
  }

  static CommentModel buildOptimisticUpdatedComment({
    required CommentModel existing,
    String? submittedContent,
    required List<String> removedImages,
  }) {
    return CommentModel(
      id: existing.id,
      articleId: existing.articleId,
      imageId: existing.imageId,
      userId: existing.userId,
      authorName: existing.authorName,
      parentId: existing.parentId,
      content: submittedContent ?? existing.content,
      status: 'edited',
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      depth: existing.depth,
      replyCount: existing.replyCount,
      totalArticleComments: existing.totalArticleComments,
      totalImageComments: existing.totalImageComments,
      images: existing.images.where((img) => !removedImages.contains(img)).toList(),
    );
  }
}
