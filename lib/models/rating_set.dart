import 'package:grocy/models/rating_type.dart';

class RatingSet {
  final String key;

  RatingSet(
    this.key,
    this.userKey,
    this.productKey
  );

  final String userKey;
  final String productKey;

  final Map<RatingType, String> ratings = {};
}