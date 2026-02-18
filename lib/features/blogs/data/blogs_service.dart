import 'dart:io';
import '../../../core/services/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/blogs_model.dart';

class BlogsService {
  final SupabaseClient _supabase = SupabaseService.client;

  //fetch
  Future<(List<Article>, int)> fetchBlogs({
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

    final articles =
        data.map((e) => Article.fromJson(e)).toList();

        print(articles);

    return (articles, total);
  }

  // create
  Future<Article> createArticle({
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

      await _supabase.storage
          .from('article_images')
          .upload(path, file);

      final publicUrl = _supabase.storage
          .from('article_images')
          .getPublicUrl(path);

      uploadedUrls.add(publicUrl);
    }

    final response = await _supabase.rpc(
      'insert_article',
      params: {
        'p_title': title,
        'p_content': content,
        'p_images': uploadedUrls,
        'p_user_id': user.id,
      },
    );

    return Article.fromJson(response[0]);
  }

  // update
  Future<Article> updateArticle({
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

      await _supabase.storage
          .from('article_images')
          .upload(path, file);

      final publicUrl = _supabase.storage
          .from('article_images')
          .getPublicUrl(path);

      newUploadedUrls.add(publicUrl);
    }

    // delete removed images from storage
    if (removedImages.isNotEmpty) {
      final paths = removedImages
          .map(_getArticleImagePath)
          .whereType<String>()
          .toList();

      if (paths.isNotEmpty) {
        await _supabase.storage
            .from('article_images')
            .remove(paths);
      }
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

    return Article.fromJson(response[0]);
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
        await _supabase.storage
            .from('article_images')
            .remove(paths);
      }
    }

    await _supabase.rpc(
      'delete_article',
      params: {
        'p_article_id': articleId,
      },
    );

    return articleId;
  }

  //helper to extract storage path from image URL
  String? _getArticleImagePath(String url) {
    const marker = '/article_images/';
    final idx = url.indexOf(marker);
    return idx != -1 ? url.substring(idx + marker.length) : null;
  }
}
