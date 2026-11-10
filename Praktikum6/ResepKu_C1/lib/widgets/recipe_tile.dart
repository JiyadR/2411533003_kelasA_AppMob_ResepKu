import 'package:flutter/material.dart';
import 'package:resep_ku_c1/models/recipe.dart';
import 'package:resep_ku_c1/pages/detail_page.dart';

class RecipeTile extends StatelessWidget {
  const RecipeTile({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(recipe.name[0])),
      title: Text(recipe.name),
      subtitle: Text(
        '${recipe.cuisine} • ${recipe.totalTimeMinutes} menit • ${recipe.rating}',
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailPage(recipe: recipe)),
      ),
    );
  }
}