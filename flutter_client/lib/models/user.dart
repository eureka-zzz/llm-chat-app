class User {
  final int id;
  final String username;
  final bool isOnline;

  User({
    required this.id,
    required this.username,
    required this.isOnline,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      isOnline: json['is_online'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'is_online': isOnline,
    };
  }
}
