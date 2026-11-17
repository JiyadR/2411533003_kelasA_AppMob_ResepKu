import 'package:flutter/material.dart';
import 'package:resepku_c2/data/dummy_recipes.dart';
import 'package:resepku_c2/pages/settings_page.dart';
import 'package:resepku_c2/widgets/favorite_badge_button.dart';
import 'package:resepku_c2/widgets/recipe_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('resepku_c2'),
          ],
        ),
        actions: [
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
      body: ListView.builder(
        itemCount: dummyRecipes.length,
        itemBuilder: (context, index) {
          return RecipeTile(recipe: dummyRecipes[index]);
        },
      ),
    );
  }
}