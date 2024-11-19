class Rating {
  final String userId;
  final String productEan;
  double? customerSatisfactionRating;
  double? labelAccuracyRating;
  double? priceRating;
  double? consistencyRating;

  Rating({
    required this.userId,
    required this.productEan
  });

  /// Get the weak key of this rating
  String get ratingKey {
    return userId + productEan;
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
        "label": "Bang for Buck",
        "value": priceRating
      },
      {
        "label": "Consistency",
        "value": consistencyRating
      },
    ];
  }


  /// Factory method to parse the rating (similar to product)
  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      userId: json['user_id'] ?? '',
      productEan: json['product_ean'] ?? '',
    )
    // Use cascade operator to assign values after the creation of the rating object.
    // Need to use it as constructor only initializes the "keys", not the ratings.
    // double giving problems, need to use int in database, or change it ?
      ..customerSatisfactionRating =
          (json['customer_satisfaction'] as num?)?.toDouble()
      ..labelAccuracyRating = (json['label_accuracy'] as num?)?.toDouble()
      ..priceRating = (json['price_accuracy'] as num?)?.toDouble()
      ..consistencyRating = (json['consistency'] as num?)?.toDouble();
  }

}
