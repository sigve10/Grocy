import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/tag_category.dart';

class SearchWidget extends ConsumerStatefulWidget {
  const SearchWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return SearchWidgetState();
  }
}

class SearchWidgetState extends ConsumerState<SearchWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search products...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: null,
        ),
        children: [
          _SearchWidgetMainTags()
        ],
      )
    );
  }
}

class _SearchWidgetMainTags extends ConsumerWidget {
  static const List<TagCategory> categories = [
    TagCategory.electronics,
    TagCategory.food,
    TagCategory.hygiene,
    TagCategory.medical,
    TagCategory.miscellaneous
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 4.0,
      runSpacing: 0.0,
      children: [
        for (TagCategory category in categories)
          Chip(
            label: Text(category.displayName)
          )
      ],
    );
  }

}