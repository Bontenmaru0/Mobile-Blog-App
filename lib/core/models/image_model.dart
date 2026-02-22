class ImageModel {
  final String id;
  final String imageUrl;
  final String? altText;
  final int? position;

  ImageModel({
    required this.id,
    required this.imageUrl,
    this.altText,
    this.position,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      imageUrl: json['image_url'],
      altText: json['alt_text'],
      position: json['position'],
    );
  }
}