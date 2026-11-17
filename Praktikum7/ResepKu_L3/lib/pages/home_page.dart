import 'package:flutter/material.dart';
import 'package:resepku_l3/data/dummy_recipes.dart';
import 'package:resepku_l3/models/recipe.dart';
import 'package:resepku_l3/pages/settings_page.dart';
import 'package:resepku_l3/widgets/favorite_badge_button.dart';
import 'package:resepku_l3/widgets/recipe_grid_card.dart';
import 'package:resepku_l3/widgets/recipe_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false; // ephemeral state: hanya HomePage yang membutuhkan
  String? _cuisine; // null berarti semua cuisine

  @override
  Widget build(BuildContext context) {
    final cuisines = dummyRecipes.map((r) => r.cuisine).toSet();
    final filteredRecipes = _cuisine == null
        ? dummyRecipes
        : dummyRecipes.where((r) => r.cuisine == _cuisine).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('resepku_l3'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : 'Tampilan grid',
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          const FavoriteBadgeButton(),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: _cuisine == null,
                    onSelected: (_) => setState(() => _cuisine = null),
                  ),
                ),
                for (final cuisine in cuisines)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cuisine),
                      selected: _cuisine == cuisine,
                      onSelected: (selected) => setState(
                        () => _cuisine = selected ? cuisine : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isGrid
                ? _buildGrid(filteredRecipes)
                : _buildList(filteredRecipes),
          ),
        ],
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
        childAspectRatio: 3 / 4, // lebar : tinggi
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeGridCard(recipe: recipes[index]);
      },
    );
  }
}