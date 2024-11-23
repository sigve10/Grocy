import 'package:flutter/material.dart';

/// Model for a product review.
class Rating {
  String userId;
  final String productEan;
  String? content;
  double? customerSatisfactionRating;
  double? labelAccuracyRating;
  double? priceRating;
  double? consistencyRating;

  Rating({
    required this.productEan, this.content,
    this.userId = "",
  });

  /// Get the weak key of this rating
  String get ratingKey {
    return userId + productEan;
  }

  /// The average rating of the product based on all rated categories
  double? get averageRating {
    int nonNullRatings = 0 + (customerSatisfactionRating == null ? 0 : 1)
      + (labelAccuracyRating == null ? 0 : 1)
      + (priceRating == null ? 0 : 1)
      + (consistencyRating == null ? 0 : 1);

    double totalRating = 0 + (customerSatisfactionRating ?? 0)
      + (labelAccuracyRating ?? 0)
      + (priceRating ?? 0)
      + (consistencyRating ?? 0);

    if (nonNullRatings == 0) {
      return null;
    }
    double averageRating = totalRating / nonNullRatings;
    return averageRating;
  }

  /// Generates a list of displayable ratings through mapping
  /// a label to a type of rating.
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
      content: json['content'] ?? ''
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

  /// Generates a row for stars that represents the rating.
  static Row getStarRating(double? stars, {Color? color}) {
    const double starSize = 20;
    stars = stars ?? 0;
    Color starColor = stars == 0
      ? Colors.grey
      : color ?? Colors.amber;

    Icon fullStar = Icon(Icons.star, size: starSize, color: starColor);
    Icon halfStar = Icon(Icons.star_half, size: starSize, color: starColor);
    Icon noStar = Icon(Icons.star_border, size: starSize, color: starColor);

    int fullStars = stars.floor();
    bool hasHalfStar = stars - (fullStars.floor()) >= 0.5;
    int noStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (int i = 0; i < fullStars; i++) fullStar,
      if (hasHalfStar) halfStar,
      for (int i = 0; i < noStars; i++) noStar
    ]);
  }

}
