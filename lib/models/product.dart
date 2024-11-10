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

  /// Parse the data from Supabase (json). 
  /// Alternatively we could set up @JsonSerializable(), however by us setting it up ourselves we prevent potential autogenerated errors.
  /// https://pub.dev/packages/json_serializable
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageurl'] as String?,
      reviewCount: json['review_count'] ?? 0,
    );
  }
}
