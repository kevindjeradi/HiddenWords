class Article {
  String title;
  String content;
  String theme;
  String url;
  String difficulty;
  List<String> hints;

  Article({
    required this.title,
    required this.content,
    this.theme = '',
    this.url = '',
    this.difficulty = '',
    this.hints = const [],
  });
}
