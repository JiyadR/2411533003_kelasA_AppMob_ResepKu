
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:resepku_l1/models/recipe.dart';
import 'package:resepku_l1/services/recipe_service.dart';
import 'package:resepku_l1/widgets/recipe_tile.dart';
import 'package:resepku_l1/widgets/error_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Controller untuk mengambil teks dari TextField
  final TextEditingController _searchController =
      TextEditingController();

  // Future awal bernilai null sebelum pengguna mencari
  Future<List<Recipe>>? _recipesFuture;

  // Menyimpan kata kunci pencarian terakhir
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Menjalankan pencarian ketika pengguna menekan Enter
  void _searchRecipes(String value) {
    final query = value.trim();

    // Jika kata kunci kosong, tidak melakukan pencarian
    if (query.isEmpty) {
      setState(() {
        _currentQuery = '';
        _recipesFuture = null;
      });
      return;
    }

    // Membuat Future baru setiap kali pengguna mencari
    setState(() {
      _currentQuery = query;
      _recipesFuture =
          context.read<RecipeService>().searchRecipes(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari resep...',
            border: InputBorder.none,
          ),

          // Pencarian dijalankan saat pengguna menekan Enter
          onSubmitted: _searchRecipes,
        ),
      ),

      body: _recipesFuture == null
          // Tampilan awal sebelum pencarian dilakukan
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Masukkan kata kunci untuk mencari resep.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )

          // Menampilkan proses dan hasil pencarian
          : FutureBuilder<List<Recipe>>(
              future: _recipesFuture,
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return ErrorView(
                    message:
                        'Gagal mencari resep.\n${snapshot.error}',
                    onRetry: () {
                      _searchRecipes(_currentQuery);
                    },
                  );
                }

                // Mengambil hasil pencarian
                final recipes = snapshot.data ?? <Recipe>[];

                // Jika hasil pencarian kosong
                if (recipes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Resep "$_currentQuery" tidak ditemukan.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Coba gunakan kata kunci yang lain.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Jika resep ditemukan, tampilkan RecipeTile
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeTile(
                      recipe: recipes[index],
                    );
                  },
                );
              },
            ),
    );
  }
}
