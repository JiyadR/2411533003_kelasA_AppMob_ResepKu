import 'package:flutter/material.dart';
import 'package:resep_ku_c1/data/dummy_recipes.dart';
import 'package:resep_ku_c1/widgets/recipe_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ResepKu'),
      ),
      body: ListView(
        children: [
          for (final recipe in dummyRecipes) RecipeTile(recipe: recipe),
        ],
      ),
    );
  }
}