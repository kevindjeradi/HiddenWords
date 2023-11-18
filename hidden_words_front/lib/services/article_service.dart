// article_service.dart

import 'dart:convert';
import 'package:hidden_words_front/helpers/logger.dart';
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
}
