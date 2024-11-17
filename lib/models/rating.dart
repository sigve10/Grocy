class Rating {
  final String userEmail;
  final String productEan;
  double? customerSatisfactionRating;
  double? labelAccuracyRating;
  double? priceRating;
  double? consistencyRating;

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
      + (labelAccuracyRating == null ? 0 : 1)
      + (priceRating == null ? 0 : 1)
      + (consistencyRating == null ? 0 : 1);

    double totalRating = (customerSatisfactionRating ?? 0)
      + (labelAccuracyRating ?? 0)
      + (priceRating ?? 0)
      + (consistencyRating ?? 0);

    return totalRating / nonNullRatings;
  }

  List<Map<String, dynamic>> get displayable {
    return [
      {
        "label": "Customer Satisfaction",
        "value": customerSatisfactionRating
      },
      {
        "label": "Label Accuracy",
        "value": labelAccuracyRating
      },
      {
        "label": "Bank for Buck",
        "value": priceRating
      },
      {
        "label": "Consistency",
        "value": consistencyRating
      },
    ];
  }
}