/// 상품 도메인 모델.
///
/// 지금은 Mock 데이터(`data/mock_products.dart`)로만 채워지지만,
/// 추후 실제 API 응답을 이 클래스로 매핑(`Product.fromJson`)하면
/// 화면 쪽 코드는 전혀 수정할 필요가 없도록 설계했다.
class Product {
  final String id;
  final String brand;
  final String name;
  final int price; // KRW 원화 정수 단위
  final String image; // 지금은 network placeholder URL, 추후 CDN URL로 교체
  final String category; // 예: Bag, Shoes, Outer ...
  final List<String> colors; // 예: ['Black', 'Beige']
  final String description;
  final int stock; // 현재 매장 재고 수량
  final String storeLocation; // 예: '1F A구역 - 3번 진열대'
  final bool arAvailable; // 이 상품이 AR 가상 착용을 지원하는지 여부
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.colors,
    required this.description,
    required this.stock,
    required this.storeLocation,
    required this.arAvailable,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  bool get inStock => stock > 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      brand: json['brand'] as String,
      name: json['name'] as String,
      price: json['price'] as int,
      image: json['image'] as String,
      category: json['category'] as String,
      colors: List<String>.from(json['colors'] as List),
      description: json['description'] as String,
      stock: json['stock'] as int,
      storeLocation: json['storeLocation'] as String,
      arAvailable: json['arAvailable'] as bool,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'colors': colors,
      'description': description,
      'stock': stock,
      'storeLocation': storeLocation,
      'arAvailable': arAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  Product copyWith({
    String? id,
    String? brand,
    String? name,
    int? price,
    String? image,
    String? category,
    List<String>? colors,
    String? description,
    int? stock,
    String? storeLocation,
    bool? arAvailable,
    double? rating,
    int? reviewCount,
  }) {
    return Product(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      storeLocation: storeLocation ?? this.storeLocation,
      arAvailable: arAvailable ?? this.arAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
