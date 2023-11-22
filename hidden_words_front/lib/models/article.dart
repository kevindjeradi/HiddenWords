// models\article.dart
class Article {
  String id;
  String title;
  String content;
  String theme;
  String url;
  String difficulty;
  List<String> hints;
  Set<String> revealedWords;
  Map<String, String> bestGuesses;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.theme = '',
    this.url = '',
    this.difficulty = '',
    this.hints = const [],
    this.revealedWords = const {},
    this.bestGuesses = const {},
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['_id'] ?? '',
      title: json['title'],
      content: json['content'],
      theme: json['theme'] ?? '',
      url: json['url'] ?? '',
      difficulty: json['difficulty'] ?? '',
      hints: List<String>.from(json['hints'] ?? []),
      revealedWords: Set<String>.from(json['revealedWords'] ?? []),
      bestGuesses: Map<String, String>.from(json['bestGuesses'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'theme': theme,
      'url': url,
      'difficulty': difficulty,
      'hints': hints,
      'revealedWords': revealedWords.toList(),
      'bestGuesses': bestGuesses,
    };
  }

  Article copyWith({
    String? title,
    String? content,
    String? theme,
    String? url,
    String? difficulty,
    List<String>? hints,
    Set<String>? revealedWords,
    Map<String, String>? bestGuesses,
  }) {
    return Article(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      theme: theme ?? this.theme,
      url: url ?? this.url,
      difficulty: difficulty ?? this.difficulty,
      hints: hints ?? this.hints,
      revealedWords: revealedWords ?? this.revealedWords,
      bestGuesses: bestGuesses ?? this.bestGuesses,
    );
  }

  @override
  String toString() {
    return 'Article(title: $title, content: $content, theme: $theme, url: $url, difficulty: $difficulty, hints: $hints, revealedWords: $revealedWords, bestGuesses: $bestGuesses)';
  }
}
