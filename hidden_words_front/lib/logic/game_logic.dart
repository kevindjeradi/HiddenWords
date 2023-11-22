// logic/game_logic.dart
import 'dart:convert';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:hidden_words_front/logic/world_analyzer.dart';
import 'package:hidden_words_front/models/article.dart';
import 'package:hidden_words_front/services/article_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic {
  final ArticleService articleService = ArticleService();
  final WordAnalyzer wordAnalyzer = WordAnalyzer();
  Article currentArticle;

  GameLogic(this.currentArticle);

  Future<void> fetchNewArticle() async {
    try {
      var articleData = await articleService.fetchRandomWikipediaArticle();

      if (articleData != null) {
        currentArticle = Article(
          id: articleData['id'] ?? '',
          title: articleData['title'],
          url: articleData['url'],
          content: articleData['contentToShow'],
          theme: articleData['theme'] ?? '',
          difficulty: articleData['difficulty'] ?? '',
          hints: List<String>.from(articleData['hints'] ?? []),
          revealedWords: {},
          bestGuesses: {},
        );
        await saveGameState();
      }
    } catch (e) {
      Log.logger.e("Error fetching article: $e");
    }
  }

  Future<void> saveGameState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'current_article', json.encode(currentArticle.toJson()));
  }

  Future<bool> loadGameState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? articleJsonStr = prefs.getString('current_article');
    if (articleJsonStr != null) {
      currentArticle = Article.fromJson(json.decode(articleJsonStr));
      return true;
    }
    return false;
  }

  void revealWord(String word, String guess, double similarity) {
    if (currentArticle.revealedWords.contains(word)) {
      return;
    }
    if (similarity == 1) {
      currentArticle.revealedWords.add(word);
      currentArticle.bestGuesses.remove(word);
    } else if (!currentArticle.bestGuesses.containsKey(word) ||
        similarity >=
            wordAnalyzer.getSimilarity(
                currentArticle.bestGuesses[word], word)) {
      currentArticle.bestGuesses[word] = guess;
    }
  }
}
