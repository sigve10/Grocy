import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/tag.dart';

final tagProvider =
    StateNotifierProvider<TagNotifier, List<Tag>>((ref) => TagNotifier());

class TagNotifier extends StateNotifier<List<Tag>> {
  TagNotifier() : super([]);

  Future<void> fetchTags() async {
    try {
      final response = await supabase.from('tags').select();
      debugPrint('Supabase response: $response');

      final tags = (response as List<dynamic>)
          .map((item) => Tag.fromJson(item as Map<String, dynamic>))
          .toList();

      debugPrint('Mapped tags: $tags');

      // Extract unique primary tags
      final primaryTagsSet = <String>{};
      for (var tag in tags) {
        primaryTagsSet.add(tag.primaryTag!);
      }

      final primaryTags = primaryTagsSet.map((name) => Tag(name: name)).toList();

      // Update state with primary tags
      state = primaryTags;
    } catch (error) {
      debugPrint('Error fetching tags: $error');
      // Handle error appropriately
    }
  }
}

