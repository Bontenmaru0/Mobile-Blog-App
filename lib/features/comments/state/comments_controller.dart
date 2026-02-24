import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comments_service.dart';
import 'comments_state.dart';
import 'comments_state_updater.dart';
import 'dart:io';

final commentsServiceProvider = Provider((ref) => CommentsService());

final commentsControllerProvider =
    NotifierProvider<CommentsController, CommentsState>(CommentsController.new);

class CommentsController extends Notifier<CommentsState> {
  late final CommentsService _service;

  @override
  CommentsState build() {
    _service = ref.read(commentsServiceProvider);
    return const CommentsState();
  }

  // fetch either article | specific image
  Future<void> fetchComments({
    required String articleId,
    String? imageId,
  }) async {
    final current = state;
    state = current.copyWith(contentLoading: true, contentError: null);

    try {
      final comments = imageId != null
          ? await _service.fetchImageComments(
              articleId: articleId,
              imageId: imageId,
            )
          : await _service.fetchArticleComments(articleId: articleId);

      final latest = state;

      if (imageId != null) {
        state = latest.copyWith(
          imageComments: {...latest.imageComments, imageId: comments},
          contentLoading: false,
        );
      } else {
        state = latest.copyWith(
          articleComments: {...latest.articleComments, articleId: comments},
          contentLoading: false,
        );
      }
    } catch (e) {
      final latest = state;
      state = latest.copyWith(contentLoading: false, contentError: e.toString());
    }
  }

  // create
  Future<void> createComment({
    required String articleId,
    String? imageId,
    String? content,
    String? parentId,
    required List<File> files,
  }) async {
    final current = state;
    state = current.copyWith(insertCommentLoading: true, insertCommentError: null);

    try {
      final newComment = await _service.createComment(
        articleId: articleId,
        content: content,
        imageId: imageId,
        parentId: parentId,
        files: files,
      );

      final latest = state;

      if (imageId != null) {
        final existing = latest.imageComments[imageId] ?? [];

        state = latest.copyWith(
          imageComments: {
            ...latest.imageComments,
            imageId: [newComment, ...existing],
          },
          insertCommentLoading: false,
        );
      } else {
        final existing = latest.articleComments[articleId] ?? [];

        state = latest.copyWith(
          articleComments: {
            ...latest.articleComments,
            articleId: [newComment, ...existing],
          },
          insertCommentLoading: false,
        );
      }
    } catch (e) {
      final latest = state;
      state = latest.copyWith(
        insertCommentLoading: false,
        insertCommentError: e.toString(),
      );
    }
  }

  // update
  Future<void> updateComment({
    required String commentId,
    required String articleId,
    String? imageId,
    String? content,
    required List<File> newFiles,
    required List<String> removedImages,
  }) async {
    final current = state;
    state = current.copyWith(
      updateCommentLoadingById: {
        ...current.updateCommentLoadingById,
        commentId: true,
      },
      updateCommentError: null,
    );

    final afterLoading = state;
    final existing = CommentsStateUpdater.findCommentById(afterLoading, commentId);
    final originalSnapshot = existing;
    if (existing != null) {
      state = CommentsStateUpdater.replaceCommentById(
        afterLoading,
        commentId,
        CommentsStateUpdater.buildOptimisticUpdatedComment(
          existing: existing,
          submittedContent: content,
          removedImages: removedImages,
        ),
      );
    }

    try {
      final updatedComment = await _service.updateComment(
        commentId: commentId,
        content: content,
        newFiles: newFiles,
        removedImages: removedImages,
        articleId: articleId,
        imageId: imageId,
      );

      final latest = state;
      final latestExisting = CommentsStateUpdater.findCommentById(
        latest,
        commentId,
      );
      final merged = latestExisting != null
          ? CommentsStateUpdater.mergeUpdatedComment(
              existing: latestExisting,
              server: updatedComment,
              submittedContent: content,
              removedImages: removedImages,
            )
          : updatedComment;

      state = CommentsStateUpdater.replaceCommentById(latest, commentId, merged).copyWith(
        updateCommentLoadingById: {
          ...latest.updateCommentLoadingById,
          commentId: false,
        },
      );
    } catch (e) {
      final latest = state;
      final reverted = originalSnapshot != null
          ? CommentsStateUpdater.replaceCommentById(
              latest,
              commentId,
              originalSnapshot,
            )
          : latest;
      state = reverted.copyWith(
        updateCommentLoadingById: {
          ...reverted.updateCommentLoadingById,
          commentId: false,
        },
        updateCommentError: e.toString(),
      );
      rethrow;
    }
  }

  // delete
  Future<void> deleteComment({
    required String commentId,
    required String articleId,
    String? imageId,
    required List<String> removedImages,
  }) async {
    final current = state;
    state = current.copyWith(
      deleteCommentLoadingById: {
        ...current.deleteCommentLoadingById,
        commentId: true,
      },
    );

    try {
      await _service.deleteComment(
        commentId: commentId,
        removedImages: removedImages,
      );

      final latest = state;
      state = CommentsStateUpdater.removeCommentById(latest, commentId).copyWith(
        deleteCommentLoadingById: {
          ...latest.deleteCommentLoadingById,
          commentId: false,
        },
      );
    } catch (e) {
      final latest = state;
      state = latest.copyWith(
        deleteCommentLoadingById: {
          ...latest.deleteCommentLoadingById,
          commentId: false,
        },
        deleteCommentError: e.toString(),
      );
      rethrow;
    }
  }
}
