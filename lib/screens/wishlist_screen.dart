import 'package:flutter/material.dart';
import '../manager/wishlist_manager.dart';
import '../models/product.dart';
import '../widget/wishlist_item.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  WishlistScreenState createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    List<Product> wishlist = WishlistManager().wishlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                final isFavorite = WishlistManager().isInWishlist(product);
                return WishlistItem(
                  product: product,
                  isFavorite: isFavorite,
                  onToggleWishlist: () {
                    if (!isFavorite) {
                      _toggleWishlist(product);
                    } else {
                      _showRemoveConfirmationDialog(product);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleWishlist(Product product) {
    setState(() {
      if (WishlistManager().isInWishlist(product)) {
        WishlistManager().removeFromWishlist(product);
      } else {
        WishlistManager().addToWishlist(product);
      }
    });
  }

  void _showRemoveConfirmationDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove from Wishlist'),
          content: const Text(
              'Do you want to remove this product from your wishlist?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Remove'),
              onPressed: () {
                Navigator.of(context).pop();
                _toggleWishlist(product);
              },
            ),
          ],
        );
      },
    );
  }
}
