// add_article.dart
import 'package:flutter/material.dart';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:hidden_words_front/models/article.dart';
import 'package:hidden_words_front/services/article_service.dart';
import 'package:hidden_words_front/views/admin/article_detail.dart';

class AddArticle extends StatefulWidget {
  const AddArticle({super.key});

  @override
  AddArticleState createState() => AddArticleState();
}

class AddArticleState extends State<AddArticle> {
  Article? currentArticle;
  final ArticleService articleService = ArticleService();
  bool loading = false;

  void fetchArticle() async {
    setState(() {
      loading = true;
    });
    var articleData = await articleService.fetchRandomWikipediaArticle();
    if (articleData != null) {
      setState(() {
        currentArticle = Article(
            id: articleData['id'] ?? '',
            title: articleData['title'],
            content: articleData['contentToShow'],
            url: articleData['url'],
            theme: '',
            difficulty: '',
            hints: [],
            revealedWords: {},
            bestGuesses: {});
        Log.logger.i(currentArticle.toString());
        setState(() {
          loading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un article'),
      ),
      body: currentArticle == null
          ? loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ElevatedButton(
                    onPressed: fetchArticle,
                    child: const Text('Récupérer un article'),
                  ),
                )
          : loading
              ? const Center(child: CircularProgressIndicator())
              : ArticleDetail(article: currentArticle!),
    );
  }
}
