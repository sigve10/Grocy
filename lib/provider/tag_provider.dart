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

  Future<bool> createTag(Tag tag) async {
    try {
      final doesTagExistResponse = await supabase.from("tags")
          .select("name")
          .ilike("name", tag.name)
          .maybeSingle();

      final bool doesTagExist = doesTagExistResponse != null;

      if (doesTagExist) {
        return false;
      }

      await supabase.from('tags').insert({
        'name': tag.name,
        'primary_tag': tag.primaryTag,
      }).select();

      fetchTags();

      return true;
    } catch (error, stackTrace) {
      debugPrint('Error creating tag: $error');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Adds a tag to the 'tags' table, linking it to a specific product.
  Future<bool> addTagToProduct(Tag tag, String productEan) async {
    try {
      /// Link the tag to the product
      await supabase.from('product_tags').insert({
        'product_ean': productEan,
        'tag_name': tag.name,
      }).select();

      state = [...state, tag];

      return true;
    } catch (error, stackTrace) {
      debugPrint('Error adding tag to product: $error');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }
}

/// State notifier for managing the primary tags.
class PrimaryTagNotifier extends StateNotifier<List<Tag>> {
  PrimaryTagNotifier() : super([]);

  /// Fetches all the primary tags in the 'primary_tags' table in the database.
  void fetchPrimaryTags() async {
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