import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku_l3/providers/favorite_provider.dart';
import 'package:resepku_l3/providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmClearAll(BuildContext context) async {
    final favorites = context.read<FavoriteProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus semua favorit?'),
        content: Text('Semua ${favorites.count} favorit akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    // Batal ditekan, atau halaman sudah ditutup selama menunggu dialog
    if (confirmed != true || !context.mounted) return;
    final count = favorites.count;
    await favorites.clear();
    // Halaman sudah ditutup selama menunggu penghapusan
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count favorit telah dihapus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final favorites = context.watch<FavoriteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode gelap'),
            value: settings.isDark,
            onChanged: settings.setDark,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.grid_view),
            title: const Text('Tampilan grid'),
            subtitle: const Text('Daftar resep ditampilkan dalam dua kolom'),
            value: settings.isGrid,
            onChanged: settings.setGrid,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: const Text('Hapus semua favorit'),
            subtitle: Text('${favorites.count} resep tersimpan'),
            onTap: () => _confirmClearAll(context),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Pengaturan tersimpan di HP'),
            subtitle: Text('Pilihan tetap ada walaupun aplikasi ditutup.'),
          ),
        ],
      ),
    );
  }
}
