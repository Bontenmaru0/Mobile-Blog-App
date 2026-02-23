class CommentModel {
  final String id;
  final String articleId;
  final String? imageId;
  final String userId;
  final String authorName;
  final String? parentId;
  final String? content;
  final String? status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int depth;
  final int replyCount;
  final int totalArticleComments;
  final int totalImageComments;
  final List<String> images;

  CommentModel({
    required this.id,
    required this.articleId,
    required this.imageId,
    required this.userId,
    required this.authorName,
    required this.parentId,
    required this.content,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.depth,
    required this.replyCount,
    required this.totalArticleComments,
    required this.totalImageComments,
    this.images = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      articleId: json['article_id'] as String,
      imageId: json['image_id'] as String?, // nullable
      userId: json['user_id'] as String,
      authorName: json['author_name'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String?, // nullable
      status: json['status'] as String?, // nullable
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      depth: json['depth'] as int,
      replyCount: json['coalesce'] ?? json['reply_count'] ?? 0,
      totalArticleComments: json['total_article_comments'] as int,
      totalImageComments: json['total_image_comments'] as int,
      images:
          (json['image'] as List<dynamic>?)
              ?.map((img) => img['image_url'] as String)
              .toList() ??
          [],
    );
  }
}
