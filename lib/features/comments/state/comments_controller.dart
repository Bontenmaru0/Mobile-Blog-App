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

  // fetch
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

      if (imageId != null) {
        state = AsyncData(
          current.copyWith(
            imageComments: {...current.imageComments, imageId: comments},
            contentLoading: false,
          ),
        );
      } else {
        state = AsyncData(
          current.copyWith(
            articleComments: {...current.articleComments, articleId: comments},
            contentLoading: false,
          ),
        );
      }
    } catch (e) {
      state = AsyncData(
        current.copyWith(contentLoading: false, contentError: e.toString()),
      );
    }
  }

  // create
  Future<void> createComment({
    required String? content,
    required List<File> files,
    String? parentId,
  }) async {
    if (_articleId == null) return;

    final current = state.value ?? const CommentsState();
    final service = ref.read(commentsServiceProvider);

    final newComment = await service.createComment(
      articleId: _articleId!,
      content: content,
      imageId: _imageId,
      parentId: parentId,
      files: files,
    );

    if (_imageId != null) {
      final existing = current.imageComments[_imageId!] ?? [];

      state = AsyncData(
        current.copyWith(
          imageComments: {
            ...current.imageComments,
            _imageId!: [newComment, ...existing],
          },
        ),
      );
    } else {
      final existing = current.articleComments[_articleId!] ?? [];

      state = AsyncData(
        current.copyWith(
          articleComments: {
            ...current.articleComments,
            _articleId!: [newComment, ...existing],
          },
        ),
      );
    }
  }

  // update
  // update
  Future<void> updateComment({
    required String commentId,
    String? content,
    required List<File> newFiles,
    required List<String> removedImages,
  }) async {
    final current = state.value ?? const CommentsState();
    final service = ref.read(commentsServiceProvider);

    // Set per-comment loading true
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

      // Replace the updated comment in the current list
      final updatedList = _getCurrentList(
        current,
      ).map((c) => c.id == commentId ? updatedComment : c).toList();

      // Reset per-comment loading false
      state = AsyncData(
        current.copyWith(
          updateCommentLoadingById: {
            ...current.updateCommentLoadingById,
            commentId: false,
          },
        ),
      );

      // Set updated list
      _setUpdatedList(current, updatedList);
    } catch (e) {
      // Error case: reset loading and set error
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

    // set per-item loading true
    state = AsyncData(
      current.copyWith(
        deleteCommentLoadingById: {
          ...current.deleteCommentLoadingById,
          commentId: true,
        },
      ),
    );

    try {
      final service = ref.read(commentsServiceProvider);

      await service.deleteComment(
        commentId: commentId,
        removedImages: removedImages,
      );

      final updatedList = _getCurrentList(
        current,
      ).where((c) => c.id != commentId).toList();

      state = AsyncData(
        current.copyWith(
          deleteCommentLoadingById: {
            ...current.deleteCommentLoadingById,
            commentId: false,
          },
        ),
      );

      _setUpdatedList(state.value ?? current, updatedList);
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

  // helper to get current list based on context (article vs image)
  List<CommentModel> _getCurrentList(CommentsState current) {
    if (_imageId != null) {
      return current.imageComments[_imageId!] ?? [];
    }
    return current.articleComments[_articleId!] ?? [];
  }

  void _setUpdatedList(CommentsState current, List<CommentModel> updatedList) {
    if (_imageId != null) {
      state = AsyncData(
        current.copyWith(
          imageComments: {...current.imageComments, _imageId!: updatedList},
        ),
      );
    } else {
      state = AsyncData(
        current.copyWith(
          articleComments: {
            ...current.articleComments,
            _articleId!: updatedList,
          },
        ),
      );
    }
  }
}
