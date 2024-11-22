class Tag {
  final String name;
  final String? primaryTag;

  Tag({
    required this.name,
    this.primaryTag
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'] as String,
      primaryTag: json['primary_tag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primary_tag': primaryTag,
    };
  }
}
