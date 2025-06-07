class Account {
  final int id;
  final String userid;
  final String login;
  final String? title;
  final String avatar;

  Account({required this.id, required this.userid, required this.login, this.title, required this.avatar});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      userid: json['userid'] as String? ?? json['id'] as String,
      login: json['login'] as String,
      title: json['title'] != null ? json['title'] as String : null,
      avatar: json['avatar'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userid,
      'login': login,
      'title': title,
      'avatar': avatar,
    };
  }
}
