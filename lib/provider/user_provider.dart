import 'package:flutter/material.dart';
import 'package:grocy/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/user.dart';

final userNotifier = StateNotifierProvider<UserProvider, List<User>>((ref) => UserProvider());

/// State notifier for managing users.
class UserProvider extends StateNotifier<List<User>> {
  UserProvider() : super([]);

  /// Default fetch that fetches all users from the database.
  Future<void> fetchAllUsers() async {
    try {
      final response = await supabase.from('profiles').select();

      final users = (response as List<dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
          debugPrint('state før $state'); //midlertidig debugs mens e holder på med disse.
          state = users;
          debugPrint('state etter $state');
    } catch (error) {
      debugPrint('Error fetching users from profiles table $error');
    }
  }



  //TODO: figure out how to fetch the authenticated user only, so it can be connected to stoof
}
