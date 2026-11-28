/// Data resep contoh untuk pengujian (dipakai fakes.dart dan widget_test.dart).
/// Resep pertama harus Classic Margherita Pizza (dipakai sampleFavorite).
const recipesJson = '''
{
  "recipes": [
    {
      "id": 1,
      "name": "Classic Margherita Pizza",
      "cuisine": "Italian",
      "difficulty": "Easy",
      "prepTimeMinutes": 20,
      "cookTimeMinutes": 15,
      "servings": 4,
      "caloriesPerServing": 300,
      "rating": 4.9,
      "image": "https://example.com/margherita.jpg",
      "ingredients": ["Pizza dough", "Tomato sauce", "Mozzarella", "Basil"],
      "instructions": ["Preheat the oven.", "Spread the sauce.", "Add cheese and bake."]
    },
    {
      "id": 2,
      "name": "Nasi Goreng",
      "cuisine": "Indonesian",
      "difficulty": "Easy",
      "prepTimeMinutes": 10,
      "cookTimeMinutes": 15,
      "servings": 2,
      "caloriesPerServing": 250,
      "rating": 4.5,
      "image": "https://example.com/nasi-goreng.jpg",
      "ingredients": ["nasi", "telur", "kecap"],
      "instructions": ["Masak nasi.", "Tambahkan telur dan kecap."]
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 50
}
''';
