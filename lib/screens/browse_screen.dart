import 'package:flutter/material.dart';
import '../models/word_model.dart';
import '../utils/database_helper.dart';
import 'word_detail_page.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<String> _alphabets = List.generate(
    26,
    (i) => String.fromCharCode(65 + i),
  );

  String? _selectedLetter;
  List<WordModel> _wordsByLetter = [];
  bool _isLoading = false;

  Future<void> _fetchWords(String letter) async {
    setState(() {
      _selectedLetter = letter;
      _isLoading = true;
    });

    final words = await DatabaseHelper.instance.getWordsByLetter(letter);
    if (!mounted) return;

    setState(() {
      _wordsByLetter = words;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLetter == null
              ? 'Browse Words'
              : 'Words starting with "$_selectedLetter"',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Word list -> letter grid -> leave the screen
            if (_selectedLetter != null) {
              setState(() {
                _selectedLetter = null;
                _wordsByLetter = [];
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: _selectedLetter == null ? _buildAlphabetGrid() : _buildWordsList(),
    );
  }

  Widget _buildAlphabetGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Category a tlyh ty:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _alphabets.length,
            itemBuilder: (context, index) {
              final letter = _alphabets[index];
              return InkWell(
                onTap: () => _fetchWords(letter),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWordsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_wordsByLetter.isEmpty) {
      return Center(
        child: Text(
          ' "$_selectedLetter" hmâpata mohchho a thaopa y vei.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _wordsByLetter.length,
      itemBuilder: (context, index) {
        final wordData = _wordsByLetter[index];
        return ListTile(
          title: Text(
            wordData.word,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WordDetailPage(word: wordData)),
            );
          },
        );
      },
    );
  }
}
