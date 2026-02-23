import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/comment_model.dart';
import '../data/comments_service.dart';
import 'comments_state.dart';
import 'dart:io';

final commentsServiceProvider = Provider((ref) => CommentsService());

final commentsControllerProvider =
    AsyncNotifierProvider<CommentsController, CommentsState>(
  CommentsController.new,
);

class CommentsController extends AsyncNotifier<CommentsState> {
  String? _articleId;
  String? _imageId;

  @override
  Future<CommentsState> build() async {
    return const CommentsState();
  }

  // fetch either article | specific image
  Future<void> fetchComments({
    required String articleId,
    String? imageId,
  }) async {
    _articleId = articleId;
    _imageId = imageId;

    final current = state.value ?? const CommentsState();

    state = AsyncData(
      current.copyWith(contentLoading: true, contentError: null),
    );

    try {
      final service = ref.read(commentsServiceProvider);

      final comments = imageId != null
          ? await service.fetchImageComments(
              articleId: articleId,
              imageId: imageId,
            )
          : await service.fetchArticleComments(articleId: articleId);

      final latest = state.value ?? current;

      if (imageId != null) {
        state = AsyncData(
          latest.copyWith(
            imageComments: {
              ...latest.imageComments,
              imageId: comments,
            },
            contentLoading: false,
          ),
        );
      } else {
        state = AsyncData(
          latest.copyWith(
            articleComments: {
              ...latest.articleComments,
              articleId: comments,
            },
            contentLoading: false,
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          contentLoading: false,
          contentError: e.toString(),
        ),
      );
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
    final current = state.value ?? const CommentsState();
    final service = ref.read(commentsServiceProvider);

    state = AsyncData(
      current.copyWith(
        insertCommentLoading: true,
        insertCommentError: null,
      ),
    );

    try {
      final newComment = await service.createComment(
        articleId: articleId,
        content: content,
        imageId: imageId,
        parentId: parentId,
        files: files,
      );

      final latest = state.value ?? current;

      if (imageId != null) {
        final existing = latest.imageComments[imageId] ?? [];

        state = AsyncData(
          latest.copyWith(
            imageComments: {
              ...latest.imageComments,
              imageId: [newComment, ...existing],
            },
            insertCommentLoading: false,
          ),
        );
      } else {
        final existing = latest.articleComments[articleId] ?? [];

        state = AsyncData(
          latest.copyWith(
            articleComments: {
              ...latest.articleComments,
              articleId: [newComment, ...existing],
            },
            insertCommentLoading: false,
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          insertCommentLoading: false,
          insertCommentError: e.toString(),
        ),
      );
    }
  }

  // update
  Future<void> updateComment({
    required String commentId,
    String? content,
    required List<File> newFiles,
    required List<String> removedImages,
  }) async {
    final current = state.value ?? const CommentsState();
    final service = ref.read(commentsServiceProvider);

    state = AsyncData(
      current.copyWith(
        updateCommentLoadingById: {
          ...current.updateCommentLoadingById,
          commentId: true,
        },
        updateCommentError: null,
      ),
    );

    try {
      final updatedComment = await service.updateComment(
        commentId: commentId,
        content: content,
        newFiles: newFiles,
        removedImages: removedImages,
      );

      final latest = state.value ?? current;

      final updatedList = _getCurrentList(latest)
          .map((c) => c.id == commentId ? updatedComment : c)
          .toList();

      if (_imageId != null) {
        state = AsyncData(
          latest.copyWith(
            imageComments: {
              ...latest.imageComments,
              _imageId!: updatedList,
            },
            updateCommentLoadingById: {
              ...latest.updateCommentLoadingById,
              commentId: false,
            },
          ),
        );
      } else {
        state = AsyncData(
          latest.copyWith(
            articleComments: {
              ...latest.articleComments,
              _articleId!: updatedList,
            },
            updateCommentLoadingById: {
              ...latest.updateCommentLoadingById,
              commentId: false,
            },
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          updateCommentLoadingById: {
            ...current.updateCommentLoadingById,
            commentId: false,
          },
          updateCommentError: e.toString(),
        ),
      );
    }
  }

  // delete
  Future<void> deleteComment({
    required String commentId,
    required List<String> removedImages,
  }) async {
    final current = state.value ?? const CommentsState();
    final service = ref.read(commentsServiceProvider);

    state = AsyncData(
      current.copyWith(
        deleteCommentLoadingById: {
          ...current.deleteCommentLoadingById,
          commentId: true,
        },
      ),
    );

    try {
      await service.deleteComment(
        commentId: commentId,
        removedImages: removedImages,
      );

      final latest = state.value ?? current;

      final updatedList = _getCurrentList(latest)
          .where((c) => c.id != commentId)
          .toList();

      if (_imageId != null) {
        state = AsyncData(
          latest.copyWith(
            imageComments: {
              ...latest.imageComments,
              _imageId!: updatedList,
            },
            deleteCommentLoadingById: {
              ...latest.deleteCommentLoadingById,
              commentId: false,
            },
          ),
        );
      } else {
        state = AsyncData(
          latest.copyWith(
            articleComments: {
              ...latest.articleComments,
              _articleId!: updatedList,
            },
            deleteCommentLoadingById: {
              ...latest.deleteCommentLoadingById,
              commentId: false,
            },
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          deleteCommentLoadingById: {
            ...current.deleteCommentLoadingById,
            commentId: false,
          },
          deleteCommentError: e.toString(),
        ),
      );
    }
  }

  // helper getting current state/list
  List<CommentModel> _getCurrentList(CommentsState current) {
    if (_imageId != null) {
      return current.imageComments[_imageId!] ?? [];
    }
    return current.articleComments[_articleId!] ?? [];
  }
}