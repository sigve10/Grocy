import 'package:flutter/material.dart';
import 'package:grocy/models/rating.dart';

/// A widget that displays a review category with a star rating.
class ReviewCategory extends StatelessWidget {
  final String title;
  final double rating;

  const ReviewCategory({
    super.key,
    required this.title,
    required this.rating,
  });

  /// Builds the review category widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Rating.getStarRating(rating),
        ],
      ),
    );
  }
}
