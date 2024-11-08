import 'package:flutter/material.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/models/rating_set.dart';

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

class _ProductScreenState extends State<ProductScreen> {
  List<Product> filteredProducts = [];
  late _Rating productRating;

  @override
  void initState() {
    super.initState();
    filteredProducts = [widget.product];
    productRating = _Rating(
      customerSatisfaction: 4.5,
      labelAccuracy: 4.0,
      bangForBuck: 4.2,
      consistency: 1,
    );
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = [widget.product]
          .where((product) =>
          product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ratings = [
      {'label': 'Customer Satisfaction', 'value': productRating.customerSatisfaction},
      {'label': 'Label Accuracy', 'value': productRating.labelAccuracy},
      {'label': 'Bang for Buck', 'value': productRating.bangForBuck},
      {'label': 'Consistency', 'value': productRating.consistency},
    ];

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Search products...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: _filterProducts,
        ),
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
                widget.product.name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.product.description,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 0.5,
            ),
            // Display Ratings Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Ratings",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              //physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          ratings[index]['label'] as String,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < (ratings[index]['value'] as double).round()
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 10,
                              color: Colors.amber,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 0.5,
            ),

            // Display Reviews Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Reviews",
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              //physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemCount: 2,
              itemBuilder: (context, index) {
                return IntrinsicHeight(
                child:  Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          backgroundImage: NetworkImage('data:image/jpeg;base64,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'),
                          radius: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Mats Bakketeig",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                "Great product! I love it!",
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                ),
              );
              },
            )
          ],
        ),
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
