import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../utils/database_helper.dart';
import '../utils/synonym_service.dart';

class WordDetailPage extends StatefulWidget {
  final WordModel word;
  const WordDetailPage({super.key, required this.word});

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  bool isFavorite = false;
  String synonyms = '';
  String antonyms = '';
  bool isLoadingApi = false;

  @override
  void initState() {
    super.initState();
    synonyms = widget.word.synonyms;
    antonyms = widget.word.antonyms;

    _checkFavoriteStatus();
    _addToHistory();

    // Call the API only when nothing is saved for this word yet
    if (synonyms.trim().isEmpty && antonyms.trim().isEmpty) {
      _fetchSynonymsAndAntonyms();
    }
  }

  // Every way of opening a word (Browse, Favorites, History) is recorded
  void _addToHistory() {
    final id = widget.word.id;
    if (id != null) {
      DatabaseHelper.instance.addToHistory(
        id,
        widget.word.word,
        widget.word.definition,
      );
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final id = widget.word.id;
    if (id == null) return;
    final status = await DatabaseHelper.instance.isWordFavorited(id);
    if (mounted) setState(() => isFavorite = status);
  }

  Future<void> _fetchSynonymsAndAntonyms() async {
    setState(() => isLoadingApi = true);

    final result = await SynonymService.fetch(widget.word.word);

    // Save in SQLite so the next visit works offline
    if (result != null &&
        (result.synonyms.isNotEmpty || result.antonyms.isNotEmpty) &&
        widget.word.id != null) {
      await DatabaseHelper.instance.updateWordSynAnt(
        widget.word.id!,
        result.synonyms,
        result.antonyms,
      );
    }

    if (!mounted) return;
    setState(() {
      synonyms = result?.synonyms ?? '';
      antonyms = result?.antonyms ?? '';
      isLoadingApi = false;
    });
  }

  Future<void> _toggleFavorite() async {
    final id = widget.word.id;
    if (id == null) return;

    final newStatus = !isFavorite;
    await DatabaseHelper.instance.updateFavoriteStatus(id, newStatus ? 1 : 0);

    if (!mounted) return;
    setState(() => isFavorite = newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus ? 'Added to Favorites!' : 'Removed from Favorites!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _relatedWords(
    IconData icon,
    Color color,
    String title,
    String words,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40, thickness: 1),
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          words,
          style: TextStyle(
            fontSize: 16,
            color: textColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.colorScheme.onSurface;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      // App bar and background colours come from the app theme (main.dart);
      // the font size follows Settings through the text scaler in main.dart.
      appBar: AppBar(
        title: Text(widget.word.word),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.word.word,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Divider(height: 30, thickness: 1.5),
                Text(
                  'Meaning:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.word.definition,
                  style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
                ),
                if (isLoadingApi) ...[
                  const SizedBox(height: 25),
                  const Center(child: CircularProgressIndicator()),
                ],
                if (!isLoadingApi && synonyms.isNotEmpty)
                  _relatedWords(
                    Icons.link,
                    Colors.green,
                    'Synonyms:',
                    synonyms,
                    textColor,
                  ),
                if (!isLoadingApi && antonyms.isNotEmpty)
                  _relatedWords(
                    Icons.compare_arrows,
                    Colors.red,
                    'Antonyms:',
                    antonyms,
                    textColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
