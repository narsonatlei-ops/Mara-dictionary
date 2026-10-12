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
  // FlutterTTS hmanrua
  final FlutterTts _flutterTts = FlutterTts();
  bool _isFavorited = false;

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  void _speak(String text) async {
    await _flutterTts.setSpeechRate(0.5);
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706), // Warm Amber / Gold badge
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                cleanToken,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
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

    const navyButtonColor = Color(0xFF13263B);
    const goldAccent = Color(0xFFDFBA7B);

    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2C2C2C);
    final subtitleColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumal fiahna bawm
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: goldAccent.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                blurRadius: 10,
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

                  // LOVE (Heart) Icon
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isFavorited = !_isFavorited;
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
                      color: _isFavorited ? Colors.redAccent : goldAccent,
                      size: 28,
                    ),
                  ),
                ],
              ),
              if (widget.word.synonyms.isNotEmpty ||
                  widget.word.antonyms.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    height: 1,
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                  ),
                ),
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
        Row(
          children: [
            // VOICE
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyButtonColor,
                  foregroundColor: goldAccent,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: goldAccent.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                icon: const Icon(Icons.volume_up, size: 22, color: goldAccent),
                label: const Text(
                  'VOICE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                onPressed: () => _speak(widget.word.word),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: navyButtonColor,
                  foregroundColor: goldAccent,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(
                      color: goldAccent.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                ),
                icon: const Icon(Icons.share, size: 22, color: goldAccent),
                label: const Text(
                  'SHARE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
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
