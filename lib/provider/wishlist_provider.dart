import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import 'package:grocy/main.dart';

final wishlistNotifier =
    StateNotifierProvider<WishlistProvider, List<Product>>((ref) {
  return WishlistProvider();
});

/// State notifier for managing the wishlist in the database.
class WishlistProvider extends StateNotifier<List<Product>> {
  WishlistProvider() : super([]);

  /// Fetches all wishlist entries in the database.
  Future<void> fetchWishlist() async {
    // Grabs the user via supabase's auth get user method.
    final user = supabase.auth.currentUser;

    if (user == null) {
      return;
    }
    try {
      // Grabs all the products that are connected to users in the wishlist table.
      final response = await supabase
          .from('wishlist')
          .select(
              'product_ean, products(*)') // due to foreign key relation to product's ean.
          .eq('user_id', user.id);

      // Map the response into a list :)
      // Litt usikker på om vi trenger all informasjonen, så skal se på dette mer i morgen med Sten.
      final wishlist = response.map((item) {
        final productData = item['products'];
        return Product.fromJson(productData);
      }).toList();

      state = wishlist;
    } catch (error) {
      debugPrint('Error fetching the wishlist from the database: $error');
    }
  }

  Future<bool> isWishlisted(Product product) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User needs to be logged in');
    }

    bool isProductInWishlist = false;

    /// Check if the product is in the wishlist and check what user it is.
    final query = supabase.from("wishlist")
        .select()
        .eq("product_ean", product.ean)
        .eq("user_id", user.id)
        .count();

    try {
      final result = await query;
      isProductInWishlist = result.count > 0;
    } catch (error) {
      debugPrint('Error fetching the wishlist from the database: $error');
    }
    return isProductInWishlist;
  }

  /// Adds a product to the wishlist in the database.
  void addProductToWishlist(Product product) async {
    final user = supabase.auth.currentUser;

    // Trenger en user check for å unngå at den kan være null lenger nede.
    if (user == null) {
      throw Exception('User needs to be logged in');
    }

    try {
      // Add the product into the wishlist.
      await supabase.from('wishlist').insert({
        'user_id': user.id,
        'product_ean': product.ean,
      });

    } catch (error) {
      debugPrint('Was unable to add the product: $product to wishlist: $error');
    }

    fetchWishlist();
  }

  /// Deletes a product from an authenticated user's wishlist in the database.
  void deleteProductFromWishlist(Product product) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User needs to be logged in first');
    }

    try {
      await supabase
          .from('wishlist')
          .delete()
          .match({'user_id': user.id, 'product_ean': product.ean});

    } catch (error) {
      debugPrint('Was unable to delete product from wishlist: $error');
    }

    fetchWishlist();
  }

}
