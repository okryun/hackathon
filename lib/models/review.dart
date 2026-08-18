/// 상품 리뷰 한 건.
class Review {
  final String id;
  final String authorName;
  final int rating; // 1~5
  final DateTime date;
  final String comment;
  final String? color;
  final int helpfulCount;

  Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.date,
    required this.comment,
    this.color,
    this.helpfulCount = 0,
  });
}
