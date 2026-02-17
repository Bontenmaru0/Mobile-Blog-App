class Profile {
  final String id;
  final String fullName;
  final String nickname;
  final String bio;
  final String? avatarUrl;

  Profile({
    required this.id,
    required this.fullName,
    required this.nickname,
    required this.bio,
    this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      nickname: json['nickname'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'nickname': nickname,
      'bio': bio,
      'avatar_url': avatarUrl,
    };
  }
}
