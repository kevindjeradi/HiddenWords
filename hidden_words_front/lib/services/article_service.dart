// article_service.dart
import 'dart:convert';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:hidden_words_front/models/article.dart';
import 'package:hidden_words_front/services/api.dart';

class ArticleService {
  fetchRandomWikipediaArticle() async {
    try {
      final response = await Api().get('/random-wikipedia-article');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load article');
      }
    } catch (e) {
      Log.logger.e("Error in fetchRandomWikipediaArticle: $e");
    }
  }

  Future<void> createArticle(Article article) async {
    try {
      final response = await Api().post(
        '/article',
        article.toJson(),
      );

      if (response.statusCode == 201) {
        Log.logger.i("Article created successfully");
      } else {
        Log.logger
            .e("Failed to create article. Status code: ${response.statusCode}");
        throw Exception('Failed to create article');
      }
    } catch (e) {
      Log.logger.e("Error in createArticle: $e");
      rethrow;
    }
  }
}
