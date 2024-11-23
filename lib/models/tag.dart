/// Model for a tag that is associated with a product.
class Tag {
  final String name;
  final String? primaryTag;

  Tag({
    required this.name,
    this.primaryTag
  });

  /// Factory method for creating an instance of [Tag] from a JSON object.
  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'] as String,
      primaryTag: json['primary_tag'] as String?,
    );
  }

  /// Converts a [Tag] into a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primary_tag': primaryTag,
    };
  }
}
