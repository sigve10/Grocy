import 'package:grocy/models/tag_category.dart';

class Tag {
  Tag(
    this.key,
    this.name,
    this.tagCategory
  );

  final String key;
  final String name;
  final TagCategory tagCategory;
}