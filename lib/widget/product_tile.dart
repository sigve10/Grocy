import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/models/rating.dart';
import 'package:grocy/provider/review_provider.dart';
import 'package:grocy/screens/product_screen.dart';

/// Widget for displaying product details in a tile format via [ClipRRect].
/// Shows the product's image, name and amount of reviews for the given product.
class ProductTile extends ConsumerWidget {
  final Product product;
  final Widget? append;

  const ProductTile({required this.product, super.key, this.append});

  IconData getMissingImageIconForProduct() {
    switch (product.primaryTag) {
      case "Food":
        return Icons.lunch_dining;
      case "Drink":
        return Icons.coffee;
      case "Electronics":
        return Icons.electric_bolt;
      case "Hygiene":
        return Icons.soap;
      case "Medical":
        return Icons.medical_services;
      case "Household":
        return Icons.handyman_outlined;
      case "Miscellaneous":
        return Icons.category;
      default:
        return Icons.broken_image;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ReviewProvider reviewProvider = ref.watch(reviewNotifier.notifier);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // ClipRRect is used to clip the image to a rounded rectangle
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  getMissingImageIconForProduct(),
                  size: 50,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    children: [
                    FutureBuilder(
                      future: reviewProvider.getReviewSummary(product.ean),
                      builder: (context, AsyncSnapshot<Rating?> snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final reviewSummary = snapshot.data;
                        // Rows within a row,
                        // Flex and expand, space to grow,
                        // Overflow no more.
                        // ~ Quoth ChatGPT
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: Rating.getStarRating(reviewSummary?.averageRating).children
                        );
                      }
                    ),
                    FutureBuilder(
                      future: reviewProvider.fetchRatings([product.ean]),
                      builder: (context, AsyncSnapshot<List<Rating>> snapshot) {
                        if (!snapshot.hasData || snapshot.data == null) {
                          return CircularProgressIndicator();
                        }
                        final reviewCount = snapshot.data!.where((e) => e.productEan == product.ean).length;
                        return Text(
                          "$reviewCount reviews",
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.6),
                              ),
                          );
                      }
                    ),
                  ],)
                ],
              ),
            ),
            if (append != null)
              append!
          ],
        ),
      ),
    );
  }

}