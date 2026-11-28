import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Urutan favorit di halaman Favorit (Latihan 1).
enum FavoriteSort { newest, name }

/// Pengaturan aplikasi yang disimpan di HP dengan SharedPreferencesAsync.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({SharedPreferencesAsync? prefs})
      : _prefs = prefs ?? SharedPreferencesAsync();

  static const keyGrid = 'is_grid';
  static const keyDark = 'is_dark';
  static const keySort = 'favorite_sort';

  final SharedPreferencesAsync _prefs;

  // Nilai saat ini disimpan di field agar build() dapat membacanya tanpa await
  bool _isGrid = false;
  bool _isDark = false;
  FavoriteSort _sort = FavoriteSort.newest;

  bool get isGrid => _isGrid;
  bool get isDark => _isDark;
  FavoriteSort get sort => _sort;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  /// Dipanggil sekali di main, sebelum runApp.
  Future<void> load() async {
    // null berarti key belum pernah disimpan (pembukaan pertama)
    _isGrid = await _prefs.getBool(keyGrid) ?? false;
    _isDark = await _prefs.getBool(keyDark) ?? false;
    _sort = FavoriteSort.values.asNameMap()[await _prefs.getString(keySort)] ??
        FavoriteSort.newest;
    notifyListeners();
  }

  Future<void> setGrid(bool value) async {
    _isGrid = value;
    notifyListeners(); // tampilan berubah lebih dulu
    await _prefs.setBool(keyGrid, value); // lalu disimpan
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    notifyListeners();
    await _prefs.setBool(keyDark, value);
  }

  Future<void> setSort(FavoriteSort value) async {
    _sort = value;
    notifyListeners(); // tampilan berubah lebih dulu
    await _prefs.setString(keySort, value.name); // lalu disimpan
  }
}
