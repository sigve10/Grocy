import 'package:flutter/material.dart';
import 'package:grocy/widget/product_tile.dart';
import '../models/product.dart';

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
          color: isFavorite ? Colors.red : Colors.grey.shade400,
          semanticLabel: isFavorite
              ? 'Remove from wishlist'
              : 'Add to wishlist',
        ),
        onPressed: onToggleWishlist,
      ),
    );
  }
}
