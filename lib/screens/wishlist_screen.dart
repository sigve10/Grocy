import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/provider/wishlist_provider.dart';
import '../models/product.dart';
import '../widget/wishlist_item.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  WishlistScreenState createState() => WishlistScreenState();
}

class WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    ref.read(wishlistNotifier.notifier).fetchWishlist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WishlistProvider wishlistProvider = ref.watch(wishlistNotifier.notifier);
    List<Product> wishlist = ref.watch(wishlistNotifier);

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text(
            'Wishlist',
            style: TextStyle(
              fontSize: 32,
            ),
          ),
        ),
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: wishlist.length,
              itemBuilder: (context, index) {
                final product = wishlist[index];
                return WishlistItem(
                  product: product,
                  isFavorite: true,
                  onToggleWishlist: () {
                    _showRemoveConfirmationDialog(
                      product,
                      () => wishlistProvider.deleteProductFromWishlist(product)
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmationDialog(Product product, Function() onConfirm) {
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
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}
