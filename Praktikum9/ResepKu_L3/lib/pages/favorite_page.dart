import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku_l3/models/favorite.dart';
import 'package:resepku_l3/pages/detail_page.dart';
import 'package:resepku_l3/providers/favorite_provider.dart';
import 'package:resepku_l3/providers/settings_provider.dart';
import 'package:resepku_l3/widgets/recipe_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  Future<void> _editNote(BuildContext context, Favorite item) async {
    final note = await showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(initial: item.note),
    );
    // null = Batal ditekan; halaman juga dapat sudah ditutup selama menunggu
    if (note == null || !context.mounted) return;
    await context
        .read<FavoriteProvider>()
        .updateNote(item.recipe.id, note.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        actions: [
          PopupMenuButton<FavoriteSort>(
            tooltip: 'Urutan favorit',
            icon: const Icon(Icons.sort),
            onSelected: (value) =>
                context.read<SettingsProvider>().setSort(value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: FavoriteSort.newest,
                child: Text('Terbaru disimpan'),
              ),
              PopupMenuItem(
                value: FavoriteSort.name,
                child: Text('Nama A–Z'),
              ),
            ],
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
          final sort = context.watch<SettingsProvider>().sort;
          // Salinan list, bukan list milik provider
          final items = [...favorite.items];
          if (sort == FavoriteSort.name) {
            items.sort((a, b) => a.recipe.name.compareTo(b.recipe.name));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final recipe = item.recipe;
              final textTheme = Theme.of(context).textTheme;
              return Dismissible(
                key: ValueKey(recipe.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  favorite.toggle(recipe);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${recipe.name} dihapus dari favorit')),
                  );
                },
                // ListTile dipakai hanya jika trailing kecil. Di sini aksi
                // ada 3, jadi dipasang di bawah subtitle agar judul tetap
                // mendapat lebar penuh dan tidak terpotong per suku kata.
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(recipe: recipe),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: RecipeImage(
                              url: recipe.image,
                              cacheWidth: 168,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Expanded: kolom ini mendapat sisa lebar baris
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item.note.isEmpty ? 'Belum ada catatan' : item.note} • Dimasak ${item.cookedCount} kali',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                    ),
                                    onPressed: () =>
                                        favorite.incrementCooked(recipe.id),
                                    child: const Text('Sudah dimasak'),
                                  ),
                                  IconButton(
                                    tooltip: 'Catatan',
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.edit_note),
                                    onPressed: () => _editNote(context, item),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus dari favorit',
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => favorite.toggle(recipe),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Dialog catatan. StatefulWidget agar dapat membuat dan men-dispose
/// TextEditingController miliknya sendiri.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan pribadi'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Contoh: kurangi garam'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
