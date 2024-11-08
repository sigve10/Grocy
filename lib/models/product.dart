import 'package:grocy/models/rating.dart';
import 'package:grocy/models/rating_set.dart';
import 'package:grocy/models/review.dart';
import 'package:grocy/models/tag.dart';

class Product {
  final String key;
  final String name;
  final String description;
  final String? imageUrl;
  final int reviewCount;
  Set<Tag> tags = {};
  List<Review> reviews = [];
  List<Rating> ratings = [];

  Product({
    required this.key,
    required this.name,
    required this.description,
    this.imageUrl,
    this.reviewCount = 0,
  });
}