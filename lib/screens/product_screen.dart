import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/models/rating.dart';
import 'package:grocy/provider/review_provider.dart';
import '../models/tag.dart';
import '../provider/product_provider.dart';
import '../provider/tag_provider.dart';
import '../widget/review.dart';
import '../widget/tag_search_widget.dart';
import 'package:grocy/provider/wishlist_provider.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import 'leave_review_screen.dart';

/// The screen that displays the details of a product.
/// Including reviews and rating section.
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({
    super.key,
    required this.product,
  });

  /// The product to display.
  final Product product;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  List<Product> filteredProducts = [];
  bool isExpanded = false;
  bool isFavorite = false;
  List<Tag> tags = [];
  List<Rating> reviews = [];
  Rating ratingSummary = Rating(productEan: "-1");

  @override
  void initState() {
    getReviews();
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateIsFavorite(widget.product));
    filteredProducts = [widget.product];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(primaryTagProvider.notifier).fetchPrimaryTags();
    });
    ref
        .read(productProvider.notifier)
        .fetchTagsForProduct(widget.product.ean)
        .then((fetchedTags) {
      setState(() {
        tags = fetchedTags;
      });
    });
  }

  /// Fetches all reviews for the given product from database, as well as the review's summary.
  void getReviews() async {
    final reviewNotifierInstance = ref.read(reviewNotifier.notifier);
    final statelessRatingSummary =
        await reviewNotifierInstance.getReviewSummary(widget.product.ean);
    final statelessReviews =
        await reviewNotifierInstance.fetchReviews(widget.product.ean);
    setState(() {
      ratingSummary = statelessRatingSummary;
      reviews = statelessReviews;
    });
  }

  /// to check if the product is in the wishlist
  void _updateIsFavorite(Product product) async {
    WishlistProvider wishlistProvider = ref.read(wishlistNotifier.notifier);
    bool whatIsFavoriteState = await wishlistProvider.isWishlisted(product);
    setState(() => isFavorite = whatIsFavoriteState);
  }

  /// add or removes a product from the wishlist
  void _toggleWishlist() {
    setState(() {
      WishlistProvider wishlistProvider = ref.read(wishlistNotifier.notifier);
      if (isFavorite) {
        wishlistProvider.deleteProductFromWishlist(widget.product);
        context.showSnackBar(
          'Removed from wishlist',
        );
      } else {
        wishlistProvider.addProductToWishlist(widget.product);
        context.showSnackBar(
          'Added to wishlist',
        );
      }
      isFavorite = !isFavorite;
    });
  }

  void _onAddUserTagPressed() {
    final productPrimaryTag = widget.product.primaryTag;

    if (productPrimaryTag == null || productPrimaryTag.isEmpty) {
      context.showSnackBar(
        'Product does not have a primary tag',
      );

      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add User Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tag Search and Selection
                SizedBox(
                  child: TagSearchWidget(
                    onTagSelected: (Tag selectedTag) {
                      _addUserTag(selectedTag);
                      Navigator.of(context).pop();
                    },
                    allowCreateNewTag: true,
                    primaryTag: productPrimaryTag,
                    productEan: widget.product.ean,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addUserTag(Tag tag) async {
    // Fetch updated product data using productProvider
    final updatedTags = await ref
        .read(productProvider.notifier)
        .fetchTagsForProduct(widget.product.ean);

    // Update the UI
    setState(() {
      tags = updatedTags;
    });

    if (mounted) {
      context.showSnackBar(
        'Tag "${tag.name}" added successfully',
      );
    }
  }

  /// Handle tag selection from SearchWidget.
  @override
  Widget build(BuildContext context) {
    ProductProvider productNotifier = ref.watch(productProvider.notifier);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display product image
            Image.network(
              widget.product.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 100,
              ),
            ),
            const SizedBox(height: 14),

            // Product Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  /// Add to wishlist button
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                      semanticLabel: isFavorite
                          ? 'Remove from wishlist'
                          : 'Add to wishlist',
                    ),
                    onPressed: _toggleWishlist,
                  ),

                  const SizedBox(width: 16),

                  IconButton(
                    icon: Icon(
                      Icons.add_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    onPressed: _onAddUserTagPressed,
                    tooltip: 'Add User Tag',
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.product.description ?? "",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),

            // Product Tags
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                future: productNotifier.fetchTagsForProduct(widget.product.ean),
                builder: (context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  List<Tag> data = snapshot.data as List<Tag>;
                  return Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      if (widget.product.primaryTag != null &&
                          widget.product.primaryTag!.isNotEmpty)
                        Chip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sell,
                                size: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                              SizedBox(width: 4),
                              Text(widget.product.primaryTag!),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              width: 1,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      else
                        const Text("No tag available"),
                      ...(data.map((tag) {
                        return Chip(
                          label: Text(tag.name),
                        );
                      }).toList())
                    ],
                  );
                },
              ),
            ),

            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 0.5,
            ),

            _RatingsSection(
              product: widget.product,
              onReviewLeft: getReviews,
              rating: ratingSummary,
            ),

            const SizedBox(height: 24),

            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 0.5,
            ),

            // Display Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Reviews",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Review list with expandable
            ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [for (Rating rating in reviews) Review(rating: rating)],
            )
          ],
        ),
      ),
    );
  }
}

/// A section that displays the ratings of a product.
class _RatingsSection extends StatefulWidget {
  final Rating rating;
  final Product product;
  final Function onReviewLeft;

  const _RatingsSection(
      {required this.rating,
      required this.product,
      required this.onReviewLeft});

  @override
  _RatingsSectionState createState() => _RatingsSectionState();
}


class _RatingsSectionState extends State<_RatingsSection> {
  bool? hasUserReview;

  @override
  void initState() {
    super.initState();
    _checkUserReview();
  }

  /// Checks if the user has left a review for the product.
  Future<void> _checkUserReview() async {
    final userReview =
        await ReviewProvider().fetchReview(widget.product.ean, null);
    setState(() {
      hasUserReview = userReview != null;
    });
  }

  List<Widget> _createRatings() {
    final List<Widget> retval = [];

    for (Map<String, dynamic> currentRating in widget.rating.displayable) {
      retval.add(Card.filled(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentRating["label"],
            textAlign: TextAlign.center,
          ),
          if (currentRating["value"] == null)
            Rating.getStarRating(0, color: Colors.grey)
          else
            Rating.getStarRating(currentRating["value"] as double)
        ],
      )));
    }

    return retval;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ratings",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24.0),

          GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              mainAxisExtent: 94,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: _createRatings(),
          ),

          const SizedBox(height: 16.0),

          // The new dynamic review button 🐱‍🏍
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasUserReview == null)
                CircularProgressIndicator() // How big is this one ?
              else
                FilledButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeaveReviewScreen(
                          product: widget.product,
                          onReviewLeft: widget.onReviewLeft,
                        ),
                      ),
                    );

                    // Refresh it after user has just left a review, so that button changes to Edit immediately 😎
                    _checkUserReview();
                  },
                  child: Text( // Hope whoever reads this has a good day
                    hasUserReview! ? "Edit Review" : "Leave a Review",
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
