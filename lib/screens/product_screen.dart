import 'package:flutter/material.dart';
import 'package:grocy/models/product.dart';

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

class _ProductScreenState extends State<ProductScreen> {
  List<Product> filteredProducts = [];
  late _Rating productRating;
  bool isExpanded = false;

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
      {
        'label': 'Customer Satisfaction',
        'value': productRating.customerSatisfaction
      },
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

            // Ratings grid
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 2.8
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ratings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
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
                                starIndex <
                                        (ratings[index]['value'] as double)
                                            .round()
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
                  ),
                );
              },
            ),
            Row(children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaveReviewScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    "Leave an review",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ]),

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
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage("A"),
                              radius: 24,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Mats Bakketeig",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Great product! I love it!",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      starIndex <
                                              (ratings[index]['value']
                                                      as double)
                                                  .round()
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 20,
                                      color: Colors.amber,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                        if (isExpanded)
                          const Padding(
                            padding: EdgeInsets.only(top: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReviewCategory(
                                    title: 'Customer Satisfaction', rating: 4),
                                ReviewCategory(
                                    title: 'Bang for Buck', rating: 3),
                                ReviewCategory(
                                    title: 'Label Accuracy', rating: 4),
                                ReviewCategory(title: 'Consistency', rating: 3),
                              ],
                            ),
                          ),
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

class ReviewCategory extends StatelessWidget {
  final String title;
  final int rating;

  const ReviewCategory({super.key, required this.title, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Row(
            children: List.generate(
                5,
                (index) => Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    )),
          ),
        ],
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
