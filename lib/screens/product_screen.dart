import 'package:flutter/material.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/models/rating_set.dart';

/// The screen that displays the details of a product.
class ProductScreen extends StatefulWidget {
    ProductScreen({
    super.key,
    required this.product,
  });

  /// The product to display.
  final Product product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display product image
            Image.network(
              widget.product.imageUrl ?? '',
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.broken_image,
                size: 100,
              ),
            ),
            const SizedBox(height: 14),

            // Product Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.product.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            const SizedBox(height: 24),

            // Display Ratings Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Ratings",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Display Reviews Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Reviews",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
