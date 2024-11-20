import '../models/product.dart';

class WishlistManager {
  static final WishlistManager _singleton = WishlistManager._internal();

  factory WishlistManager() {
    return _singleton;
  }

  WishlistManager._internal();

  final List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  bool isInWishlist(Product product) {
    return _wishlist.contains(product);
  }

  void addToWishlist(Product product) {
    if (!_wishlist.contains(product)) {
      _wishlist.add(product);
    }
  }

  void removeFromWishlist(Product product) {
    _wishlist.remove(product);
  }
}
