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
import '../screens/news_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/app_info.dart';
import '../utils/database_helper.dart';
import '../utils/news_service.dart';

class HomeDrawer extends StatelessWidget {
  final Function(WordModel) onWordSelected;

  const HomeDrawer({super.key, required this.onWordSelected});

  // Close the drawer, then open a screen
  void _open(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _randomWord(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    final word = await DatabaseHelper.instance.getRandomWord();
    if (word != null) {
      onWordSelected(word);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('No words found in the database.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<ThemeProvider>(context);
    final headerColor = settings.headerColor;
    const gold = Color.fromARGB(255, 234, 185, 100);

    // Colour of the icons and of the selected item
    const accent = Color.fromARGB(255, 241, 183, 83);
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFFAF8F5);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    Widget section(String label) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
      );
    }

    Widget item(
      IconData icon,
      String title,
      VoidCallback onTap, {
      bool selected = false,
      Widget? trailing,
    }) {
      return _DrawerItem(
        icon: icon,
        title: title,
        onTap: onTap,
        accent: accent,
        selected: selected,
        trailing: trailing,
      );
    }

    return Drawer(
      width: 304,
      backgroundColor: bg,
      child: Column(
        children: [
          // ---------------- header: tap to read about the author ----------------
          Ink(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  headerColor,
                  Color.lerp(headerColor, Colors.black, 0.3)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: InkWell(
              onTap: () => _open(context, const AboutScreen()),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  MediaQuery.of(context).padding.top + 24,
                  22,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('assets/profile.jpeg'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'P.T Hlychho',
                      style: TextStyle(
                        color: gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '(12.06.1947)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Author of the dictionary',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------------- menu ----------------
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              children: [
                item(
                  Icons.home_outlined,
                  'Home',
                  () => Navigator.pop(context),
                  selected: true,
                ),

                section('Dictionary'),
                item(
                  Icons.sort_by_alpha,
                  'Browse Words',
                  () => _open(context, const BrowseScreen()),
                ),
                item(
                  Icons.casino_outlined,
                  'Random Word',
                  () => _randomWord(context),
                ),
                item(
                  Icons.history,
                  'History',
                  () => _open(context, const HistoryScreen()),
                ),
                item(
                  Icons.favorite_border,
                  'Favorites',
                  () => _open(context, const FavoritesScreen()),
                ),

                section('Learn'),
                item(
                  Icons.menu_book_outlined,
                  'Info & Guide',
                  () => _open(context, const InfoScreen()),
                ),
                item(
                  Icons.notifications_none,
                  'News',
                  () => _open(context, const NewsScreen()),
                  trailing: ValueListenableBuilder<int>(
                    valueListenable: NewsService.unread,
                    builder: (context, count, _) {
                      if (count == 0) return const SizedBox.shrink();
                      return Badge(label: Text('$count'));
                    },
                  ),
                ),

                section('About'),
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
              ],
            ),
          ),

          // ---------------- settings and footer ----------------
          Divider(
            height: 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: item(
              Icons.settings_outlined,
              'Settings',
              () => _open(context, const SettingsScreen()),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              6,
              24,
              MediaQuery.of(context).padding.bottom + 14,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Version ${AppInfo.version}\n'
                'Dictionary content: P. T. Hlychho',
                style: TextStyle(fontSize: 12, height: 1.5, color: muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// One row of the menu: an icon in a rounded box, then the title
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color accent;
  final bool selected;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.accent,
    required this.selected,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selected ? accent : accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: selected ? Colors.white : accent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
