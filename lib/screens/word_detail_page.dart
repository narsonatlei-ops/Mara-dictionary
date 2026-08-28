import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // JSON decoding nan kan mamawh
import 'package:http/http.dart' as http; // API dawt nan kan mamawh
import '../models/word_model.dart';
import '../utils/database_helper.dart';
import '../providers/theme_provider.dart';

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
  bool isLoadingApi = false; // Internet atanga a dawt laia loading hmuhna tur

  @override
  void initState() {
    super.initState();
    // Database tharah hian column thar an nih avangin NULL an lo nih palh pawhin ruak (empty) angin kan pawm hram ang
    synonyms = widget.word.synonyms;
    antonyms = widget.word.antonyms;

    _checkFavoriteStatus();

    // Synonyms leh Antonyms a lo la ruak vek a nih chuan API kan dawt nghal ang
    if (synonyms.trim().isEmpty && antonyms.trim().isEmpty) {
      _fetchSynonymsAndAntonyms();
    }
  }

  void _checkFavoriteStatus() async {
    if (widget.word.id != null) {
      bool status = await DatabaseHelper.instance.isWordFavorited(
        widget.word.id!,
      );
      if (mounted) {
        setState(() {
          isFavorite = status;
        });
      }
    }
  }

  // Hemi hian internet atangin synonyms leh antonyms a va dawt tawh ang
  void _fetchSynonymsAndAntonyms() async {
    setState(() {
      isLoadingApi = true;
    });

    try {
      final String cleanWord = widget.word.word.trim();

      // Uri.parse aiah space leh special character awm thut pawha him zawk turin Uri.https kan hmang ang
      final synUri = Uri.https('api.datamuse.com', '/words', {
        'rel_syn': cleanWord,
      });
      final antUri = Uri.https('api.datamuse.com', '/words', {
        'rel_ant': cleanWord,
      });

      final synRes = await http.get(synUri);
      final antRes = await http.get(antUri);

      if (synRes.statusCode == 200 && antRes.statusCode == 200) {
        List synData = json.decode(synRes.body);
        List antData = json.decode(antRes.body);

        // Thumal hmasa 5 chauh comma-in kan thlung khawm ang
        String synList = synData.map((e) => e['word']).take(5).join(', ');
        String antList = antData.map((e) => e['word']).take(5).join(', ');

        // Offline-a hman zui theih nan database-ah kan va save (update) hlen nghal ang
        if (widget.word.id != null) {
          await DatabaseHelper.instance.updateWordSynAnt(
            widget.word.id!,
            synList,
            antList,
          );
        }

        // User-in back button a lo hmeh hman palh pawha a crash loh nan 'if (mounted)' kan check ang
        if (mounted) {
          setState(() {
            synonyms = synList;
            antonyms = antList;
            isLoadingApi = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoadingApi = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingApi = false;
        });
      }
      print("API Fetch Error: $e");
    }
  }

  // HETAH HIAN KAN THLAK E
  void _toggleFavorite() async {
    if (widget.word.id != null) {
      bool newStatus = !isFavorite;
      int statusInt = newStatus
          ? 1
          : 0; // SQLite-in 1 leh 0 chiah a hriatthiam avangin

      // updateFavoriteStatus kan ko tawh ang
      await DatabaseHelper.instance.updateFavoriteStatus(
        widget.word.id!,
        statusInt,
      );

      setState(() {
        isFavorite = newStatus;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus
                ? 'Favorites-lia ei soh ha!'
                : 'Favorites tawhta ei thy ha!',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFFFFDF6),
      appBar: AppBar(
        title: Text(
          widget.word.word,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode
            ? const Color.fromARGB(255, 140, 15, 180)
            : themeProvider.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
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
                // 1. THUMAL HMING
                Text(
                  widget.word.word,
                  style: TextStyle(
                    fontSize: themeProvider.fontSize + 8,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? Colors.purpleAccent
                        : themeProvider.primaryColor,
                  ),
                ),
                const Divider(height: 30, thickness: 1.5),

                // 2. THUMAL HRIHFIAHNA
                Text(
                  'Meaning:',
                  style: TextStyle(
                    fontSize: themeProvider.fontSize - 2,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.word.definition,
                  style: TextStyle(
                    fontSize: themeProvider.fontSize,
                    color: textColor,
                    height: 1.5,
                  ),
                ),

                // Internet atanga a la dawt lai chuan helai bîk hi lo berpui rawh se
                if (isLoadingApi) ...[
                  const SizedBox(height: 25),
                  const Center(child: CircularProgressIndicator()),
                ],

                // 3. SYNONYMS (A lo thlen tawh chuan mawi deuhin a rawn tlar ang)
                if (!isLoadingApi && synonyms.isNotEmpty) ...[
                  const Divider(height: 40, thickness: 1),
                  Row(
                    children: [
                      const Icon(Icons.link, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Synonyms:',
                        style: TextStyle(
                          fontSize: themeProvider.fontSize - 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    synonyms,
                    style: TextStyle(
                      fontSize: themeProvider.fontSize,
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],

                // 4. ANTONYMS (A lo thlen tawh chuan mawi deuhin a rawn tlar ang)
                if (!isLoadingApi && antonyms.isNotEmpty) ...[
                  const Divider(height: 40, thickness: 1),
                  Row(
                    children: [
                      const Icon(
                        Icons.compare_arrows,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Antonyms:',
                        style: TextStyle(
                          fontSize: themeProvider.fontSize - 2,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    antonyms,
                    style: TextStyle(
                      fontSize: themeProvider.fontSize,
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
