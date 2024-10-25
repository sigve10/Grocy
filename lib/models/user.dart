/// Implement user model class
class User {
  String key;
  String name;
  String email;

  /// User constructor
  User(
    this.key,
    {
      required this.name,
      required this.email,
    }
  );
}