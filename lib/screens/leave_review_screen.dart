import 'package:flutter/material.dart';

class LeaveReviewScreen extends StatefulWidget {
  const LeaveReviewScreen({super.key});

  @override
  LeaveReviewScreenState createState() => LeaveReviewScreenState();
}

class LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final Map<String, int> ratings = {
    "Customer Satisfaction": 0,
    "Label Accuracy": 0,
    "Bang for Buck": 0,
    "Consistency": 0,
  };

  final TextEditingController _reviewController = TextEditingController();

  void _updateRating(String category, int rating) {
    setState(() {
      ratings[category] = rating;
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: Padding(
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
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < ratings[category]!
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
                    final selectedRatings = Map<String, int>.from(ratings);
                    print("Review Text: $reviewText");
                    print("Ratings: $selectedRatings");
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
    );
  }
}
