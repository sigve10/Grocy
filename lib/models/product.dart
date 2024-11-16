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
  final String primaryTag;
  /// A list of secondary tags for the product, such as user-generated tags.
  final List<String> tags = [];

  Product({
    required this.ean,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.primaryTag
  });
}