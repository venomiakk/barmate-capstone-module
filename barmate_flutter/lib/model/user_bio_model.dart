class UserBioModel {
  final String userBio;

  UserBioModel({required this.userBio});

  factory UserBioModel.fromJson(Map<String, dynamic> json) {
    return UserBioModel(userBio: json['user_bio'] as String);
  }
}
