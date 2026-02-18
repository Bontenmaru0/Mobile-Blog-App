import '../../../core/models/blogs_model.dart';

class ArticlesState {
  final List<Article> articles;
  final int total;
  final bool contentLoading;
  final String? blogError;

  final bool insertArticleLoading;
  final String? insertArticleError;

  final Map<String, bool> updateArticleLoadingById;
  final String? updateArticleError;

  final Map<String, bool> deleteArticleLoadingById;
  final String? deleteArticleError;

  const ArticlesState({
    this.articles = const [],
    this.total = 0,
    this.contentLoading = false,
    this.blogError,
    this.insertArticleLoading = false,
    this.insertArticleError,
    this.updateArticleLoadingById = const {},
    this.updateArticleError,
    this.deleteArticleLoadingById = const {},
    this.deleteArticleError,
  });

  ArticlesState copyWith({
    List<Article>? articles,
    int? total,
    bool? contentLoading,
    String? blogError,
    bool? insertArticleLoading,
    String? insertArticleError,
    Map<String, bool>? updateArticleLoadingById,
    String? updateArticleError,
    Map<String, bool>? deleteArticleLoadingById,
    String? deleteArticleError,
  }) {
    return ArticlesState(
      articles: articles ?? this.articles,
      total: total ?? this.total,
      contentLoading: contentLoading ?? this.contentLoading,
      blogError: blogError,
      insertArticleLoading:
          insertArticleLoading ?? this.insertArticleLoading,
      insertArticleError: insertArticleError,
      updateArticleLoadingById:
          updateArticleLoadingById ?? this.updateArticleLoadingById,
      updateArticleError: updateArticleError,
      deleteArticleLoadingById:
          deleteArticleLoadingById ?? this.deleteArticleLoadingById,
      deleteArticleError: deleteArticleError,
    );
  }
}
