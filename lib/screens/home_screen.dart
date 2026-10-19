import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import '../models/word_model.dart';
import '../providers/theme_provider.dart';
import '../utils/database_helper.dart';
import '../utils/synonym_service.dart';
import '../widgets/home_drawer.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/word_card.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

const _webUrl = 'https://narsonatlei-ops.github.io/Mara-dictionary/';
const _privacyUrl = 'https://mara-dictionary-web.com/privacy-policy';
const _apkUrl =
    'https://drive.google.com/file/d/11HMC56cwS6aqTOH49EyhW2ZPWwE9R7w6/view?usp=sharing';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<WordModel> _suggestions = [];
  WordModel? _selectedWord;
  int _cardVersion = 0; // changes when the card must reload (e.g. favorites)
  final TextEditingController _searchController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ---------------- word selection ----------------

  void _selectWord(WordModel word) {
    setState(() {
      _selectedWord = word;
      _searchController.text = word.word;
      _suggestions = [];
    });
    FocusScope.of(context).unfocus();

    if (word.id != null) {
      DatabaseHelper.instance.addToHistory(
        word.id!,
        word.word,
        word.definition,
      );
    }
    _loadSynonymsAndAntonyms(word);
  }

  // The word is shown at once; synonyms and antonyms are added when ready
  Future<void> _loadSynonymsAndAntonyms(WordModel word) async {
    if (word.synonyms.isNotEmpty || word.antonyms.isNotEmpty) return;

    final result = await SynonymService.fetch(word.word);
    if (result == null ||
        (result.synonyms.isEmpty && result.antonyms.isEmpty)) {
      return;
    }

    if (word.id != null) {
      await DatabaseHelper.instance.updateWordSynAnt(
        word.id!,
        result.synonyms,
        result.antonyms,
      );
    }

    // Show them only if the user is still looking at the same word
    if (!mounted || _selectedWord?.id != word.id) return;
    setState(() {
      _selectedWord = WordModel(
        id: word.id,
        word: word.word,
        definition: word.definition,
        isFavorite: word.isFavorite,
        synonyms: result.synonyms,
        antonyms: result.antonyms,
      );
    });
  }

  Future<void> _getRandomWord() async {
    final word = await DatabaseHelper.instance.getRandomWord();
    if (word != null && mounted) _selectWord(word);
  }

  // ---------------- search ----------------

  Future<void> _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _selectedWord = null;
      });
      return;
    }

    final suggestions = await DatabaseHelper.instance.searchWords(query.trim());
    if (!mounted) return;
    setState(() {
      _suggestions = suggestions;
      _selectedWord = null;
    });
  }

  // ---------------- voice search ----------------

  void _setListening(bool value) {
    if (!mounted) return;
    setState(() => _isListening = value);
    if (value) {
      _animationController.repeat();
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  Future<void> _listen() async {
    if (_isListening) {
      _speech.stop();
      _setListening(false);
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          _setListening(false);
        }
      },
      onError: (error) => _setListening(false),
    );

    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice search is not available on this device.'),
          ),
        );
      }
      return;
    }

    _setListening(true);
    _speech.listen(
      onResult: (result) async {
        if (!mounted) return;
        _searchController.text = result.recognizedWords;

        final suggestions = await DatabaseHelper.instance.searchWords(
          result.recognizedWords.trim(),
        );
        if (!mounted) return;
        setState(() {
          _suggestions = suggestions;
          _selectedWord = null;
        });

        if (result.finalResult && suggestions.isNotEmpty) {
          _selectWord(suggestions.first);
          _speech.stop();
          _setListening(false);
        }
      },
    );
  }

  // ---------------- menu ----------------

  Future<void> _openLink(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
    }
  }

  void _onMenuSelected(String value) {
    switch (value) {
      case 'theme':
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
        break;
      case 'share':
        Share.share(
          'Mara Dictionary\n\nWeb version: $_webUrl\n\nDirect apk download: $_apkUrl',
        );
        break;
      case 'web':
        _openLink(_webUrl);
        break;
      case 'privacy':
        _openLink(_privacyUrl);
        break;
    }
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String text) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // ---------------- bottom bar ----------------

  Future<void> _onBottomTap(int index) async {
    if (index == 0) {
      _getRandomWord();
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            index == 1 ? const HistoryScreen() : const FavoritesScreen(),
      ),
    );
    // The favorite status may have changed: reload the card
    if (mounted) setState(() => _cardVersion++);
  }

  // ---------------- build ----------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final headerColor = Provider.of<ThemeProvider>(context).headerColor;
    final headerDark = Color.lerp(headerColor, Colors.black, 0.35)!;

    // One gradient is shared by the app bar and the search bar:
    // the app bar ends at the middle shade, the search bar continues from it.
    final headerMid = Color.lerp(headerColor, Colors.black, 0.17)!;
    final appBarGradient = LinearGradient(
      colors: [headerColor, headerMid],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final bottomGradient = LinearGradient(
      colors: [headerColor, headerDark],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    const goldAccent = Color(0xFFDFBA7B);

    final textColor = theme.colorScheme.onSurface;
    final hintColor = isDarkMode ? Colors.white60 : Colors.black45;

    return Scaffold(
      drawer: HomeDrawer(onWordSelected: _selectWord),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(gradient: appBarGradient),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'English - Mara Dictionary',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textScaler: TextScaler.noScaling,
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
                color: headerDark,
                icon: const Icon(Icons.more_vert, color: goldAccent),
                onSelected: _onMenuSelected,
                itemBuilder: (context) => [
                  _menuItem('theme', Icons.dark_mode, 'Dark Mode'),
                  _menuItem('settings', Icons.settings, 'Settings'),
                  _menuItem('share', Icons.share, 'Share App Link'),
                  _menuItem('web', Icons.language, 'Web Version'),
                  _menuItem('privacy', Icons.security, 'Privacy Policy'),
                ],
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
            headerColor: headerColor,
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
                    child: WordCard(
                      key: ValueKey('${_selectedWord!.id}_$_cardVersion'),
                      word: _selectedWord!,
                    ),
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
        decoration: BoxDecoration(
          gradient: bottomGradient,
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          onTap: _onBottomTap,
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
              icon: Icon(Icons.casino_outlined),
              label: 'Random word',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
