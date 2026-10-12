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
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'info_screen.dart';
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
  int _currentBottomIndex = 0;

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  // Free Dictionary API hmanga Synonyms & Antonyms la chhuaktu
  Future<WordModel> _checkAndFetchData(WordModel word) async {
    if (word.synonyms.isEmpty && word.antonyms.isEmpty) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://api.dictionaryapi.dev/api/v2/entries/en/${word.word}',
          ),
        );

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          Set<String> synonymsSet = {};
          Set<String> antonymsSet = {};

          for (var entry in data) {
            if (entry['meanings'] != null) {
              for (var meaning in entry['meanings']) {
                if (meaning['synonyms'] != null) {
                  synonymsSet.addAll(List<String>.from(meaning['synonyms']));
                }
                if (meaning['antonyms'] != null) {
                  antonymsSet.addAll(List<String>.from(meaning['antonyms']));
                }
                if (meaning['definitions'] != null) {
                  for (var def in meaning['definitions']) {
                    if (def['synonyms'] != null) {
                      synonymsSet.addAll(List<String>.from(def['synonyms']));
                    }
                    if (def['antonyms'] != null) {
                      antonymsSet.addAll(List<String>.from(def['antonyms']));
                    }
                  }
                }
              }
            }
          }

          String synonymsList = synonymsSet.take(4).join(', ');
          String antonymsList = antonymsSet.take(4).join(', ');

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
        }
      } catch (e) {
        debugPrint("API fetch error: $e");
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

  void _getRandomWord() async {
    try {
      final suggestions = await DatabaseHelper.instance.searchWords('');
      if (suggestions.isNotEmpty) {
        suggestions.shuffle();
        _selectWord(suggestions.first);
      }
    } catch (e) {
      debugPrint("Random word fetch error: $e");
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

    const navyHeaderGradient = [Color(0xFF13263B), Color(0xFF0B1724)];
    const goldAccent = Color(0xFFDFBA7B);

    final primaryColor = isDarkMode
        ? const Color(0xFF13263B)
        : const Color(0xFF13263B);

    final textColor = isDarkMode ? Colors.white : const Color(0xFF2C2C2C);
    final hintColor = isDarkMode ? Colors.white60 : Colors.black45;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFF5EFEB),
      drawer: HomeDrawer(
        primaryColor: primaryColor,
        textColor: textColor,
        onWordSelected: (word) async {
          final updated = await _checkAndFetchData(word);
          _selectWord(updated);
        },
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: navyHeaderGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'English - Mara Dictionary',
              style: TextStyle(
                color: Color.fromARGB(255, 244, 242, 239),
                fontWeight: FontWeight.bold,
                fontSize: 21,
                letterSpacing: 0.5,
              ),
            ),
            iconTheme: const IconThemeData(color: goldAccent),
            actions: [
              PopupMenuButton<String>(
                color: isDarkMode
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFF13263B),
                icon: const Icon(Icons.more_vert, color: goldAccent),
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
                      'Direct apk download: https://drive.google.com/file/d/1f2QlM_mn7H83Sz5xp2nxR0OXWdiV_rJ-/view?usp=drive_link',
                    );
                  } else if (value == 'web') {
                    final Uri url = Uri.parse(
                      'https://zawtha.github.io/mara-dictionary/',
                    );
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      debugPrint('Could not launch $url');
                    }
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
                          Text(
                            'Dark Mode',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Settings',
                            style: TextStyle(color: Colors.white),
                          ),
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
        ),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: navyHeaderGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentBottomIndex,
          onTap: (index) {
            setState(() => _currentBottomIndex = index);
            if (index == 0) {
              _getRandomWord();
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoScreen()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: goldAccent,
          unselectedItemColor: goldAccent.withValues(alpha: 0.7),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Random word',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_border),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
