import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocy/models/rating.dart';
import 'package:grocy/provider/user_provider.dart';

/// Provider to fetch the reviewer's profile based on userId.
final reviewerProfileProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, userId) async {
  final userProvider = ref.read(userNotifier.notifier);
  return await userProvider.fetchProfile(userId);
});

/// A widget for displaying individual user reviews for the product.
class Review extends ConsumerStatefulWidget {
  final Rating rating;
  const Review({required this.rating, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ReviewState();
}

/// State class for the [Review] widget.
class ReviewState extends ConsumerState<Review> {
  static const maxReviewLines = 2;
  late final UserProvider userProvider;

  String reviewerName = "";

  bool isExpanded = false;
  bool isOverflowing = false;
  bool isLoading = true;

  /// Fetches the reviewer's profile data.
  void setupReviewData() async {
    final poster = await userProvider.fetchProfile(widget.rating.userId);
    setState(() {
      reviewerName = poster!["username"];
      isLoading = false;
    });
  }

  @override
  void initState() {
    userProvider = ref.read(userNotifier.notifier);
    setupReviewData();
    super.initState();
  }

  /// Builds the review widget.
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
                              text: TextSpan(text: widget.rating.content!),
                              maxLines: maxReviewLines,
                              textDirection: TextDirection.ltr)
                            ..layout(maxWidth: constraints.maxWidth);

                          isOverflowing = textPaint.didExceedMaxLines;

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(widget.rating.content!,
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
                  itemCount: widget.rating.displayable.length,
                  itemBuilder: (context, index) {
                    final currentRating = widget.rating.displayable[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(currentRating["label"]),
                        if (currentRating["value"] == null)
                          Rating.getStarRating(0, color: Colors.grey)
                        else
                          Rating.getStarRating(currentRating["value"] as double)
                      ],
                    );
                  }),
            Row(
              children: [
                if (!isExpanded)
                  Rating.getStarRating(widget.rating.averageRating ?? 0, color: widget.rating.averageRating != null ? null : Colors.grey),
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