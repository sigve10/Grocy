import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/models/rating.dart';
import 'package:grocy/provider/review_provider.dart';

class LeaveReviewScreen extends ConsumerStatefulWidget {
  final Product product;
  const LeaveReviewScreen({super.key, required this.product});

  @override
  LeaveReviewScreenState createState() => LeaveReviewScreenState();
}

class LeaveReviewScreenState extends ConsumerState<LeaveReviewScreen> {
  final Map<String, int?> ratings = {
    "Customer Satisfaction": null,
    "Label Accuracy": null,
    "Bang for Buck": null,
    "Consistency": null,
  };

  final TextEditingController _reviewController = TextEditingController();
  late final ReviewProvider reviewProvider;

  void _updateRating(String category, int? rating) {
    setState(() {
      ratings[category] = rating;
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> getOldReview() async {
    final Rating? oldReview = await reviewProvider.fetchReview(widget.product.ean, null);
    if (oldReview != null) {
      setState(() {
        ratings["Customer Satisfaction"] = oldReview.customerSatisfactionRating as int?;
        ratings["Label Accuracy"] = oldReview.labelAccuracyRating as int?;
        ratings["Bang for Buck"] = oldReview.priceRating as int?;
        ratings["Consistency"] = oldReview.consistencyRating as int?;
        _reviewController.text = oldReview.content ?? "";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    reviewProvider = ref.read(reviewNotifier.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getOldReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Avocado",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ...ratings.keys.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (int index) {
                          return IconButton(
                            icon: Icon(
                              index < (ratings[category] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                            onPressed: () => _updateRating(category, index + 1),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              const Text(
                "Leave a review",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
               Text(
                "(Optional)",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "I think this product is....",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final reviewText = _reviewController.text;

                      final Rating newRating = Rating(productEan: widget.product.ean);
                      newRating.customerSatisfactionRating = ratings["Customer Satisfaction"] as double?;
                      newRating.labelAccuracyRating = ratings["Label Accuracy"] as double?;
                      newRating.priceRating = ratings["Bang for Buck"] as double?;
                      newRating.consistencyRating = ratings["Consistency"] as double?;
                      newRating.content = reviewText.isNotEmpty ? reviewText : null;

                      reviewProvider.addReview(newRating);

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
