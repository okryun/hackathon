import '../models/product.dart';
import '../data/mock_products.dart';

/// 상품 데이터 접근을 추상화하는 인터페이스.
///
/// 지금은 [MockProductService]만 존재하지만, 추후 백엔드 API가 준비되면
/// 이 인터페이스를 구현하는 `ApiProductService`를 새로 만들어
/// `main.dart`(혹은 DI 설정)에서 구현체만 바꿔 끼우면 된다.
/// 화면/위젯 코드는 [ProductService]만 알고 있으므로 수정이 필요 없다.
abstract class ProductService {
  Future<List<Product>> fetchAllProducts();
  Future<Product?> fetchProductById(String id);
  Future<List<Product>> fetchByCategory(String category);
  Future<List<String>> fetchCategories();
  Future<List<Product>> fetchPopular();
  Future<List<Product>> fetchRecommended();
  Future<List<Product>> search(String keyword);
}

/// Mock Data 기반 구현체. 실제 네트워크 호출처럼 약간의 지연(delay)을 흉내내어
/// 추후 API 전환 시 로딩 상태 처리 코드가 그대로 재사용되도록 한다.
class MockProductService implements ProductService {
  static const _fakeLatency = Duration(milliseconds: 300);

  @override
  Future<List<Product>> fetchAllProducts() async {
    await Future.delayed(_fakeLatency);
    return List.unmodifiable(mockProducts);
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    await Future.delayed(_fakeLatency);
    return findMockProductById(id);
  }

  @override
  Future<List<Product>> fetchByCategory(String category) async {
    await Future.delayed(_fakeLatency);
    if (category == 'All') return List.unmodifiable(mockProducts);
    return mockProducts.where((p) => p.category == category).toList();
  }

  @override
  Future<List<String>> fetchCategories() async {
    await Future.delayed(_fakeLatency);
    final categories = mockProducts.map((p) => p.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  /// 리뷰 수 + 평점을 기준으로 한 임시 "인기 상품" 로직.
  @override
  Future<List<Product>> fetchPopular() async {
    await Future.delayed(_fakeLatency);
    final sorted = [...mockProducts]
      ..sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    return sorted.take(6).toList();
  }

  /// 지금은 AR 지원 + 평점 기준 임시 추천 로직.
  /// 추후 사용자 행동 데이터 기반 추천 API로 교체될 지점.
  @override
  Future<List<Product>> fetchRecommended() async {
    await Future.delayed(_fakeLatency);
    final sorted = [...mockProducts]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(6).toList();
  }

  @override
  Future<List<Product>> search(String keyword) async {
    await Future.delayed(_fakeLatency);
    final q = keyword.trim().toLowerCase();
    if (q.isEmpty) return List.unmodifiable(mockProducts);
    return mockProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();
  }
}
