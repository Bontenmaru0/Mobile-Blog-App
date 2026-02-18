import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/blogs_service.dart';
import 'blogs_state.dart';
import 'dart:io';

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
      state = state.copyWith(
        contentLoading: false,
        blogError: e.toString(),
      );
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
    final loadingMap = Map<String, bool>.from(
        state.updateArticleLoadingById);
    loadingMap[id] = true;

    state = state.copyWith(updateArticleLoadingById: loadingMap);

    try {
      final updated = await _service.updateArticle(
        articleId: id,
        title: title,
        content: content,
        files: files,
        removedImages: removedImages,
      );

      final updatedList = state.articles.map((a) {
        return a.id == id ? updated : a;
      }).toList();

      loadingMap.remove(id);

      state = state.copyWith(
        articles: updatedList,
        updateArticleLoadingById: loadingMap,
      );
    } catch (e) {
      loadingMap.remove(id);

      state = state.copyWith(
        updateArticleLoadingById: loadingMap,
        updateArticleError: e.toString(),
      );
    }
  }

  // delete
  Future<void> deleteArticle({
    required String id,
    required List<String> removedImages,
  }) async {
    final loadingMap =
        Map<String, bool>.from(state.deleteArticleLoadingById);
    loadingMap[id] = true;

    state = state.copyWith(deleteArticleLoadingById: loadingMap);

    try {
      await _service.deleteArticle(
        articleId: id,
        removedImages: removedImages,
      );

      loadingMap.remove(id);

      state = state.copyWith(
        deleteArticleLoadingById: loadingMap,
        articles:
            state.articles.where((a) => a.id != id).toList(),
      );
    } catch (e) {
      loadingMap.remove(id);

      state = state.copyWith(
        deleteArticleLoadingById: loadingMap,
        deleteArticleError: e.toString(),
      );
    }
  }
}
