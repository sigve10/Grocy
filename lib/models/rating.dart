class Rating {
  final String userEmail;
  final String productEan;
  int? customerSatisfactionRating;
  int? labelAccuracyRating;
  int? priceRating;
  int? consistencyRating;

  Rating({
    required this.userEmail,
    required this.productEan
  });

  /// Get the weak key of this rating
  String get ratingKey {
    return userEmail + productEan;
  }

  /// The average rating of the product based on all rated categories
  double get averageRating {
    int nonNullRatings = (customerSatisfactionRating == null ? 0 : 1)
      + (labelAccuracyRating == null ? 1 : 0)
      + (priceRating == null ? 0 : 1)
      + (consistencyRating == null ? 0 : 1);

    int totalRating = (customerSatisfactionRating ?? 0)
      + (labelAccuracyRating ?? 0)
      + (priceRating ?? 0)
      + (consistencyRating ?? 0);

    return totalRating / nonNullRatings;
  }
}