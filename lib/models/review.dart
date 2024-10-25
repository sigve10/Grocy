class Review {
  final String key;

  Review(
    this.key,
    this.userKey,
    this.ratingsKey
  );

  final String userKey;
  final String ratingsKey;

  String? _content;

  String get content => _content ?? "";
  set content(String newContent) => content = newContent;
}