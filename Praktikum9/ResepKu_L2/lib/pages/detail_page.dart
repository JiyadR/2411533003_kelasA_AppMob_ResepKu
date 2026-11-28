
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:resepku_l2/models/recipe.dart';
import 'package:resepku_l2/providers/favorite_provider.dart';
import 'package:resepku_l2/services/recipe_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _servings;

  // Menyimpan nama resep yang sedang ditampilkan.
  late String _recipeName;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
    _recipeName = widget.recipe.name;
  }

  void _addServing() {
    setState(() => _servings++);
  }

  void _removeServing() {
    if (_servings > 1) {
      setState(() => _servings--);
    }
  }

  /// Menampilkan dialog untuk mengubah nama resep.
  Future<void> _editRecipeName() async {
    final controller = TextEditingController(text: _recipeName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ubah Nama Resep'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nama resep',
              hintText: 'Masukkan nama resep baru',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              Navigator.pop(dialogContext, value.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  controller.text.trim(),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    // Memastikan halaman masih aktif setelah await.
    if (!mounted) return;

    // Pengguna membatalkan dialog.
    if (newName == null) return;

    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama resep tidak boleh kosong.'),
        ),
      );
      return;
    }

    try {
      // Mengirim perubahan nama ke RecipeService.
      final updatedRecipe = await context
          .read<RecipeService>()
          .updateRecipe(
            id: widget.recipe.id,
            name: trimmedName,
          );

      // Memeriksa mounted setelah await.
      if (!mounted) return;

      // Memperbarui nama pada halaman detail.
      setState(() {
        _recipeName = updatedRecipe.name;
      });

      // Menampilkan nama dari respons server.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nama resep berhasil diubah menjadi '
            '"${updatedRecipe.name}".',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah nama resep: $error'),
        ),
      );
    }
  }

  /// Menampilkan dialog konfirmasi sebelum menghapus resep.
  Future<void> _confirmDeleteRecipe() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Resep'),
          content: Text(
            'Apakah Anda yakin ingin menghapus resep '
            '"$_recipeName"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // Memastikan halaman masih aktif setelah await.
    if (!mounted) return;

    // Jika pengguna membatalkan penghapusan.
    if (confirmed != true) return;

    try {
      // Mengirim permintaan DELETE ke RecipeService.
      final isDeleted = await context
          .read<RecipeService>()
          .deleteRecipe(widget.recipe.id);

      // Memeriksa mounted setelah await.
      if (!mounted) return;

      if (isDeleted) {
        // Menampilkan notifikasi keberhasilan.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil dihapus.'),
          ),
        );

        // Menutup halaman detail.
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Server tidak mengonfirmasi penghapusan resep.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus resep: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final totalCalories = recipe.caloriesPerServing * _servings;

    final isFavorite =
        context.watch<FavoriteProvider>().isFavorite(recipe);

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            actions: [
              // Tombol favorit yang sudah ada.
              IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                onPressed: () =>
                    context.read<FavoriteProvider>().toggle(recipe),
              ),

              // Menu untuk mengubah dan menghapus resep.
              PopupMenuButton<String>(
                tooltip: 'Menu resep',
                onSelected: (value) {
                  if (value == 'edit') {
                    _editRecipeName();
                  } else if (value == 'delete') {
                    _confirmDeleteRecipe();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 12),
                        Text('Ubah nama'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'Hapus resep',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_recipeName),
              background: CachedNetworkImage(
                imageUrl: recipe.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => ColoredBox(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  child: const Center(
                    child: Icon(Icons.restaurant_menu),
                  ),
                ),
                errorWidget: (context, url, error) => Image.asset(
                  'assets/images/placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${recipe.cuisine} • ${recipe.difficulty} • '
                    '${recipe.totalTimeMinutes} menit',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Text('Porsi', style: textTheme.titleMedium),
                          const Spacer(),
                          IconButton.filledTonal(
                            onPressed:
                                _servings > 1 ? _removeServing : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Text(
                              '$_servings',
                              style: textTheme.titleLarge,
                            ),
                          ),
                          IconButton.filledTonal(
                            onPressed: _addServing,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total kalori: $totalCalories kkal',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text('Bahan', style: textTheme.titleLarge),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverList.builder(
              itemCount: recipe.ingredients.length,
              itemBuilder: (context, index) {
                final item = recipe.ingredients[index];

                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline),
                  title: Text(item),
                );
              },
            ),
          ),

          if (recipe.instructions.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: Text(
                  'Langkah',
                  style: textTheme.titleLarge,
                ),
              ),
            ),

          SliverList.builder(
            itemCount: recipe.instructions.length,
            itemBuilder: (context, index) => ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 12,
                child: Text('${index + 1}'),
              ),
              title: Text(recipe.instructions[index]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
