import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/extentions/snackbar_context.dart';
import 'package:grocy/models/product.dart';
import 'package:grocy/models/rating.dart';
import 'package:grocy/provider/review_provider.dart';

/// A screen which allows users to leave a review for the selected product.
class LeaveReviewScreen extends ConsumerStatefulWidget {
  final Product product;
  final Function? onReviewLeft;
  const LeaveReviewScreen({super.key, this.onReviewLeft, required this.product});

  @override
  LeaveReviewScreenState createState() => LeaveReviewScreenState();
}

/// State class for the [LeaveReviewScreen]
/// Manages UI state for the review process.
class LeaveReviewScreenState extends ConsumerState<LeaveReviewScreen> {
  final Map<String, double?> ratings = {
    "Customer Satisfaction": null,
    "Label Accuracy": null,
    "Bang for Buck": null,
    "Consistency": null,
  };

  final Map<String, String> categoryTexts = {
    "Customer Satisfaction": "Did you like this product?",
    "Label Accuracy": "Did you get what you thought you paid for?",
    "Bang for Buck": "Was it worth the money?",
    "Consistency": "Is it usually the same quality every time you buy it?",
  };

  final TextEditingController _reviewController = TextEditingController();
  late final ReviewProvider reviewProvider;

  void _updateRating(String category, double? rating) {
    setState(() {
      ratings[category] = rating;
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  /// Fetches an existing review for a user if available.
  Future<void> getOldReview() async {
    final Rating? oldReview = await reviewProvider.fetchReview(widget.product.ean, null);
    if (oldReview != null) {
      setState(() {
        ratings["Customer Satisfaction"] = oldReview.customerSatisfactionRating?.floor().toDouble();
        ratings["Label Accuracy"] = oldReview.labelAccuracyRating?.floor().toDouble();
        ratings["Bang for Buck"] = oldReview.priceRating?.floor().toDouble();
        ratings["Consistency"] = oldReview.consistencyRating?.floor().toDouble();
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

  /// Adds a review from a user to a product.
  void leaveReview() async {
    final reviewText = _reviewController.text;

    final Rating newRating = Rating(productEan: widget.product.ean);
    newRating.customerSatisfactionRating = ratings["Customer Satisfaction"];
    newRating.labelAccuracyRating = ratings["Label Accuracy"];
    newRating.priceRating = ratings["Bang for Buck"];
    newRating.consistencyRating = ratings["Consistency"];
    newRating.content = reviewText.isNotEmpty ? reviewText : null;

    await reviewProvider.addReview(newRating);
    if (widget.onReviewLeft != null) {
      widget.onReviewLeft!();
    }
    if (mounted) {
    Navigator.pop(context);
    }
  }

  /// Delete the authenticated user's review.
  Future<void> _deleteReview() async {
    final rating = Rating(productEan: widget.product.ean);
    try {
      await reviewProvider.deleteReview(rating);

      // Notify parent widget that a review has been deleted.
      if (widget.onReviewLeft != null) {
        widget.onReviewLeft!();
      }

      if (mounted) {
        context.showSnackBar('Review successfully deleted');
      }

      // Instead of staying in leave review screen, navigate to the product screen 😎
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        context.showSnackBar('Failed to delete the review: $error');
      }
    }
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
              Text(
                widget.product.name,
                style: Theme.of(context).textTheme.headlineSmall
              ),
              const SizedBox(height: 8),
              Text(
                "Hint: You can leave ratings blank if you are unsure about a category",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(127)
                )
              ),
              const SizedBox(height: 20),
              ...ratings.keys.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        categoryTexts[category]!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withAlpha(127)
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ...List.generate(5, (int index) {
                          return IconButton(
                            icon: Icon(
                              index < (ratings[category] ?? 0)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: ratings[category] == null
                                ? Colors.grey
                                : Colors.amber,
                            ),
                            onPressed: () => _updateRating(category, index + 1),
                          );
                        }),
                        Spacer(),
                        IconButton(
                          onPressed: () => _updateRating(category, null),
                          icon: Icon(Icons.close)
                        )
                        ],
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Center the new Delete text (button) below Cancel :)
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel"),
                                ),
                                const SizedBox(
                                    height:
                                        12), // so that the cancel button isn't squished to the delete text button.
                                InkWell(
                                  onTap: () async {
                                    final bool? confirmDelete =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Confirm Deletion"),
                                          content: const Text(
                                              "Are you sure you want to delete this review?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context, false);
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            const SizedBox(width: 2),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(context, true);
                                                await _deleteReview();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                              ),
                                              child: Text(
                                                "Confirm",
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmDelete == true) {
                                      _reviewController.clear();
                                    }
                                  },
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                width:
                                    32), // Added space since I changed the row/column setup to add delete text button.
                            ElevatedButton(
                              onPressed: leaveReview,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
