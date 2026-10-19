import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/word_model.dart';
import '../providers/theme_provider.dart';
import '../screens/about_developer_screen.dart';
import '../screens/about_screen.dart';
import '../screens/browse_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/history_screen.dart';
import '../screens/info_screen.dart';
import '../utils/database_helper.dart';

class HomeDrawer extends StatelessWidget {
  final Function(WordModel) onWordSelected;

  const HomeDrawer({super.key, required this.onWordSelected});

  // Close the drawer, then open a screen
  void _open(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final headerColor = Provider.of<ThemeProvider>(context).headerColor;

    final drawerBgColor = isDarkMode
        ? const Color(0xFF121212)
        : const Color(0xFFF5EFEB);
    final textColor = theme.colorScheme.onSurface;
    const goldAccent = Color(0xFFDFBA7B);

    Widget item(IconData icon, String title, VoidCallback onTap) {
      return ListTile(
        leading: Icon(icon, color: goldAccent),
        title: Text(title, style: TextStyle(color: textColor)),
        onTap: onTap,
      );
    }

    return Drawer(
      backgroundColor: drawerBgColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  headerColor,
                  Color.lerp(headerColor, Colors.black, 0.35)!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            currentAccountPicture: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: goldAccent, width: 2),
              ),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/profile.jpeg'),
              ),
            ),
            accountName: const Text(
              'P.T Hlychho',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: goldAccent,
              ),
            ),
            accountEmail: const Text(
              '(12.06.1947)',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: goldAccent),
            title: const Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.bold, color: goldAccent),
            ),
            selected: true,
            selectedTileColor: goldAccent.withValues(alpha: 0.1),
            onTap: () => Navigator.pop(context),
          ),
          item(
            Icons.person_outline,
            'P.T Hlychho',
            () => _open(context, const AboutScreen()),
          ),
          item(
            Icons.code,
            'About Developer',
            () => _open(context, const AboutDeveloperScreen()),
          ),
          item(
            Icons.bug_report_outlined,
            'Report Error/Contact',
            () => _open(context, const ContactScreen()),
          ),
          item(
            Icons.search,
            'Browse Words',
            () => _open(context, const BrowseScreen()),
          ),
          item(
            Icons.history,
            'Search History',
            () => _open(context, const HistoryScreen()),
          ),
          item(
            Icons.favorite_border,
            'Favorites',
            () => _open(context, const FavoritesScreen()),
          ),
          item(
            Icons.info_outline,
            'Info',
            () => _open(context, const InfoScreen()),
          ),
          item(Icons.casino_outlined, 'Random Word', () async {
            final messenger = ScaffoldMessenger.of(context);
            Navigator.pop(context);
            final randomWord = await DatabaseHelper.instance.getRandomWord();
            if (randomWord != null) {
              onWordSelected(randomWord);
            } else {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('No words found in the database.'),
                ),
              );
            }
          }),
          item(Icons.thumb_up_alt_outlined, 'Rate Me', () {
            final messenger = ScaffoldMessenger.of(context);
            Navigator.pop(context);
            // The app is not on the Play Store yet.
            // After publishing, open the store page here with url_launcher.
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Rating will be available on the Play Store.'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
