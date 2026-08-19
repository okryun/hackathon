import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../models/review.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ReviewScreen extends StatelessWidget {
  final Product product;

  const ReviewScreen({super.key, required this.product});

  /// 백엔드(/api/v1/products/:id/reviews)에서 실제 리뷰 목록을 가져온다.
  Future<List<Review>> _fetchReviews() async {
    try {
      final data = await ApiClient.instance.get('/products/${product.id}/reviews') as List;
      return data.map((e) {
        final map = e as Map<String, dynamic>;
        return Review(
          id: map['id'] as String,
          authorName: map['authorName'] as String,
          rating: map['rating'] as int,
          date: DateTime.parse(map['createdAt'] as String),
          comment: map['comment'] as String,
          color: map['color'] as String?,
          helpfulCount: map['helpfulCount'] as int,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '리뷰 ${product.reviewCount}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<Review>>(
        future: _fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data ?? [];
          final distribution = _computeDistribution(reviews);

          return reviews.isEmpty
              ? Center(
                  child: Text(
                    '아직 등록된 리뷰가 없어요.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Text(
                      product.name,
                      style: AppTypography.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    _RatingSummary(
                      product: product,
                      distribution: distribution,
                      totalCount: reviews.length,
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 8),
                    for (final review in reviews) _ReviewCard(review: review),
                  ],
                );
        },
      ),
    );
  }

  Map<int, int> _computeDistribution(List<Review> reviews) {
    final counts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final review in reviews) {
      counts[review.rating] = (counts[review.rating] ?? 0) + 1;
    }
    return counts;
  }
}

class _RatingSummary extends StatelessWidget {
  final Product product;
  final Map<int, int> distribution;
  final int totalCount;

  const _RatingSummary({
    required this.product,
    required this.distribution,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (index) {
                final filled = index < product.rating.round();
                return Icon(
                  filled ? Icons.star : Icons.star_border,
                  size: 16,
                  color: AppColors.accent,
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '리뷰 $totalCount개',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(width: 28),
        Expanded(
          child: Column(
            children: [
              for (var star = 5; star >= 1; star--)
                _DistributionBar(
                  star: star,
                  count: distribution[star] ?? 0,
                  total: totalCount,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DistributionBar extends StatelessWidget {
  final int star;
  final int count;
  final int total;

  const _DistributionBar({
    required this.star,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 14,
            child: Text(
              '$star',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation(AppColors.ink),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.authorName.substring(0, 1),
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = index < review.rating;
                          return Icon(
                            filled ? Icons.star : Icons.star_border,
                            size: 13,
                            color: AppColors.accent,
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(review.date),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.color != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '컬러: ${review.color}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.thumb_up_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                '도움돼요 ${review.helpfulCount}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
