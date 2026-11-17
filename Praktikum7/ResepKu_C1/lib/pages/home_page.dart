import 'package:flutter/material.dart';
import 'package:resepku_c1/data/dummy_recipes.dart';
import 'package:resepku_c1/pages/settings_page.dart';
import 'package:resepku_c1/widgets/favorite_badge_button.dart';
import 'package:resepku_c1/widgets/recipe_tile.dart';

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
            const Text('ResepKu'),
          ],
        ),
        actions: [
          const FavoriteBadgeButton(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          for (final recipe in dummyRecipes) RecipeTile(recipe: recipe),
        ],
      ),
    );
  }
}