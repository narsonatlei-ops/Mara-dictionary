import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/word_model.dart';
import '../providers/theme_provider.dart';
import '../utils/database_helper.dart';

class WordCard extends StatefulWidget {
  final WordModel word;

  const WordCard({super.key, required this.word});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isFavorited = false;

  // Part-of-speech labels shown as badges
  static const List<String> _posList = [
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

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  @override
  void didUpdateWidget(covariant WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.id != widget.word.id) _loadFavorite();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  // Read the saved favorite status from the database
  Future<void> _loadFavorite() async {
    final id = widget.word.id;
    if (id == null) return;
    final fav = await DatabaseHelper.instance.isWordFavorited(id);
    if (mounted) setState(() => _isFavorited = fav);
  }

  // Heart button: save or remove the favorite in the database
  Future<void> _toggleFavorite() async {
    final id = widget.word.id;
    if (id == null) return;
    final newStatus = !_isFavorited;
    await DatabaseHelper.instance.updateFavoriteStatus(id, newStatus ? 1 : 0);
    if (!mounted) return;
    setState(() => _isFavorited = newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus ? 'Added to Favorites!' : 'Removed from Favorites!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // VOICE button: pronounce the English word at the speed chosen in Settings
  Future<void> _speak(String text) async {
    final rate = Provider.of<ThemeProvider>(context, listen: false).speechRate;
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      if (text.isNotEmpty) await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Speech error: $e');
    }
  }

  void _shareWord() {
    Share.share(
      "Mara Dictionary:\n\n"
      "Word: ${widget.word.word}\n"
      "Meaning: ${widget.word.definition}",
    );
  }

  Widget _buildDefinitionText(Color textColor) {
    final spans = <InlineSpan>[
      TextSpan(
        text: '${widget.word.word} : ',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    ];

    for (final token in widget.word.definition.split(' ')) {
      if (token.isEmpty) continue;

      final hasComma = token.endsWith(',');
      final cleanToken = hasComma
          ? token.substring(0, token.length - 1).trim()
          : token.trim();

      if (_posList.contains(cleanToken)) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706),
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
        spans.add(TextSpan(text: hasComma ? ', ' : ' '));
      } else {
        spans.add(
          TextSpan(
            text: '$token ',
            style: TextStyle(fontSize: 18, color: textColor, height: 1.5),
          ),
        );
      }
    }

    // Text.rich follows the font size chosen in Settings
    return Text.rich(TextSpan(children: spans));
  }

  // One line for synonyms or antonyms: the label is italic, the words are bold
  Widget _relatedWords(
    String label,
    String words,
    Color labelColor,
    Color wordsColor,
  ) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(fontStyle: FontStyle.italic, color: labelColor),
          ),
          TextSpan(
            text: words,
            style: TextStyle(fontWeight: FontWeight.bold, color: wordsColor),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 17, height: 1.4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = Provider.of<ThemeProvider>(context).headerColor;
    const goldAccent = Color(0xFFDFBA7B);

    final cardBgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2C2C2C);
    final subtitleColor = isDarkMode ? Colors.white60 : Colors.black54;

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: goldAccent,
      elevation: 3,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: goldAccent.withValues(alpha: 0.4), width: 1),
      ),
    );
    const labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
      letterSpacing: 0.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  Expanded(child: _buildDefinitionText(textColor)),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _toggleFavorite,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    height: 1,
                    color: isDarkMode ? Colors.white12 : Colors.black12,
                  ),
                ),
              if (widget.word.synonyms.isNotEmpty)
                _relatedWords(
                  'Synonyms:',
                  widget.word.synonyms,
                  subtitleColor,
                  textColor,
                ),
              if (widget.word.antonyms.isNotEmpty) ...[
                const SizedBox(height: 10),
                _relatedWords(
                  'Antonyms:',
                  widget.word.antonyms,
                  subtitleColor,
                  textColor,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: buttonStyle,
                icon: const Icon(Icons.volume_up, size: 22),
                label: const Text('VOICE', style: labelStyle),
                onPressed: () => _speak(widget.word.word),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: buttonStyle,
                icon: const Icon(Icons.share, size: 22),
                label: const Text('SHARE', style: labelStyle),
                onPressed: _shareWord,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
