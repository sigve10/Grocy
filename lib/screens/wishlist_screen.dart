import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../models/product.dart';
import '../widget/wishlist_item.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  WishlistScreenState createState() => WishlistScreenState();
}

class WishlistScreenState extends State<WishlistScreen> {
  final List<Product> allProducts = DummyData.getProducts();
  List<Product> wishlist = [];
  List<Product> filteredWishlist = [];

  @override
  void initState() {
    super.initState();
    // TODO: Replace hardcoded wishlist with actual user data
    wishlist = List.from(allProducts);
    filteredWishlist = wishlist;
  }

  void _toggleWishlist(Product product) {
    setState(() {
      if (wishlist.contains(product)) {
        wishlist.remove(product);
      } else {
        wishlist.add(product);
      }
    });
  }

  bool _isInWishlist(Product product) {
    return wishlist.contains(product);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredWishlist.length,
              itemBuilder: (context, index) {
                final product = filteredWishlist[index];
                final isFavorite = _isInWishlist(product);
                return WishlistItem(
                  product: product,
                  isFavorite: isFavorite,
                  onToggleWishlist: () {
                    if (!isFavorite) {
                      // adds the product to the wishlist
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
}
