import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku_c2/providers/favorite_provider.dart';
import 'package:resepku_c2/widgets/recipe_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        // Modul 9 Bagian B: tombol Hapus semua dikomentari dulu karena
        // FavoriteProvider versi database belum memiliki clear().
        // clear() dibuat ulang dengan database pada Latihan 2 modul ini.
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
          final items = favorite.items;
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index]; // diubah: kini Favorite
              final recipe = item.recipe; // baru: resep di dalam Favorite
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

  // Modul 9 Bagian B: dikomentari dulu, karena FavoriteProvider versi
  // database belum memiliki clear(). Dibuat ulang pada Latihan 2.
  // void _showDeleteAllDialog(BuildContext context, FavoriteProvider favorite) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Hapus Semua Favorit'),
  //       content: const Text(
  //         'Apakah Anda yakin ingin menghapus semua resep dari daftar favorit?',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Batal'),
  //         ),
  //         FilledButton(
  //           onPressed: () {
  //             favorite.clear();
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Hapus'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}