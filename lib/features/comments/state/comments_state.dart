import '../../../../core/models/comment_model.dart';

/// State for comments
class CommentsState {
  final bool contentLoading;
  final String? contentError;

  /// Map by articleId → List of comments
  final Map<String, List<CommentModel>> articleComments;

  /// Map by imageId → List of comments
  final Map<String, List<CommentModel>> imageComments;

  /// Per-comment deletion loading state
  final Map<String, bool> deleteCommentLoadingById;
  final String? deleteCommentError;

  final Map<String, bool> updateCommentLoadingById;
  final String? updateCommentError;

  const CommentsState({
    this.contentLoading = false,
    this.contentError,
    
    this.articleComments = const {},
    this.imageComments = const {},

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

      deleteCommentLoadingById:
          deleteCommentLoadingById ?? this.deleteCommentLoadingById,
      deleteCommentError: deleteCommentError,
      
      updateCommentLoadingById:
          updateCommentLoadingById ?? this.updateCommentLoadingById,
      updateCommentError: updateCommentError,
    );
  }
}