
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:resepku_l2/models/recipe.dart';
import 'package:resepku_l2/pages/settings_page.dart';
import 'package:resepku_l2/pages/search_page.dart';
import 'package:resepku_l2/services/recipe_service.dart';
import 'package:resepku_l2/widgets/error_view.dart';
import 'package:resepku_l2/widgets/favorite_badge_button.dart';
import 'package:resepku_l2/widgets/recipe_grid_card.dart';
import 'package:resepku_l2/widgets/recipe_tile.dart';
import 'package:resepku_l2/pages/add_recipe_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false;

  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = context.read<RecipeService>().fetchRecipes();
  }

  void _reload() {
    setState(() {
      _recipesFuture = context.read<RecipeService>().fetchRecipes();
    });
  }

  Future<void> _refresh() async {
    _reload();

    try {
      await _recipesFuture;
    } catch (_) {
      // error sudah ditampilkan oleh FutureBuilder
    }
  }

  Future<void> _openAddPage() async {
    final created = await Navigator.push<Recipe>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRecipePage(),
      ),
    );

    if (created == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${created.name}" diterima server dengan id ${created.id}. '
          'dummyjson hanya menyimulasikan penyimpanan.',
        ),
      ),
    );
  }

  // Membuka halaman pencarian resep
  void _openSearchPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('ResepKu'),
          ],
        ),
        actions: [
          // Tombol pencarian
          IconButton(
            tooltip: 'Cari resep',
            icon: const Icon(Icons.search),
            onPressed: _openSearchPage,
          ),

          // Tombol tampilan list dan grid
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : 'Tampilan grid',
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGrid = !_isGrid;
              });
            },
          ),

          // Tombol favorit
          const FavoriteBadgeButton(),

          // Tombol pengaturan
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            ),
          ),
        ],
      ),

      body: FutureBuilder<List<Recipe>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return ErrorView(
              message: 'Gagal memuat resep.\n${snapshot.error}',
              onRetry: _reload,
            );
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return const Center(
              child: Text('Belum ada resep.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: _isGrid
                ? _buildGrid(recipes)
                : _buildList(recipes),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah resep',
        onPressed: _openAddPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeTile(recipe: recipes[index]);
      },
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeGridCard(recipe: recipes[index]);
      },
    );
  }
}
