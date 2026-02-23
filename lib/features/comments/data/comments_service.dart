import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_client.dart';
import '../../../core/models/comment_model.dart';

class CommentsService {
  final SupabaseClient _supabase = SupabaseService.client;

  // fetch article comments
  Future<List<CommentModel>> fetchArticleComments({
    required String articleId,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_article_comments',
        params: {'p_article_id': articleId},
      );

      final data = response as List? ?? [];
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // fetch image comments
  Future<List<CommentModel>> fetchImageComments({
    required String articleId,
    required String imageId,
  }) async {
    try {
      final response = await _supabase.rpc(
        'get_images_comments',
        params: {
          'p_article_id': articleId,
          'p_image_id': imageId,
        },
      );

      final data = response as List? ?? [];
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // create comment
  Future<CommentModel> createComment({
    required String articleId,
    String? content,
    String? imageId,
    String? parentId,
    required List<File> files,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      List<String> uploadedUrls = [];

      // upload multiple images
      for (final file in files) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final path = 'comments/$fileName';

        await _supabase.storage.from('comment_images').upload(path, file);
        final publicUrl = _supabase.storage.from('comment_images').getPublicUrl(path);
        uploadedUrls.add(publicUrl);
      }

      final response = await _supabase.rpc(
        'insert_comment_mobile',
        params: {
          'p_article_id': articleId,
          'p_content': content,
          'p_image_id': imageId,
          'p_parent_id': parentId,
          'p_comment_images': uploadedUrls,
        },
      );

      if (response is List && response.isNotEmpty) {
        return CommentModel.fromJson(Map<String, dynamic>.from(response[0]));
      } else if (response is Map) {
        return CommentModel.fromJson(Map<String, dynamic>.from(response));
      } else {
        throw Exception('Unexpected RPC response format');
      }
    } catch (e) {
      rethrow;
    }
  }

  // update comment
  Future<CommentModel> updateComment({
    required String commentId,
    String? content,
    required List<File> newFiles,
    required List<String> removedImages,
    String status = 'edited',
    String? articleId,
  }) async {
    try {
      List<String> newUploadedUrls = [];

      // Upload new images
      for (final file in newFiles) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final path = 'comments/$commentId/$fileName';

        await _supabase.storage.from('comment_images').upload(path, file);
        final publicUrl = _supabase.storage.from('comment_images').getPublicUrl(path);
        newUploadedUrls.add(publicUrl);
      }

      // Remove deleted images from storage (paths only)
      if (removedImages.isNotEmpty) {
        final paths = removedImages
            .map(_getCommentImagePath)
            .whereType<String>()
            .toList();

        if (paths.isNotEmpty) {
          await _supabase.storage.from('comment_images').remove(paths);
        }
      }

      // Call RPC to update comment (DB removal uses full image URL)
      final response = await _supabase.rpc(
        'update_comment_mobile',
        params: {
          'p_comment_id': commentId,
          'p_content': content,
          'p_status': status,
          'p_new_images': newUploadedUrls,
          'p_removed_images': removedImages, // full URLs
          'p_article_id': articleId,
        },
      );

      print("Update RPC response: $response");

      if (response is List && response.isNotEmpty) {
        return CommentModel.fromJson(Map<String, dynamic>.from(response[0]));
      } else if (response is Map) {
        return CommentModel.fromJson(Map<String, dynamic>.from(response));
      } else {
        throw Exception('Unexpected RPC response format');
      }
    } catch (e, stack) {
      print("UPDATE ||||||||||| UPDATE COMMENT ERROR: $e");
      print(stack);
      rethrow;
    }
  }

  // delete comment
  Future<String> deleteComment({
    required String commentId,
    required List<String> removedImages,
  }) async {
    try {
      if (removedImages.isNotEmpty) {
        final paths = removedImages
            .map(_getCommentImagePath)
            .whereType<String>()
            .toList();

        if (paths.isNotEmpty) {
          await _supabase.storage.from('comment_images').remove(paths);
        }
      }

      await _supabase.rpc('delete_comment', params: {'p_comment_id': commentId});
      return commentId;
    } catch (e, stack) {
      print("UPDATE ||||||||||| DELETE COMMENT ERROR: $e");
      print(stack);
      rethrow;
    }
  }

  // helper to extract storage path from public URL
  String? _getCommentImagePath(String url) {
    const marker = '/comment_images/';
    final idx = url.indexOf(marker);
    return idx != -1 ? url.substring(idx + marker.length) : null;
  }
}