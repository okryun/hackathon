import 'dart:math';

import '../models/product.dart';
import '../models/review.dart';

const List<String> _authorPool = [
  '수민', '지훈', '하은', '민준', '서연',
  '도윤', '예은', '준서', '유진', '시우',
  '채원', '건우', '아윤', '지호', '나연',
];

const List<String> _highlightComments = [
  '기대했던 것보다 훨씬 고급스러워요. 마감이 정말 꼼꼼합니다.',
  '데일리로 들기 딱 좋은 사이즈예요. 수납력도 넉넉해서 만족스러워요.',
  '컬러감이 화면에서 본 것보다 예뻐요. 재구매 의사 100%입니다.',
  'AR로 미리 착용해보고 구매했는데 실물이랑 거의 똑같아서 놀랐어요.',
  '가죽 질감이 부드럽고 스크래치가 잘 안 생기는 것 같아요.',
];

const List<String> _neutralComments = [
  '전반적으로 무난하고 괜찮아요. 배송도 빨랐습니다.',
  '디자인은 마음에 드는데 생각보다 무게감이 있어요.',
  '가격 대비 만족스러운 편이에요. 다음엔 다른 컬러도 사보려고요.',
  '매장에서 실물 보고 구매했는데 기대만큼 좋았어요.',
];

const List<String> _criticalComments = [
  '색상이 사진과 살짝 다르게 느껴져서 조금 아쉬웠어요.',
  '스트랩 길이 조절이 조금 불편한 것 같아요.',
  '가격대를 생각하면 구성품이 조금 아쉬워요.',
];

/// 상품의 rating/reviewCount를 기반으로 그럴듯한 목업 리뷰 목록을 생성한다.
/// 실제 리뷰 데이터가 없는 프로토타입 단계에서 사용.
List<Review> generateMockReviews(Product product) {
  final count = product.reviewCount.clamp(0, 24);
  if (count == 0) return [];

  final random = Random(product.id.hashCode);
  final reviews = <Review>[];

  for (var i = 0; i < count; i++) {
    final base = product.rating.round();
    final offset = random.nextInt(3) - 1; // -1, 0, 1
    final rating = (base + offset).clamp(3, 5);

    final String comment;
    if (rating >= 5) {
      comment = _highlightComments[random.nextInt(_highlightComments.length)];
    } else if (rating == 4) {
      comment = _neutralComments[random.nextInt(_neutralComments.length)];
    } else {
      comment = _criticalComments[random.nextInt(_criticalComments.length)];
    }

    final author = _authorPool[random.nextInt(_authorPool.length)];
    final daysAgo = random.nextInt(120) + 1;

    reviews.add(
      Review(
        id: '${product.id}_review_$i',
        authorName: '$author***',
        rating: rating,
        date: DateTime.now().subtract(Duration(days: daysAgo)),
        comment: comment,
        color: product.colors.isNotEmpty
            ? product.colors[random.nextInt(product.colors.length)]
            : null,
        helpfulCount: random.nextInt(28),
      ),
    );
  }

  reviews.sort((a, b) => b.date.compareTo(a.date));
  return reviews;
}
