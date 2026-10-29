import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // Pronunciation guide: letter and its description
  static const List<List<String>> _pronunciation = [
    [
      'A, a',
      'he eima reih lâta a nata e likawh liata parosapa a châ, eg. bad, had, cat, dad, fat, had, lad, lady, man, pad, pat, sad, sat, that, etc.',
    ],
    [
      'E, e',
      'he eima reih lâta i hawhta parosapa châ ta, e hawhta parosapa chhao a châ thei hra, eg. green, heed, beat, pen, bent, dent, remember, etc.',
    ],
    [
      'I, i',
      'he ai hawhta parosapa a châ tarawpata i hawhta chhao parosapa a châ thei hra, eg. I go, I eat, kite, bite, bid, hid, kit, sit, side, etc.',
    ],
    [
      'O, o',
      'he eima reih ô hawhta parosapa a châ chai, achâhta u nata aw hawhta chhao parosapa a châ hra, â hawhta hmâpa a châ thei pyly hra, eg. go, do, good, come, home, got, God, lord, ford, etc.',
    ],
    [
      'U, u',
      'he â hawhta parosapa a châ chai, châhrasala u hawhta chhao hmâpa a châ hra. eg. cut, but, hut, put, nude, cute, etc.',
    ],
    [
      'W, w',
      'he eima reih lâta y leipata u hawhta hmâpa a châ chai, eg. what, who, why, where, while, dew, few, want, win, wine, wind, etc.',
    ],
    [
      'Y, y',
      'he eima reih y nata a parosazie âlyu vei, uai tahpata paraosapa a cha, ai nata i hawhta parosa theipa a châ hra. eg. why, tyrant, dynamic, duty, python, lily, fully, my, thy, by, shy, psychology, etc.',
    ],
  ];

  // Abbreviations used in the dictionary
  static const List<List<String>> _abbreviations = [
    ['adj.', 'adjective.'],
    ['adv.', 'adverb.'],
    ['abbrev.', 'abbreviation.'],
    ['arch.', 'archaic.'],
    ['bot.', 'botany.'],
    ['colloq.', 'colloquialism.'],
    ['compar.', 'comparative.'],
    ['conj.', 'conjunction.'],
    ['cf.', 'compare.'],
    ['derog.', 'derogatory.'],
    ['e.g.', 'for example.'],
    ['esp.', 'especially.'],
    ['etc.', 'et cetera.'],
    ['Fr.', 'French.'],
    ['fem.', 'feminine.'],
    ['fig.', 'figurative.'],
    ['gram.', 'grammer.'],
    ['Gr.', 'Greek.'],
    ['i.e.', 'that is to say.'],
    ['interj.', 'interjection.'],
    ['ill.', 'illustration.'],
    ['It.', 'Italy.'],
    ['lit.', 'literature.'],
    ['Lat.', 'Latin.'],
    ['med.', 'medical.'],
    ['mus.', 'music.'],
    ['n.', 'noun.'],
    ['npl.', 'noun in plural.'],
    ['No.', 'number.'],
    ['pl.', 'plural.'],
    ['pp.', 'past participle.'],
    ['poet.', 'poetry.'],
    ['pt.', 'past tense.'],
    ['prep.', 'preposition.'],
    ['pron.', 'pronoun.'],
    ['RC.', 'Roman Catholic.'],
    ['sing.', 'singular.'],
    ['sl.', 'slang.'],
    ['superl.', 'superlative.'],
    ['Sp.', 'Spain.'],
    ['v.', 'verb.'],
    ['viz.', 'namely.'],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = Provider.of<ThemeProvider>(context);

    // Follows the Theme Colour chosen in Settings (gold in dark mode)
    final accent = isDark ? const Color(0xFFDFBA7B) : settings.primaryColor;
    final textColor = theme.colorScheme.onSurface;
    final softColor = textColor.withValues(alpha: 0.87);

    // App bar and background colours come from the app theme (main.dart)
    return Scaffold(
      appBar: AppBar(title: const Text('Info & Guide')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PRONUNCIATION ---
            Text(
              'Pronunciation. Hawrawh reihparosa dâh.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            for (final p in _pronunciation)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${p[0]} = ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p[1],
                        style: TextStyle(
                          fontSize: 16,
                          color: softColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'He zy hleikhôpata reihparosazie ânanotu hlei vei.',
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: softColor,
                ),
              ),
            ),

            const Divider(height: 40, thickness: 1.5),

            // --- ABBREVIATIONS ---
            Text(
              'ABBREVIATIONS USED IN THE DICTIONARY.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),

            // Two columns; a long text wraps to the next line (no "...")
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    for (final a in _abbreviations)
                      SizedBox(
                        width: itemWidth,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a[0],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                a[1],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: softColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
