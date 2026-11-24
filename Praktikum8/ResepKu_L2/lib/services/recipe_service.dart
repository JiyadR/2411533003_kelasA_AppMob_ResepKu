
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resepku_l2/models/recipe.dart';

/// Semua komunikasi ResepKu dengan REST API dummyjson.com
/// dilakukan melalui class ini.
class RecipeService {
  RecipeService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://dummyjson.com';
  static const _timeout = Duration(seconds: 10);

  /// GET /recipes?limit=50
  /// Mengambil daftar resep.
  Future<List<Recipe>> fetchRecipes({int limit = 50}) async {
    final uri = Uri.parse('$_baseUrl/recipes?limit=$limit');

    final response = await _client.get(uri).timeout(_timeout);

    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['recipes'] as List<dynamic>;

    return list
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// GET /recipes/search?q=...
  /// Mencari resep berdasarkan kata kunci.
  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse('$_baseUrl/recipes/search').replace(
      queryParameters: {'q': query.trim()},
    );

    final response = await _client.get(uri).timeout(_timeout);

    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['recipes'] as List<dynamic>;

    return list
        .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// POST /recipes/add
  /// Mengirim resep baru.
  Future<Recipe> addRecipe({
    required String name,
    required String cuisine,
    required int cookTimeMinutes,
  }) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/recipes/add'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'cuisine': cuisine,
            'cookTimeMinutes': cookTimeMinutes,
          }),
        )
        .timeout(_timeout);

    _checkStatus(response);

    return Recipe.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// PUT /recipes/{id}
  /// Mengubah nama resep berdasarkan ID.
  Future<Recipe> updateRecipe({
    required int id,
    required String name,
  }) async {
    final response = await _client
        .put(
          Uri.parse('$_baseUrl/recipes/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
          }),
        )
        .timeout(_timeout);

    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    return Recipe.fromJson(body);
  }

  /// DELETE /recipes/{id}
  /// Menghapus resep berdasarkan ID.
  /// Mengembalikan true jika respons server berisi isDeleted: true.
  Future<bool> deleteRecipe(int id) async {
    final response = await _client
        .delete(
          Uri.parse('$_baseUrl/recipes/$id'),
        )
        .timeout(_timeout);

    _checkStatus(response);

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    return body['isDeleted'] == true;
  }

  /// Memeriksa status HTTP.
  /// Status di luar rentang 2xx dianggap sebagai error.
  void _checkStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RecipeServiceException(
        'Server menjawab dengan status ${response.statusCode}',
      );
    }
  }

  void close() => _client.close();
}

class RecipeServiceException implements Exception {
  RecipeServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
