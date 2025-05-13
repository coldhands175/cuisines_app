import 'package:flutter/material.dart';
import 'features/navigation/responsive_scaffold.dart';

void main() {
  runApp(const CuisinesApp());
}

class CuisinesApp extends StatelessWidget {
  const CuisinesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuisines',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'SansSerif',
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          margin: const EdgeInsets.all(8),
        ),
      ),
      home: const ResponsiveScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}
