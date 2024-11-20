import 'package:flutter/material.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/models/rating.dart';
import '../manager/wishlist_manager.dart';
import 'leave_review_screen.dart';

/// The screen that displays the details of a product.
class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.product,
  });

  /// The product to display.
  final Product product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _StarRatingUtil {
  static Widget getStarRating(double stars) {
    const double starSize = 20;
    const Color starColor = Colors.amber;

    const Icon fullStar = Icon(Icons.star, size: starSize, color: starColor);
    const Icon halfStar =
        Icon(Icons.star_half, size: starSize, color: starColor);
    const Icon noStar =
        Icon(Icons.star_border, size: starSize, color: starColor);

    int fullStars = stars.floor();
    bool hasHalfStar = stars - (fullStars as double) >= 0.5;
    int noStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      for (int i = 0; i < fullStars; i++) fullStar,
      if (hasHalfStar) halfStar,
      for (int i = 0; i < noStars; i++) noStar
    ]);
  }
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> filteredProducts = [];
  late _Rating productRating;
  bool isExpanded = false;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    isFavorite = _isInWishlist(widget.product);
    filteredProducts = [widget.product];
    productRating = _Rating(
      customerSatisfaction: 4.5,
      labelAccuracy: 4.0,
      bangForBuck: 2.5,
      consistency: 1,
    );
  }

  /// to check if the product is in the wishlist
  bool _isInWishlist(Product product) {
    return WishlistManager().isInWishlist(product);
  }

  /// add or removes a product from the wishlist
  void _toggleWishlist() {
    setState(() {
      if (_isInWishlist(widget.product)) {
        WishlistManager().removeFromWishlist(widget.product);
        isFavorite = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from wishlist')),
        );
      } else {
        WishlistManager().addToWishlist(widget.product);
        isFavorite = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to wishlist')),
        );
      }
    });
  }

/// filter the products based on the query
  void _filterProducts(String query) {
    setState(() {
      filteredProducts = [widget.product]
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Handle tag selection from SearchWidget.
  @override
  Widget build(BuildContext context) {
    final ratings = [
      {
        'label': 'Customer Satisfaction',
        'value': productRating.customerSatisfaction
      },
      {'label': 'Label Accuracy', 'value': productRating.labelAccuracy},
      {'label': 'Bang for Buck', 'value': productRating.bangForBuck},
      {'label': 'Consistency', 'value': productRating.consistency},
    ];

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
                      color: isFavorite ? Colors.red : Colors.grey.shade400,
                      semanticLabel: isFavorite
                          ? 'Remove from wishlist'
                          : 'Add to wishlist',
                    ),
                    onPressed: _toggleWishlist,
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

            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 0.5,
            ),

            RatingsSection(
                rating: Rating(productEan: "", userId: "")
                  ..customerSatisfactionRating = 5
                  ..labelAccuracyRating = 4.5
                  ..priceRating = 2.5
                  ..consistencyRating = 1),

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
            ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return const Review();
              },
            )
          ],
        ),
      ),
    );
  }
}

/// A section that displays the ratings of a product.
class RatingsSection extends StatelessWidget {
  final Rating rating;

  const RatingsSection({super.key, required this.rating});

  List<Widget> createRatings() {
    final List<Widget> retval = [];

    for (Map<String, dynamic> currentRating in rating.displayable) {
      retval.add(Card.filled(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentRating["label"],
            textAlign: TextAlign.center,
          ),
          _StarRatingUtil.getStarRating(currentRating["value"] as double)
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
            Text("Ratings",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 24.0),
            GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    // Why are flutter grid this awful?
                    mainAxisExtent: 94),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: createRatings()),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaveReviewScreen(),
                      ),
                    );
                  },
                  child: const Text("Leave a Review"),
                ),
              ],
            )
          ],
        ));
  }
}

class Review extends StatefulWidget {
  const Review({super.key});

  @override
  State<StatefulWidget> createState() => ReviewState();
}

class ReviewState extends State<Review> {
  static const maxReviewLines = 2;

  final String reviewerName = "Mats Bakketeig";
  final String reviewContent =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur malesuada, lacus scelerisque dapibus consequat, metus dolor euismod elit, vitae auctor massa urna eu urna. Proin porttitor feugiat rhoncus. Aliquam et erat sed est molestie porttitor suscipit quis lorem. Proin aliquet pharetra urna in sodales. Aenean eget ornare leo. Praesent non sapien porttitor lorem imperdiet bibendum. Morbi leo quam, venenatis vitae justo id, malesuada sollicitudin elit. Maecenas accumsan elit sit amet ligula tristique, quis feugiat sem consectetur. Nulla id ex ante. Sed condimentum diam scelerisque, interdum erat eu, tempor mauris.";
  final String reviewPfp = "";
  final Rating rating = Rating(productEan: "", userId: "")
    ..customerSatisfactionRating = 5
    ..labelAccuracyRating = 4.5
    ..priceRating = 3.5
    ..consistencyRating = 1;

  bool isExpanded = false;
  bool isOverflowing = false;

  @override
  Widget build(BuildContext context) {
    return Card.outlined(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(child: Icon(Icons.account_circle)),
            const SizedBox(width: 24),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reviewerName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                // This allows us to check if the review exceeds X lines
                LayoutBuilder(builder: (context, constraints) {
                  final textPaint = TextPainter(
                      text: TextSpan(text: reviewContent),
                      maxLines: maxReviewLines,
                      textDirection: TextDirection.ltr)
                    ..layout(maxWidth: constraints.maxWidth);

                  isOverflowing = textPaint.didExceedMaxLines;

                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(reviewContent,
                            maxLines: isExpanded ? null : maxReviewLines,
                            overflow: isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis),
                      ]);
                })
              ],
            ))
          ],
        ),
        if (isExpanded) const SizedBox(height: 8.0),
        if (isExpanded)
          GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 2.8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rating.displayable.length,
              itemBuilder: (context, index) {
                final currentRating = rating.displayable[index];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(currentRating["label"]),
                    _StarRatingUtil.getStarRating(
                        currentRating["value"] as double)
                  ],
                );
              }),
        Row(
          children: [
            if (!isExpanded)
              _StarRatingUtil.getStarRating(rating.averageRating),
            const Spacer(),
            TextButton(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                child: Text(isExpanded ? "Show less" : "Show more"))
          ],
        )
      ]),
    ));
  }
}

class ReviewCategory extends StatelessWidget {
  final String title;
  final double rating;

  const ReviewCategory({super.key, required this.title, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), _StarRatingUtil.getStarRating(rating)],
      ),
    );
  }
}

class _Rating {
  final double customerSatisfaction;
  final double labelAccuracy;
  final double bangForBuck;
  final double consistency;

  _Rating({
    required this.customerSatisfaction,
    required this.labelAccuracy,
    required this.bangForBuck,
    required this.consistency,
  });
}
