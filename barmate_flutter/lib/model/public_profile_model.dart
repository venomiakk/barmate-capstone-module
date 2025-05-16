class PublicProfileModel {
  final int id;
  final String username;
  final String? title;
  final String? bio;
  final String avatarUrl;
  final String uuid;

  PublicProfileModel(
    this.bio,
    this.avatarUrl,
    this.uuid,
    this.id,
    this.username,
    this.title,
  );

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    return PublicProfileModel(
      json['bio'] != null ? json['bio'] as String : null,
      json['avatar_url'] != null ? json['avatar_url'] as String : '',
      json['uuid'] != null ? json['uuid'] as String : '',
      json['id'] as int,
      json['username'] as String,
      json['user_title'] != null ? json['user_title'] as String : null,
    );
  }
}
