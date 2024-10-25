import 'package:grocy/models/rating.dart';
import 'package:grocy/models/review.dart';
import 'package:grocy/models/tag.dart';

class Product {
  Product(
    this.name,
    this.description
  );

  final String name;
  final String description;
  Set<Tag> tags = {};
  List<Review> reviews = [];
  List<Rating> ratings = [];
}