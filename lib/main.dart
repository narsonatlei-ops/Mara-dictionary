import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider kan import belh e
import 'package:mara_dictionary/screens/home_screen.dart';
import 'package:mara_dictionary/providers/theme_provider.dart'; // I file siam thar kha kan import bawk e

void main() {
  runApp(
    // App pum puiah ThemeProvider kan thlung lût a ni
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tah hian Dark Mode leh Theme Palette rawng kan lo ngaichang reng dâwn a ni
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Mara Dictionary',
      debugShowCheckedModeBanner: false,

      // Hei hian Dark Mode leh Light Mode in-switch dan a thunun thlap ang
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 1. LIGHT MODE THEME (Theme Palette-a rawng i thlan apiang khan a in-change tawh ang)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider
              .primaryColor, // Rawng thlan sa ni lovin, Provider ami kan hmang ta e
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),

      // 2. DARK MODE THEME
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider
              .primaryColor, // Dark mode-ah pawh primary seed color atan a hman theih nghal
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),

      home: const HomeScreen(),
    );
  }
}
