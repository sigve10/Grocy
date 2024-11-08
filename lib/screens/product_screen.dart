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
                        const SizedBox(height: 8),
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
