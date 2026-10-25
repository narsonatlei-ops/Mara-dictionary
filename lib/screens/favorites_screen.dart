import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/word_model.dart';
import 'word_detail_page.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<WordModel> _favoriteWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Read the favorite words from the database
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getFavoriteWords();
    if (!mounted) return;
    setState(() {
      _favoriteWords = data;
      _isLoading = false;
    });
  }

  // Heart button: remove one word from the favorites
  Future<void> _removeFromFavorites(WordModel word) async {
    if (word.id == null) return;
    await DatabaseHelper.instance.updateFavoriteStatus(word.id!, 0);
    await _loadFavorites();
  }

  // App bar button: remove all words after the user confirms
  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all favorites'),
        content: const Text('Na favorite words nah na thy kho hmeisei?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear all',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await DatabaseHelper.instance.clearFavorites();
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    const goldAccent = Color(0xFFDFBA7B);

    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = theme.colorScheme.onSurface;
    final subtitleColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        actions: [
          if (_favoriteWords.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: goldAccent),
              tooltip: 'Clear all',
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteWords.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: goldAccent.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Favorite mohchho y mah vei.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              itemCount: _favoriteWords.length,
              itemBuilder: (context, index) {
                final word = _favoriteWords[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: goldAccent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDarkMode ? 0.2 : 0.04,
                        ),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      word.word,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: textColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        word.definition,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: subtitleColor),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                      onPressed: () => _removeFromFavorites(word),
                      tooltip: 'Remove from Favorites',
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WordDetailPage(word: word),
                        ),
                      );
                      // The heart may have changed on the detail page
                      _loadFavorites();
                    },
                  ),
                );
              },
            ),
    );
  }
}
