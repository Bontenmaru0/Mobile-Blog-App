import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/blogs_service.dart';
import 'blogs_state.dart';
import '../../../core/models/blog_model.dart';
import '../../../core/models/image_model.dart';

final blogsServiceProvider = Provider((ref) => BlogsService());

final blogsControllerProvider =
    StateNotifierProvider<BlogsController, ArticlesState>((ref) {
      final service = ref.read(blogsServiceProvider);
      return BlogsController(service);
    });

class BlogsController extends StateNotifier<ArticlesState> {
  final BlogsService _service;

  BlogsController(this._service) : super(const ArticlesState());

  // fetch
  Future<void> fetchArticles({
    int limit = 5,
    int page = 1,
    String? search,
    bool onlyMine = false,
  }) async {
    try {
      state = state.copyWith(contentLoading: true, blogError: null);

      final (articles, total) = await _service.fetchBlogs(
        limit: limit,
        page: page,
        search: search,
        onlyMine: onlyMine,
      );

      state = state.copyWith(
        contentLoading: false,
        articles: articles,
        total: total,
      );
    } catch (e) {
      state = state.copyWith(contentLoading: false, blogError: e.toString());
    }
  }

  // create
  Future<void> createArticle({
    required String title,
    required String content,
    required List<File> files,
  }) async {
    try {
      state = state.copyWith(
        insertArticleLoading: true,
        insertArticleError: null,
      );

      await _service.createArticle(
        title: title,
        content: content,
        files: files,
      );

      state = state.copyWith(insertArticleLoading: false);

      await fetchArticles();
    } catch (e) {
      state = state.copyWith(
        insertArticleLoading: false,
        insertArticleError: e.toString(),
      );
      rethrow;
    }
  }

  // update
  Future<void> updateArticle({
    required String id,
    required String title,
    required String content,
    required List<File> files,
    required List<String> removedImages,
  }) async {
    final current = state;
    final loadingMap = Map<String, bool>.from(current.updateArticleLoadingById);
    loadingMap[id] = true;

    state = current.copyWith(
      updateArticleLoadingById: loadingMap,
      updateArticleError: null,
      articles: current.articles.map((article) {
        if (article.id != id) return article;

        final filteredImages = article.images
            .where((img) => !removedImages.contains(img.imageUrl))
            .toList();

        return ArticleModel(
          id: article.id,
          title: title,
          content: content,
          authorId: article.authorId,
          images: filteredImages,
          createdAt: article.createdAt,
          fullName: article.fullName,
        );
      }).toList(),
    );

    try {
      final result = await _service.updateArticle(
        articleId: id,
        title: title,
        content: content,
        files: files,
        removedImages: removedImages,
      );

      final updatedList = state.articles.map((a) {
        if (a.id != id) return a;

        if (result.article != null) {
          return result.article!;
        }

        final existingUrls = a.images.map((img) => img.imageUrl).toSet();
        final appended = result.newImageUrls
            .where((url) => !existingUrls.contains(url))
            .map(
              (url) => ImageModel(
                id: 'temp_${DateTime.now().microsecondsSinceEpoch}_${url.hashCode}',
                imageUrl: url,
              ),
            )
            .toList();

        return ArticleModel(
          id: a.id,
          title: a.title,
          content: a.content,
          authorId: a.authorId,
          images: [...a.images, ...appended],
          createdAt: a.createdAt,
          fullName: a.fullName,
        );
      }).toList();

      loadingMap.remove(id);

      state = state.copyWith(
        articles: updatedList,
        updateArticleLoadingById: loadingMap,
      );
    } catch (e) {
      loadingMap.remove(id);

      state = current.copyWith(
        updateArticleLoadingById: loadingMap,
        updateArticleError: e.toString(),
      );
      rethrow;
    }
  }

  // delete
  Future<void> deleteArticle({
    required String id,
    required List<String> removedImages,
  }) async {
    final current = state;
    final loadingMap = Map<String, bool>.from(current.deleteArticleLoadingById);
    loadingMap[id] = true;

    state = current.copyWith(
      deleteArticleLoadingById: loadingMap,
      deleteArticleError: null,
    );

    try {
      await _service.deleteArticle(articleId: id, removedImages: removedImages);

      loadingMap.remove(id);

      state = state.copyWith(
        deleteArticleLoadingById: loadingMap,
        articles: state.articles.where((a) => a.id != id).toList(),
      );
    } catch (e) {
      loadingMap.remove(id);

      state = current.copyWith(
        deleteArticleLoadingById: loadingMap,
        deleteArticleError: e.toString(),
      );
      rethrow;
    }
  }
}
