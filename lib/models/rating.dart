import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  static Widget getStarRating(double stars) {
    const double starSize = 20;
    const Color starColor = Colors.amber;

    const Icon fullStar = Icon(Icons.star, size: starSize, color: starColor);
    const Icon halfStar =
    Icon(Icons.star_half, size: starSize, color: starColor);
    const Icon noStar =
    Icon(Icons.star_border, size: starSize, color: starColor);

    int fullStars = stars.floor();
    bool hasHalfStar = stars - (fullStars as double) >= 0.5;
    int noStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (int i = 0; i < fullStars; i++) fullStar,
      if (hasHalfStar) halfStar,
      for (int i = 0; i < noStars; i++) noStar
    ]);
  }

}
