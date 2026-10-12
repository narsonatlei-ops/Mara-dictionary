class WordModel {
  final int? id;
  final String word;
  final String definition;
  final int isFavorite;
  final String synonyms;
  final String antonyms;

  WordModel({
    this.id,
    required this.word,
    required this.definition,
    this.isFavorite = 0,
    this.synonyms = '',
    this.antonyms = '',
  });
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'word': word,
      'definition': definition,
      'is_favorite': isFavorite,
      'synonyms': synonyms,
      'antonyms': antonyms,
    };
  }

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'],
      word: map['word'] ?? map['WORDS'] ?? '',
      definition: map['definition'] ?? map['DEFINITIONS'] ?? '',
      isFavorite: map['is_favorite'] ?? 0,
      synonyms: map['synonyms'] ?? '',
      antonyms: map['antonyms'] ?? '',
    );
  }
}
