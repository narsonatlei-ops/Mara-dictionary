import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

import '../models/word_model.dart';
import '../providers/theme_provider.dart';
import '../utils/database_helper.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/word_card.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<WordModel> _suggestions = [];
  WordModel? _selectedWord;
  final TextEditingController _searchController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  Future<WordModel> _checkAndFetchData(WordModel word) async {
    if (word.synonyms.isEmpty && word.antonyms.isEmpty) {
      try {
        final synRes = await http.get(
          Uri.parse('https://api.datamuse.com/words?rel_syn=${word.word}'),
        );
        final antRes = await http.get(
          Uri.parse('https://api.datamuse.com/words?rel_ant=${word.word}'),
        );

        String synonymsList = '';
        String antonymsList = '';

        if (synRes.statusCode == 200) {
          List data = json.decode(synRes.body);
          synonymsList = data
              .take(4)
              .map((e) => e['word'].toString())
              .join(', ');
        }

        if (antRes.statusCode == 200) {
          List data = json.decode(antRes.body);
          antonymsList = data
              .take(4)
              .map((e) => e['word'].toString())
              .join(', ');
        }

        if (synonymsList.isNotEmpty || antonymsList.isNotEmpty) {
          if (word.id != null) {
            await DatabaseHelper.instance.updateWordSynAnt(
              word.id!,
              synonymsList,
              antonymsList,
            );
          }
          return WordModel(
            id: word.id,
            word: word.word,
            definition: word.definition,
            isFavorite: word.isFavorite,
            synonyms: synonymsList,
            antonyms: antonymsList,
          );
        }
      } catch (e) {
        debugPrint("Offline chy..: $e");
      }
    }
    return word;
  }

  void _selectWord(WordModel word) async {
    WordModel updatedWord = await _checkAndFetchData(word);

    if (!mounted) return;
    setState(() {
      _selectedWord = updatedWord;
      _searchController.text = updatedWord.word;
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();

    if (updatedWord.id != null) {
      await DatabaseHelper.instance.addToHistory(
        updatedWord.id!,
        updatedWord.word,
        updatedWord.definition,
      );
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening' || status == 'done') {
            if (mounted) setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) async {
            if (!mounted) return;
            setState(() {
              _searchController.text = result.recognizedWords;
            });

            final suggestions = await DatabaseHelper.instance.searchWords(
              result.recognizedWords,
            );

            setState(() {
              _suggestions = suggestions;
              _selectedWord = null;
            });

            if (result.finalResult && suggestions.isNotEmpty) {
              _selectWord(suggestions.first);
              if (mounted) setState(() => _isListening = false);
              _speech.stop();
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _selectedWord = null;
      });
      return;
    }

    final suggestions = await DatabaseHelper.instance.searchWords(query);

    // Hemi line hi belh rawh:
    debugPrint("Search: $query | Suggestions count: ${suggestions.length}");

    setState(() {
      _suggestions = suggestions;
      _selectedWord = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDarkMode
        ? const Color.fromARGB(255, 140, 15, 180)
        : const Color.fromARGB(255, 192, 21, 239);

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final hintColor = isDarkMode ? Colors.white60 : Colors.black45;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFFFFDF6),
      drawer: HomeDrawer(
        primaryColor: primaryColor,
        textColor: textColor,
        onWordSelected: (word) async {
          final updated = await _checkAndFetchData(word);
          _selectWord(updated);
        },
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'Mara dictionary',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            color: isDarkMode ? const Color(0xFF2C2C2C) : primaryColor,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'theme') {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme();
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              } else if (value == 'share') {
                await Share.share(
                  'Download Mara Dictionary from Play Store:\n'
                  'https://play.google.com/store/apps/details?id=com.example.mara_dictionary\n\n'
                  'Direct apk download: https://www.dropbox.com/scl/fi/6ctv9loxw8c9oooo22xlo/app-release.apk?rlkey=7of1f9jy0vd3jr3pfmk5y9f30&st=yornui99&dl=1',
                );
              } else if (value == 'web') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Web Version is coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (value == 'privacy') {
                final Uri url = Uri.parse(
                  'https://mara-dictionary-web.com/privacy-policy',
                );
                if (!await launchUrl(
                  url,
                  mode: LaunchMode.externalApplication,
                )) {
                  debugPrint('Could not launch $url');
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Dark Mode', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Settings', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Share App Link',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'web',
                  child: Row(
                    children: [
                      Icon(Icons.language, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Web Version',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'privacy',
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Privacy Policy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          HomeSearchBar(
            searchController: _searchController,
            onChanged: _onSearchChanged,
            onClear: () {
              _searchController.clear();
              _onSearchChanged('');
            },
            isListening: _isListening,
            animationController: _animationController,
            onListen: _listen,
            isDarkMode: isDarkMode,
            textColor: textColor,
            hintColor: hintColor,
          ),
          Expanded(
            child: Stack(
              children: [
                if (_selectedWord == null && _suggestions.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 70,
                          color: hintColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Mohchho charôh tyh...',
                          style: TextStyle(
                            fontSize: 16,
                            color: hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedWord != null)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: WordCard(word: _selectedWord!),
                  ),
                if (_suggestions.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2C2C2C)
                            : Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => Divider(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final wordData = _suggestions[index];
                          return ListTile(
                            title: Text(
                              wordData.word,
                              style: TextStyle(color: textColor, fontSize: 18),
                            ),
                            onTap: () => _selectWord(wordData),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
