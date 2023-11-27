import 'package:flutter/material.dart';
import 'package:hidden_words_front/models/article.dart';
import 'package:hidden_words_front/services/article_service.dart';
import 'package:hidden_words_front/views/admin/article_detail.dart';

class ListArticles extends StatefulWidget {
  const ListArticles({super.key});

  @override
  ListArticlesState createState() => ListArticlesState();
}

class ListArticlesState extends State<ListArticles> {
  final ArticleService _articleService = ArticleService();
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  _loadArticles() async {
    try {
      var articles = await _articleService.fetchAllArticles();
      setState(() => _articles = articles);
    } catch (e) {
      // Handle exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List des articles'),
      ),
      body: ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final article = _articles[index];
          return ListTile(
            title: Text(article.title),
            subtitle: Text(
                "Theme: ${article.theme}, Difficulty: ${article.difficulty}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text("Modifier un article"),
                      ),
                      body: ArticleDetail(article: article, createMode: false)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
