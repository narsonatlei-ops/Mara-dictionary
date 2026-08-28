import 'package:flutter/material.dart';
import 'package:mara_dictionary/utils/database_helper.dart';
import 'package:mara_dictionary/models/word_model.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailScreen extends StatefulWidget {
  final WordModel currentWord;

  const DetailScreen({super.key, required this.currentWord});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late WordModel displayWord;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    displayWord = widget.currentWord;
    _loadSynonymsAndAntonyms();
  }

  Future<void> _loadSynonymsAndAntonyms() async {
    if (displayWord.synonyms.isEmpty && displayWord.antonyms.isEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        final synRes = await http.get(
          Uri.parse(
            'https://api.datamuse.com/words?rel_syn=${displayWord.word}',
          ),
        );
        final antRes = await http.get(
          Uri.parse(
            'https://api.datamuse.com/words?rel_ant=${displayWord.word}',
          ),
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

        if (displayWord.id != null &&
            (synonymsList.isNotEmpty || antonymsList.isNotEmpty)) {
          await DatabaseHelper.instance.updateWordSynAnt(
            displayWord.id!,
            synonymsList,
            antonymsList,
          );

          setState(() {
            displayWord = WordModel(
              id: displayWord.id,
              word: displayWord.word,
              definition: displayWord.definition,
              isFavorite: displayWord.isFavorite,
              synonyms: synonymsList,
              antonyms: antonymsList,
            );
          });
          print("SQLite-lia offline hmâthei awpa ta a save haw!");
        }
      } catch (e) {
        print("Internet y vei: $e");
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          displayWord.word,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- THUMAL LEH A DEFINITION ---
            Text(
              displayWord.word,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(displayWord.definition, style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 15),

            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              )
            else ...[
              // --- SYNONYMS (Mizo a ni lo, sapṭawngin kan dah let e) ---
              if (displayWord.synonyms.isNotEmpty) ...[
                Text.rich(
                  TextSpan(
                    text: 'Synonyms: ',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: displayWord.synonyms,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.blue[300]
                              : Colors.blue[900],
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // --- ANTONYMS (Mizo a ni lo, sapṭawngin kan dah let e) ---
              if (displayWord.antonyms.isNotEmpty) ...[
                Text.rich(
                  TextSpan(
                    text: 'Antonyms: ',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    children: [
                      TextSpan(
                        text: displayWord.antonyms,
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.blue[300]
                              : Colors.blue[900],
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
