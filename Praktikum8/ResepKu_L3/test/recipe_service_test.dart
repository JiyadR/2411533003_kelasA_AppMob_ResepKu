
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resepku_l3/models/recipe.dart';
import 'package:resepku_l3/services/recipe_service.dart';

void main() {
  group('Recipe.fromJson', () {
    test('mengubah rating int menjadi double dan memberi nilai bawaan', () {
      final recipe = Recipe.fromJson({
        'id': 1,
        'name': 'Nasi Goreng',
        'rating': 5,
      });

      // Rating berupa int harus dikonversi menjadi double.
      expect(recipe.rating, 5.0);
      expect(recipe.rating, isA<double>());

      // Menguji nilai bawaan untuk field yang tidak tersedia.
      expect(recipe.cuisine, '-');
      expect(recipe.difficulty, '-');
      expect(recipe.prepTimeMinutes, 0);
      expect(recipe.cookTimeMinutes, 0);
      expect(recipe.servings, 1);
      expect(recipe.caloriesPerServing, 0);
      expect(recipe.image, '');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });
  });

  group('RecipeService.fetchRecipes', () {
    test('mengembalikan List<Recipe> dari respons HTTP palsu', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/recipes');
        expect(request.url.queryParameters['limit'], '50');

        return http.Response(
          jsonEncode({
            'recipes': [
              {
                'id': 1,
                'name': 'Nasi Goreng',
                'cuisine': 'Indonesian',
                'difficulty': 'Easy',
                'prepTimeMinutes': 10,
                'cookTimeMinutes': 15,
                'servings': 2,
                'caloriesPerServing': 250,
                'rating': 5,
                'image': 'https://example.com/nasi-goreng.jpg',
                'ingredients': ['nasi', 'telur'],
                'instructions': ['Masak nasi', 'Tambahkan telur'],
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = RecipeService(client: mockClient);
      addTearDown(service.close);

      final recipes = await service.fetchRecipes();

      expect(recipes, isA<List<Recipe>>());
      expect(recipes, hasLength(1));
      expect(recipes.first.id, 1);
      expect(recipes.first.name, 'Nasi Goreng');
      expect(recipes.first.rating, 5.0);
    });

    test('melempar RecipeServiceException jika status respons 404', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        return http.Response('Not Found', 404);
      });

      final service = RecipeService(client: mockClient);
      addTearDown(service.close);

      expect(
        service.fetchRecipes(),
        throwsA(isA<RecipeServiceException>()),
      );
    });
  });
}
