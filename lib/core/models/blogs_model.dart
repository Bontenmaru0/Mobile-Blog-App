class Article {
  final String id;
  final String title;
  final String content;
  final List<String> images;
  final DateTime createdAt;
  final String? fullName;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
    required this.createdAt,
    this.fullName,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
  return Article(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    images: (json['images'] as List?)
            ?.map((e) => e['image_url'] as String)
            .toList() ??
        [],
    createdAt: DateTime.parse(json['created_at']),
    fullName: json['full_name'],
  );
}
}
