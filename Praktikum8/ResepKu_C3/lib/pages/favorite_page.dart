import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku_c3/providers/favorite_provider.dart';
import 'package:resepku_c3/widgets/recipe_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        actions: [
          Consumer<FavoriteProvider>(
            builder: (context, favorite, child) {
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'Hapus semua',
                onPressed: favorite.count == 0
                    ? null
                    : () => _showDeleteAllDialog(context, favorite),
              );
            },
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favorite, child) {
          if (favorite.count == 0) {
            return const Center(
              child: Text(
                'Belum ada resep favorit.\nTekan ikon hati di daftar resep.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            itemCount: favorite.items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final recipe = favorite.items[index];
              return Dismissible(
                key: ValueKey(recipe.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  favorite.toggle(recipe);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('${recipe.name} dihapus dari favorit'),
                      ),
                    );
                },
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: RecipeImage(url: recipe.image, cacheWidth: 168),
                    ),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(recipe.cuisine),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => favorite.toggle(recipe),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, FavoriteProvider favorite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Favorit'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua resep dari daftar favorit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              favorite.clear();
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}