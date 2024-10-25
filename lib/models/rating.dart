/// Rating model class
/// Implement rating model class
class Rating {
  final String key;

  /// Rating constructor
  Rating(
    this.key,
    this._rating,
    {
      required this.ratingType,
    }
  );

  final String ratingType;
  int _rating;

  double get rating => _rating/10;
  set rating(double newRating) {
    newRating *= 10;
    if (newRating >= 0 && newRating <= 50) {
      _rating = (newRating *= 10) as int;
    }
  }
}

