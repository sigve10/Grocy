import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import '../models/rating.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reviewNotifier = StateNotifierProvider<ReviewProvider, List<Rating>>(
    (ref) => ReviewProvider());

/// State notifier for managing the reviews in the database.
/// Supports all CRUD operations for Reviews table.
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

  //TODO: implement fetch reviews for the product only in product screen, probably isn't a problem but ya know

  /// Adds a review to the database via the authenticated user.
  void addReview(Rating rating) async {
    // Get the user that's authenticated / logged in user
    final user = supabase.auth.currentUser;

    // Improve this piece, snackbar message? dialog? something. Temporary.
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Temporary until the method is fully tested. Still need to fetch the username for the review though.
    final username = user.userMetadata?['username'];
    //Temporary debug prints.
    debugPrint('Username: $username');
    debugPrint('the user is $user');

    final userId = user.id; // The UUID of the auth user.
    debugPrint(
        'the userId is $userId and does this work ? the user.id? ${user.id}');

    final reviewData = {
      'user_id': userId,
      'product_ean': rating.productEan,
      'content': rating.content,
      'customer_satisfaction': rating.customerSatisfactionRating,
      'label_accuracy': rating.labelAccuracyRating,
      'price_accuracy': rating.priceRating,
      'consistency': rating.consistencyRating,
    };
    try {
      // Insert the review into the "reviews" table
      await supabase.from('reviews').insert(reviewData);

      // Temporary while testing the method.
      debugPrint('Review inserted successfully: $reviewData');
    } catch (error) {
      debugPrint('Error inserting review: $error');
    }
  }

  /// Delete one "specific" review from the database.
  void deleteReview(Rating rating) async {
    // Get the user that's authenticated / logged in user
    final user = supabase.auth.currentUser;

    if (user == null) {
      debugPrint('User er null her, test metode mer hvis det skjer');
      throw Exception('user not logged in'); //midlertidig før commit
    }
    debugPrint('the user is $user');
    final userId = user.id; // The UUID of the auth user, from auth.currentUser.
    debugPrint(
        'the userId is $userId and does this work ? the user.id? ${user.id}');

    try {

      // Delete the specific review that matches both user and product.
      final response = await supabase
          .from('reviews')
          .delete()
          .match({'user_id': userId, 'product_ean': rating.productEan});

      if (response.error != null) {
        debugPrint('Error deleting review: ${response.error!.message}');
        throw Exception('Failed to update review: ${response.error!.message}'); // temporary
      }
    } catch (error) {
      debugPrint('Errow deleting review: $error');
    }
  }
  

  /// Updates a review in the database.
  void updateReview(Rating updatedRating) async {
    // Get the user that's authenticated / logged in user
    final user = supabase.auth.currentUser;

    // Ensure the user is logged in
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.id; // The UUID of the authenticated user
    debugPrint('User ID for update: $userId');

    // Prepare the new updated review's data before it goes into the database response.
    final updatedReview = {
      'content': updatedRating.content,
      'customer_satisfaction': updatedRating.customerSatisfactionRating,
      'label_accuracy': updatedRating.labelAccuracyRating,
      'price_accuracy': updatedRating.priceRating,
      'consistency': updatedRating.consistencyRating,
    };

    try {
      debugPrint('Attempting to update the review for user $userId');

      // Update the review in the "reviews" table
      final response = await supabase
          .from('reviews')
          .update(updatedReview)
          .match({'user_id': userId, 'product_ean': updatedRating.productEan});

      if (response.error != null) {
        debugPrint('Error updating review: ${response.error!.message}');
        return;
      }

      debugPrint('Review has been updated successfully: $response');

      // Update the state after the database operation actually goes through.
      state = state.map((review) {
        // Make sure that the product's ean and the user's id matches before you update 😁
        if (review.productEan == updatedRating.productEan &&
            review.userId == userId) {
          return updatedRating;
        }
        return review;
      }).toList();
    } catch (error) {
      debugPrint('Error updating fjordkraft: $error');
    }
  }
}
