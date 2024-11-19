import 'package:grocy/models/rating.dart';

class Review {
  final Rating rating;
  final String content;

  Review({
    required this.rating,
    required this.content,
  });

    factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: Rating(
        userId: json['rating_user_id'] as String,
        productEan: json['rating_product_ean'] as String,
      ),
      content: json['description'] as String, 
    );
  }
}
