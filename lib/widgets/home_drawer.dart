import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/about_developer_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/browse_screen.dart';
import '../screens/history_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/info_screen.dart';
import '../models/word_model.dart';
import '../utils/database_helper.dart';

class HomeDrawer extends StatelessWidget {
  final Color primaryColor;
  final Color textColor;
  final Function(WordModel) onWordSelected;

  const HomeDrawer({
    super.key,
    required this.primaryColor,
    required this.textColor,
    required this.onWordSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/profile.jpeg'),
            ),
            accountName: const Text(
              'P.T Hlychho',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: const Text('(12.06.1947)'),
          ),
          ListTile(
            leading: Icon(Icons.home, color: primaryColor),
            title: Text(
              'Home',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            selected: true,
            selectedTileColor: primaryColor.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.grey),
            title: Text('P.T Hlychho', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.code, color: Colors.grey),
            title: Text('About Developer', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutDeveloperScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined, color: Colors.grey),
            title: Text(
              'Report Error/Contact',
              style: TextStyle(color: textColor),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.grey),
            title: Text('Browse Words', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BrowseScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text('Search History', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border, color: Colors.grey),
            title: Text('Favorites', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.grey),
            title: Text('Info', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.casino_outlined, color: Colors.grey),
            title: Text('Random Word', style: TextStyle(color: textColor)),
            onTap: () async {
              Navigator.pop(context);
              final randomWord = await DatabaseHelper.instance.getRandomWord();

              if (randomWord != null) {
                onWordSelected(randomWord);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database-lia mohchho y tlâ mah vei!'),
                    ),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.thumb_up_alt_outlined,
              color: Colors.grey,
            ),
            title: Text('Rate Me', style: TextStyle(color: textColor)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
