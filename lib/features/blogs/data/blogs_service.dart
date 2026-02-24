import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../../core/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/blog_model.dart';

class ArticleUpdateResult {
  final ArticleModel? article;
  final List<String> newImageUrls;

  const ArticleUpdateResult({
    required this.article,
    required this.newImageUrls,
  });
}

class BlogsService {
  final SupabaseClient _supabase = SupabaseService.client;

  //fetch
  Future<(List<ArticleModel>, int)> fetchBlogs({
    int limit = 5,
    int page = 1,
    String? search,
    bool onlyMine = false,
  }) async {
    final offset = (page - 1) * limit;

    final response = await _supabase.rpc(
      'get_articles',
      params: {
        'p_limit': limit,
        'p_offset': offset,
        'p_search': search,
        'p_only_mine': onlyMine,
      },
    );

    final data = response['data'] as List? ?? [];
    final total = (response['total'] as num?)?.toInt() ?? 0;

    final articles = data.map((e) => ArticleModel.fromJson(e)).toList();

    return (articles, total);
  }

  // create
  Future<void> createArticle({
    required String title,
    required String content,
    required List<File> files,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    List<String> uploadedUrls = [];

    for (final file in files) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final path = 'articles/$fileName';

      await _supabase.storage.from('article_images').upload(path, file);

      final publicUrl = _supabase.storage
          .from('article_images')
          .getPublicUrl(path);

      uploadedUrls.add(publicUrl);
    }

    await _supabase.rpc(
      'insert_article',
      params: {
        'p_title': title,
        'p_content': content,
        'p_images': uploadedUrls,
        'p_user_id': user.id,
      },
    );
  }

  // update
  Future<ArticleUpdateResult> updateArticle({
    required String articleId,
    required String title,
    required String content,
    required List<File> files,
    required List<String> removedImages,
  }) async {
    List<String> newUploadedUrls = [];

    // upload new images
    for (final file in files) {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final path = 'articles/$articleId/$fileName';

      await _supabase.storage.from('article_images').upload(path, file);

      final publicUrl = _supabase.storage
          .from('article_images')
          .getPublicUrl(path);

      newUploadedUrls.add(publicUrl);
    }

    final response = await _supabase.rpc(
      'update_article',
      params: {
        'p_article_id': articleId,
        'p_title': title,
        'p_content': content,
        'p_new_images': newUploadedUrls,
        'p_removed_images': removedImages,
      },
    );

    final parsed = _parseArticleResponse(response);

    // best-effort cleanup after DB update succeeds
    if (removedImages.isNotEmpty) {
      final paths = removedImages
          .map(_getArticleImagePath)
          .whereType<String>()
          .toList();

      if (paths.isNotEmpty) {
        try {
          await _supabase.storage.from('article_images').remove(paths);
        } catch (e) {
          debugPrint('Failed to remove old article images: $e');
        }
      }
    }

    return ArticleUpdateResult(
      article: parsed,
      newImageUrls: List.unmodifiable(newUploadedUrls),
    );
  }

  // delete
  Future<String> deleteArticle({
    required String articleId,
    required List<String> removedImages,
  }) async {
    // Delete images from storage
    if (removedImages.isNotEmpty) {
      final paths = removedImages
          .map(_getArticleImagePath)
          .whereType<String>()
          .toList();

      if (paths.isNotEmpty) {
        await _supabase.storage.from('article_images').remove(paths);
      }
    }

    await _supabase.rpc('delete_article', params: {'p_article_id': articleId});

    return articleId;
  }

  //helper to extract storage path from image URL
  String? _getArticleImagePath(String url) {
    const marker = '/article_images/';
    final idx = url.indexOf(marker);
    return idx != -1 ? url.substring(idx + marker.length) : null;
  }

  ArticleModel? _parseArticleResponse(dynamic response) {
    if (response is List && response.isNotEmpty && response.first is Map) {
      return ArticleModel.fromJson(
        Map<String, dynamic>.from(response.first as Map),
      );
    }
    if (response is Map) {
      return ArticleModel.fromJson(Map<String, dynamic>.from(response));
    }
    return null;
  }
}
