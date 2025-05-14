import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/navigation/responsive_scaffold.dart';
import 'features/cuisines/providers/recipe_provider.dart';

void main() {
  runApp(const CuisinesApp());
}

class CuisinesApp extends StatelessWidget {
  const CuisinesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
      child: MaterialApp(
      title: 'Cuisines',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF3D5A80),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF3D5A80),
          secondary: const Color(0xFFEE6C4D),
          tertiary: const Color(0xFF98C1D9),
          background: const Color(0xFFE0FBFC),
          surface: Colors.white,
        ),
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF3D5A80),
          elevation: 0,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          margin: const EdgeInsets.all(8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3D5A80),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF293241)),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF293241)),
          titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF293241)),
          titleMedium: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF3D5A80)),
          bodyLarge: TextStyle(color: Color(0xFF293241)),
          bodyMedium: TextStyle(color: Color(0xFF3D5A80)),
        ),
      ),
      home: const ResponsiveScaffold(),
      debugShowCheckedModeBanner: false,
      ),
    );
  }
}
