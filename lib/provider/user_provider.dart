import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userNotifier = StateNotifierProvider<UserProvider, Map<String, dynamic>>(
  (ref) => UserProvider(),
);

/// State notifier for managing user profile.
class UserProvider extends StateNotifier<Map<String, dynamic>> {
  UserProvider() : super({});

  Future<Map<String, dynamic>?> fetchMyProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final query = supabase.from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
    try {
      final data = await query;

      if (data == null) {
        print("User doesn't exist, signing out");
        supabase.auth.signOut();
        return null;
      }

      state = data;
      return data;
    } on PostgrestException catch (error) {
      debugPrint('Error fetching profile: ${error.message}');
      return null;
    } catch (error) {
      debugPrint('Unexpected error occurred: $error');
      return null;
    }
  }

  /// Fetches the current user's profile from Supabase.
  /// Returns the profile data or `null` if the user is not signed in.
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {

    final query = supabase.from('profiles')
      .select()
      .eq('id', userId)
      .single();
    try {
      final data = await query;
      return data;
    } on PostgrestException catch (error) {
      debugPrint('Error fetching profile: ${error.message}');
      return null;
    } catch (error) {
      debugPrint('Unexpected error occurred: $error');
      return null;
    }
  }


  /// Checks if the username is empty or not
  /// If it returns true then the username is not empty
  /// if false, the username is empty.
  Future<bool?> checkUserName() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not signed in.');
    }

    final userId = user.id;
    final response = await supabase
        .from('profiles')
        .select('username')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
        print("User doesn't exist, signing out");
        supabase.auth.signOut();
        return null;
      }

    // Check if response or username is null/empty
    if (response.isEmpty ||
        response['username'] == null ||
        (response['username'] as String).isEmpty) {
      return false; // Username is missing
    }

    return true; // Username exists 🙌
  }

  /// Updates the user's profile in Supabase.
  /// Takes a `username` and updates the profile data.
  Future<void> updateProfile(String username) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User is not signed in.');
      }

      final updates = {
        'id': user.id,
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('profiles').upsert(updates);

      // Update the state with the new username
      state = {...state, 'username': username};
    } catch (error) {
      debugPrint('Error updating user profile: $error');
    }
  }
}
