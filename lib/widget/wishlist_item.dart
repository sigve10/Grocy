import 'package:flutter/material.dart';
import 'package:grocy/widget/product_tile.dart';
import '../models/product.dart';

/// A widget for displaying a product in the wishlist,
/// allows user to toggle/untoggle products to the wishlist.
class WishlistItem extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onToggleWishlist;

  const WishlistItem({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return ProductTile(
      product: product,
      append: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          semanticLabel: isFavorite
              ? 'Remove from wishlist'
              : 'Add to wishlist',
        ),
        onPressed: onToggleWishlist,
      ),
    );
  }
}
