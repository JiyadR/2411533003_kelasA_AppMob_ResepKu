import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku_c1/pages/home_page.dart';
import 'package:resepku_c1/providers/favorite_provider.dart';
import 'package:resepku_c1/providers/settings_provider.dart';
import 'package:resepku_c1/services/recipe_service.dart';
import 'package:resepku_c1/widgets/identity_footer.dart';

Future<void> main() async {
  // Wajib sebelum memakai plugin di dalam main
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(
          create: (context) => FavoriteProvider(),
        ),
        // Provider biasa: RecipeService tidak berubah, jadi tidak perlu notifyListeners
        Provider(
          create: (context) => RecipeService(),
          dispose: (context, service) => service.close(),
        ),
      ],
      child: const resepku_c1App(),
    ),
  );
}

class resepku_c1App extends StatelessWidget {
  const resepku_c1App({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<SettingsProvider>().themeMode;

    return MaterialApp(
      title: 'resepku_c1',
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
