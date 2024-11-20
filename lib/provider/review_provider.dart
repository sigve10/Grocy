import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import '../models/rating.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewNotifier = StateNotifierProvider<ReviewProvider, List<Rating>>(
    (ref) => ReviewProvider());

/// State notifier for managing the reviews in the database.
class ReviewProvider extends StateNotifier<List<Rating>> {
  ReviewProvider() : super([]);

  /// Default fetch that fetches all the reviews from the database.
  Future<void> fetchReviews() async {
    try {
      final response = await supabase.from('reviews').select();

      final reviews = (response as List<dynamic>)
          .map((item) => Rating.fromJson(item as Map<String, dynamic>))
          .toList();

      state = reviews;
      debugPrint('$state'); // Midlertidig debug mens e holder på med disse.
    } catch (error) {
      debugPrint('Error fetch reviews from the reviews table, $error');
    }
  }

  //TODO: implement fetch review for specific user. or something
}
