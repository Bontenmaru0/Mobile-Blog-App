import '../../../../core/models/comment_model.dart';

class CommentsState {
  final bool contentLoading;
  final String? contentError;

  /// Map by articleId → List of comments
  final Map<String, List<CommentModel>> articleComments;

  /// Map by imageId → List of comments
  final Map<String, List<CommentModel>> imageComments;

  /// Insert state
  final bool insertCommentLoading;
  final String? insertCommentError;

  /// Delete state
  final Map<String, bool> deleteCommentLoadingById;
  final String? deleteCommentError;

  /// Update state
  final Map<String, bool> updateCommentLoadingById;
  final String? updateCommentError;

  const CommentsState({
    this.contentLoading = false,
    this.contentError,
    this.articleComments = const {},
    this.imageComments = const {},

    this.insertCommentLoading = false,
    this.insertCommentError,

    this.deleteCommentLoadingById = const {},
    this.deleteCommentError,

    this.updateCommentLoadingById = const {},
    this.updateCommentError,
  });

  CommentsState copyWith({
    bool? contentLoading,
    String? contentError,
    Map<String, List<CommentModel>>? articleComments,
    Map<String, List<CommentModel>>? imageComments,

    bool? insertCommentLoading,
    String? insertCommentError,

    Map<String, bool>? deleteCommentLoadingById,
    String? deleteCommentError,

    Map<String, bool>? updateCommentLoadingById,
    String? updateCommentError,
  }) {
    return CommentsState(
      contentLoading: contentLoading ?? this.contentLoading,
      contentError: contentError,

      articleComments: articleComments ?? this.articleComments,
      imageComments: imageComments ?? this.imageComments,

      insertCommentLoading:
          insertCommentLoading ?? this.insertCommentLoading,
      insertCommentError: insertCommentError,

      deleteCommentLoadingById:
          deleteCommentLoadingById ?? this.deleteCommentLoadingById,
      deleteCommentError: deleteCommentError,

      updateCommentLoadingById:
          updateCommentLoadingById ?? this.updateCommentLoadingById,
      updateCommentError: updateCommentError,
    );
  }
}