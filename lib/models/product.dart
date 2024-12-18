import 'package:grocy/models/tag.dart';

/// Represents a product you can buy off of store shelves
class Product {
  /// The barcode of the product (PK)
  final String ean;
  /// The name of the product
  final String name;
  /// The product's description, can be empty
  final String? description;
  /// An image url for the product image
  final String imageUrl;
  /// The primary tag of the product. Should be one of the basic tags.
  final String? primaryTag;
  /// A list of secondary tags for the product, such as user-generated tags.
  final List<Tag> tags;


  Product({
    required this.ean,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.primaryTag,
    this.tags = const [],
  });

  /// Parse the data from Supabase (json). 
  /// Alternatively we could set up @JsonSerializable(), however by us setting it up ourselves we prevent potential autogenerated errors.
  /// https://pub.dev/packages/json_serializable
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      ean: json['ean'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageurl'] ?? '',
      primaryTag: json['primary_tag'],
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tag) => Tag.fromJson(tag as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
