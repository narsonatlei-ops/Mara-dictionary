import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/word_model.dart';
import '../widgets/word_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final List<String> _alphabets = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  String? _selectedLetter;
  List<WordModel> _wordsByLetter = [];
  bool _isLoading = false;

  void _fetchWords(String letter) async {
    setState(() {
      _selectedLetter = letter;
      _isLoading = true;
    });

    final words = await DatabaseHelper.instance.getWordsByLetter(letter);

    setState(() {
      _wordsByLetter = words;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF6),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 192, 21, 239),
        title: Text(
          _selectedLetter == null
              ? 'Browse Words'
              : 'Words starting with "$_selectedLetter"',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 'onPressed' kan hmang tawh e, error a bo ang
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
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Category a tlyh ty:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
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
                    color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 192, 21, 239),
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
      return const Center(
        child: CircularProgressIndicator(
          color: Color.fromARGB(255, 192, 21, 239),
        ),
      );
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
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: const Color(0xFFFFFDF6),
                  appBar: AppBar(
                    backgroundColor: const Color.fromARGB(255, 192, 21, 239),
                    title: Text(wordData.word),
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: WordCard(word: wordData),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
