import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku_l2/pages/home_page.dart';
import 'package:resepku_l2/data/favorite_database.dart';
import 'package:resepku_l2/providers/favorite_provider.dart';
import 'package:resepku_l2/providers/settings_provider.dart';
import 'package:resepku_l2/services/recipe_service.dart';
import 'package:resepku_l2/widgets/identity_footer.dart';

Future<void> main() async {
  // Wajib sebelum memakai plugin di dalam main
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  final favorites = FavoriteProvider(FavoriteDatabase());
  await Future.wait([settings.load(), favorites.load()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: favorites),
        // Provider biasa: RecipeService tidak berubah, jadi tidak perlu notifyListeners
        Provider(
          create: (context) => RecipeService(),
          dispose: (context, service) => service.close(),
        ),
      ],
      child: const resepku_l2App(),
    ),
  );
}

class resepku_l2App extends StatelessWidget {
  const resepku_l2App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().themeMode;

    return MaterialApp(
      title: 'resepku_l2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      themeMode: themeMode,
      builder: (context, child) => IdentityFooter(
        child: child!,
      ),
      home: const HomePage(),
    );
  }
}
