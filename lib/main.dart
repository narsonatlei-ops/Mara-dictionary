import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mara_dictionary/screens/home_screen.dart';
import 'package:mara_dictionary/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeProvider = ThemeProvider();
  await themeProvider.loadSettings(); // saved settings are loaded first

  runApp(
    ChangeNotifierProvider.value(value: themeProvider, child: const MyApp()),
  );
}

ThemeData _buildTheme(ThemeProvider p, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: p.primaryColor,
      brightness: brightness,
    ),
    scaffoldBackgroundColor: isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5EFEB),
    appBarTheme: AppBarTheme(
      backgroundColor: p.headerColor,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Mara Dictionary',
      debugShowCheckedModeBanner: false,
      themeMode: p.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(p, Brightness.light),
      darkTheme: _buildTheme(p, Brightness.dark),
      // Font size from Settings scales all text in the whole app
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(p.fontSize / 16.0)),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
