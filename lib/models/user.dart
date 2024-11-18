/// Implement user model class
class User {
  final String email;
  final String nickname;

  /// User constructor
  User({required this.email, required this.nickname});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: 'email', nickname: 'username');
  }
}
