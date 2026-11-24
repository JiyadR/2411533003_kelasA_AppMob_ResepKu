import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku_c1/pages/home_page.dart';
import 'package:resepku_c1/providers/favorite_provider.dart';
import 'package:resepku_c1/providers/theme_provider.dart';
import 'package:resepku_c1/services/recipe_service.dart';
import 'package:resepku_c1/widgets/identity_footer.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FavoriteProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        Provider(
          create: (context) => RecipeService(),
          dispose: (context, service) => service.close(),
        ),
      ],
      child: const ResepKu_c1App(),
    ),
  );
}

class ResepKu_c1App extends StatelessWidget {
  const ResepKu_c1App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResepKu_c1',
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
      themeMode: context.watch<ThemeProvider>().themeMode,
      builder: (context, child) => IdentityFooter(
        child: child!,
      ),
      home: const HomePage(),
    );
  }
}