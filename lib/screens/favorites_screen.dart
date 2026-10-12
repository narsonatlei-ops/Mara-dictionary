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

  // Database aṭanga favorite thumalte rawn sawk chhuahna
  void _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    final data = await DatabaseHelper.instance.getFavoriteWords();

    setState(() {
      _favoriteWords = data;
      _isLoading = false;
    });
  }

  // Heart Icon hmeh laia favorite aṭanga va paih (remove) na
  Future<void> _removeFromFavorites(WordModel word) async {
    if (word.id != null) {
      await DatabaseHelper.instance.updateFavoriteStatus(word.id!, 0);
      _loadFavorites(); // Database update hnuah screen a refresh nghal ang
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    const navyPrimary = Color(0xFF13263B);
    const goldAccent = Color(0xFFDFBA7B);

    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2C2C2C);
    final subtitleColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(color: goldAccent, fontWeight: FontWeight.bold),
        ),
        backgroundColor: navyPrimary,
        iconTheme: const IconThemeData(color: goldAccent),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: goldAccent))
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
                      // Detail Page-ah a va kal ang
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WordDetailPage(word: word),
                        ),
                      );
                      // Detail Page aṭanga i kir leh tikah favorites list hi a rawn refresh nawn nghal ang
                      _loadFavorites();
                    },
                  ),
                );
              },
            ),
    );
  }
}
