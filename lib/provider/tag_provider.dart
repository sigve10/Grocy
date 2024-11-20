import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/tag.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final tagProvider =
    StateNotifierProvider<TagNotifier, List<Tag>>((ref) => TagNotifier());

final primaryTagProvider =
  StateNotifierProvider<PrimaryTagNotifier, List<Tag>>((ref) => PrimaryTagNotifier());

/// State notifier (Riverpod) for managing tags.
/// Fetches tags from the database.
class TagNotifier extends StateNotifier<List<Tag>> {
  TagNotifier() : super([]);

  ///Fetches tags from Supabase, and grabs the unique primary tags.
  void fetchTags() async {
    late final PostgrestList? response;
    late final List<Tag>? userTags;

    try {
      response = await supabase.from("tags").select();

      userTags = (response as List<dynamic>)
        .map((item) => Tag.fromJson(item as Map<String, dynamic>))
        .toList();
    } catch(error) {
      debugPrint('Error fetching tags: $error');
    }

    if (userTags != null) {
      state = userTags;
    }
  }
}

class PrimaryTagNotifier extends StateNotifier<List<Tag>> {
  PrimaryTagNotifier() : super([]);

  void fetchPrimaryTags() async {
    print("Fetching primary tags");
    late final PostgrestList? response;
    late final List<Tag>? primaryTags;
    try {
      response = await supabase.from("primary_tags").select("name");
      primaryTags = (response as List)
        .map((item) => Tag.fromJson(item as Map<String, dynamic>))
        .toList();
    } catch (error) {
      debugPrint("Error fetching primary tags: $error");
    }

    if (primaryTags != null) {
      state = primaryTags;
    }
  }
}