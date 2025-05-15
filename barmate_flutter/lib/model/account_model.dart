class Account {
  final int id;
  final String login;
  final String? title;

  Account({required this.id, required this.login, this.title});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as int,
      login: json['login'] as String,
      title: json['title'] != null ? json['title'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'title': title,
    };
  }
}
