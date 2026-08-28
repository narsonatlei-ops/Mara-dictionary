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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: const Color(0xFF1976D2),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteWords.isEmpty
          ? const Center(
              child: Text(
                'Favorite mohchho y mah vei.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _favoriteWords.length,
              itemBuilder: (context, index) {
                final word = _favoriteWords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      word.word,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      word.definition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
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
