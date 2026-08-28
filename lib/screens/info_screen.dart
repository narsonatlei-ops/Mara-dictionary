import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFFFFDF6,
      ), // I HomeScreen background rawng chiah kha
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(
          255,
          192,
          21,
          239,
        ), // I AppBar rawng mawi tak kha
        title: const Text(
          'Info & Guide',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================================================================
            // SECTION 1: PRONUNCIATION
            // =========================================================================
            const Text(
              'Pronunciation. Hawrawh reihparosa dâh.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            _buildPronunciationItem(
              'A, a',
              'he eima reih lâta a nata e likawh liata parosapa a châ, eg. bad, had, cat, dad, fat, had, lad, lady, man, pad, pat, sad, sat, that, etc.',
            ),
            _buildPronunciationItem(
              'E, e',
              'he eima reih lâta i hawhta parosapa châ ta, e hawhta parosapa chhao a châ thei hra, eg. green, heed, beat, pen, bent, dent, remember, etc.',
            ),
            _buildPronunciationItem(
              'I, i',
              'he ai hawhta parosapa a châ tarawpata i hawhta chhao parosapa a châ thei hra, eg. I go, I eat, kite, bite, bid, hid, kit, sit, side, etc.',
            ),
            _buildPronunciationItem(
              'O, o',
              'he eima reih ô hawhta parosapa a châ chai, achâhta u nata aw hawhta chhao parosapa a châ hra, â hawhta hmâpa a châ thei pyly hra, eg. go, do, good, come, home, got, God, lord, ford, etc.',
            ),
            _buildPronunciationItem(
              'U, u',
              'he â hawhta parosapa a châ chai, châhrasala u hawhta chhao hmâpa a châ hra. eg. cut, but, hut, put, nude, cute, etc.',
            ),
            _buildPronunciationItem(
              'W, w',
              'he eima reih lâta y leipata u hawhta hmâpa a châ chai, eg. what, who, why, where, while, dew, few, want, win, wine, wind, etc.',
            ),
            _buildPronunciationItem(
              'Y, y',
              'he eima reih y nata a parosazie âlyu vei, uai tahpata paraosapa a cha, ai nata i hawhta parosa theipa a châ hra. eg. why, tyrant, dynamic, duty, python, lily, fully, my, thy, by, shy, psychology, etc.',
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'He zy hleikhôpata reihparosazie ânanotu hlei vei.',
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ),

            const Divider(height: 40, thickness: 1.5),

            // =========================================================================
            // SECTION 2: ABBREVIATIONS
            // =========================================================================
            const Text(
              'ABBREVIATIONS USED IN THE DICTIONARY.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Tlar thup hmuh nuam turin GridView hmangin column pahnihin kan rem dawn nia
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio:
                  3.5, // Tlar pakhat dung leh vang inrem tawk chiah
              children: [
                _buildAbbrevItem('adj.', 'adjective.'),
                _buildAbbrevItem('adv.', 'adverb.'),
                _buildAbbrevItem('abbrev.', 'abbreviation.'),
                _buildAbbrevItem('arch.', 'archaic.'),
                _buildAbbrevItem('bot.', 'botany.'),
                _buildAbbrevItem('colloq.', 'colloquialism.'),
                _buildAbbrevItem('compar.', 'comparative.'),
                _buildAbbrevItem('conj.', 'conjunction.'),
                _buildAbbrevItem('cf.', 'compare.'),
                _buildAbbrevItem('derog.', 'derogatory.'),
                _buildAbbrevItem('e.g.', 'for example.'),
                _buildAbbrevItem('esp.', 'especially.'),
                _buildAbbrevItem('etc.', 'et cetera.'),
                _buildAbbrevItem('Fr.', 'French.'),
                _buildAbbrevItem('fem.', 'feminine.'),
                _buildAbbrevItem('fig.', 'figurative.'),
                _buildAbbrevItem(
                  'gram.',
                  'grammer.',
                ), // Thlalaka a ziah dan chiah khuan 'grammer'
                _buildAbbrevItem('Gr.', 'Greek.'),
                _buildAbbrevItem('i.e.', 'that is to say.'),
                _buildAbbrevItem('interj.', 'interjection.'),
                _buildAbbrevItem('ill.', 'illustration.'),
                _buildAbbrevItem('It.', 'Italy.'),
                _buildAbbrevItem('lit.', 'literature.'),
                _buildAbbrevItem('Lat.', 'Latin.'),
                _buildAbbrevItem('med.', 'medical.'),
                _buildAbbrevItem('mus.', 'music.'),
                _buildAbbrevItem('n.', 'noun.'),
                _buildAbbrevItem('npl.', 'noun in plural.'),
                _buildAbbrevItem('No.', 'number.'),
                _buildAbbrevItem('pl.', 'plural.'),
                _buildAbbrevItem('pp.', 'past participle.'),
                _buildAbbrevItem('poet.', 'poetry.'),
                _buildAbbrevItem('pt.', 'past tense.'),
                _buildAbbrevItem('prep.', 'preposition.'),
                _buildAbbrevItem('pron.', 'pronoun.'),
                _buildAbbrevItem('RC.', 'Roman Catholic.'),
                _buildAbbrevItem('sing.', 'singular.'),
                _buildAbbrevItem('sl.', 'slang.'),
                _buildAbbrevItem('superl.', 'superlative.'),
                _buildAbbrevItem('Sp.', 'Spain.'),
                _buildAbbrevItem('v.', 'verb.'),
                _buildAbbrevItem('viz.', 'namely.'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Pronunciation design hman thin tur widget
  Widget _buildPronunciationItem(String letter, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$letter = ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Abbreviation tlar thup design na widget awlsam
  Widget _buildAbbrevItem(String short, String long) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          short,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 23, 179, 222),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            long,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
