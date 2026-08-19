import '../models/product.dart';
import 'api_client.dart';
import 'product_service.dart';

/// 백엔드 API(/api/v1/products)를 호출하는 ProductService 구현체.
///
/// [ProductService] 인터페이스를 그대로 구현하기 때문에, main.dart에서
/// `MockProductService()` 대신 이 클래스를 생성해서 끼워넣기만 하면
/// 화면(screens) 쪽 코드는 한 줄도 수정할 필요가 없다.
class ApiProductService implements ProductService {
  final ApiClient _client = ApiClient.instance;

  Product _toProduct(dynamic json) => Product.fromJson(json as Map<String, dynamic>);

  List<Product> _toProductList(dynamic data) =>
      (data as List).map(_toProduct).toList();

  @override
  Future<List<Product>> fetchAllProducts() async {
    final data = await _client.get('/products');
    return _toProductList(data);
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    try {
      final data = await _client.get('/products/$id');
      return _toProduct(data);
    } on ApiException {
      return null;
    }
  }

  @override
  Future<List<Product>> fetchByCategory(String category) async {
    final data = await _client.get('/products', query: {'category': category});
    return _toProductList(data);
  }

  @override
  Future<List<String>> fetchCategories() async {
    final data = await _client.get('/products/categories') as List;
    return data.map((e) => e.toString()).toList();
  }

  @override
  Future<List<Product>> fetchPopular() async {
    final data = await _client.get('/products/popular');
    return _toProductList(data);
  }

  @override
  Future<List<Product>> fetchRecommended() async {
    final data = await _client.get('/products/recommended');
    return _toProductList(data);
  }

  @override
  Future<List<Product>> search(String keyword) async {
    final data = await _client.get('/products', query: {'search': keyword});
    return _toProductList(data);
  }
}
