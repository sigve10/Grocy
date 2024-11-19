import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/tag.dart';

final tagProvider =
    StateNotifierProvider<TagNotifier, List<Tag>>((ref) => TagNotifier());

/// State notifier (Riverpod) for managing tags.
/// Fetches tags from the database.
class TagNotifier extends StateNotifier<List<Tag>> {
  TagNotifier() : super([]);

  ///Fetches tags from Supabase, and grabs the unique primary tags.
  Future<void> fetchTags() async {
    try {
      final response = await supabase.from('tags').select();

      final tags = (response as List<dynamic>)
          .map((item) => Tag.fromJson(item as Map<String, dynamic>))
          .toList();

      // Grab only unique primary tags. As there are multiple of the same values in the DB atm.
      // May change database structure later to connect them to numbers again, and use a second table like Sigve mentioned.
      // Handle dupe on supa instead of here?
      state = tags
          .map((tag) => tag.primaryTag!)
          .toSet() //To only get the unique tags to be shown. Yes I know it's not server side. 
          .map((name) => Tag(name: name))
          .toList();
    } catch (error) {
      debugPrint('Error fetching tags: $error');
      // I don't know how to handle errors properly :) User feedback?
    }
  }
}