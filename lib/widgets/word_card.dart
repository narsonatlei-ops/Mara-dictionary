import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/word_model.dart';


class WordCard extends StatefulWidget {
  final WordModel word;

  const WordCard({super.key, required this.word});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  // FlutterTTS hmanrua kan din thar e
  final FlutterTts _flutterTts = FlutterTts();

  // Favorite thlan leh thlan loh chhinchhiahna variable
  bool _isFavorited = false;

  @override
  void dispose() {
    _flutterTts.stop(); // App kan tih hlum rualin voice kan ti hlum ve ang
    super.dispose();
  }

  // A taka thumal lam rikna function
  void _speak(String text) async {
    await _flutterTts.setSpeechRate(0.5); // Muang deuh zawk hlek turin
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  // A taka share-na function
  void _shareWord() {
    final String shareText =
        "Mara Dictionary:\n\n"
        "📖 Word: ${widget.word.word}\n"
        "💡 Meaning: ${widget.word.definition}";

    Share.share(shareText);
  }

  // Part of Speech lo thla hrang a, Orange Box-a khungna function
  Widget _buildDefinitionText(
    String word,
    String definitionText,
    Color textColor,
  ) {
    final List<String> posList = [
      'v.t.',
      'v.i.',
      'adj.',
      'n.',
      'adv.',
      'v.',
      'prep.',
      'conj.',
      'pron.',
      'interj.',
    ];

    List<String> tokens = definitionText.split(' ');
    List<InlineSpan> spans = [];

    // 1. Thumal hming (Word) - Bold in
    spans.add(
      TextSpan(
        text: word,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );

    // 2. A laia Colon mawi taka dahna
    spans.add(
      TextSpan(
        text: ' : ',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );

    // 3. Fiahna (Definition) ho kha mal te tein kan rual chhuak ang
    for (String token in tokens) {
      if (token.isEmpty) continue;

      String cleanToken = token.endsWith(',')
          ? token.substring(0, token.length - 1).trim()
          : token.trim();

      if (posList.contains(cleanToken)) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cleanToken,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );

        if (token.endsWith(',')) {
          spans.add(
            TextSpan(
              text: ', ',
              style: TextStyle(fontSize: 18, color: textColor),
            ),
          );
        } else {
          spans.add(const TextSpan(text: ' '));
        }
      } else {
        spans.add(
          TextSpan(
            text: '$token ',
            style: TextStyle(fontSize: 18, color: textColor, height: 1.5),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDarkMode
        ? const Color.fromARGB(255, 140, 15, 180)
        : const Color(0xFF1976D2);

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumal fiahna bawm
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildDefinitionText(
                      widget.word.word,
                      widget.word.definition,
                      textColor,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Star aiah LOVE (Heart) Icon function nei tawh thap kan dah ta e
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isFavorited =
                            !_isFavorited; // Hmet la a in-toggle pap pap ang
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFavorited
                                ? 'Added to Favorites!'
                                : 'Removed from Favorites!',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorited
                          ? Colors
                                .red // Favorite tawh chu a sen mawi takin a rawn lang ang
                          : (isDarkMode
                                ? Colors.white60
                                : Colors.grey.shade400),
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.word.synonyms.isNotEmpty)
                Text(
                  'Synonyms: ${widget.word.synonyms}',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: subtitleColor,
                  ),
                ),

              if (widget.word.antonyms.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Antonyms: ${widget.word.antonyms}',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: subtitleColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Button te
        Row(
          children: [
            // VOICE
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.volume_up, size: 20),
                label: const Text(
                  'VOICE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: () => _speak(widget.word.word),
              ),
            ),
            const SizedBox(width: 16),

            // SHARE
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.share, size: 20),
                label: const Text(
                  'SHARE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: _shareWord,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
