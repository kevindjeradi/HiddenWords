import 'package:flutter/material.dart';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:hidden_words_front/models/article.dart';
import 'package:hidden_words_front/services/article_service.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  AdminState createState() => AdminState();
}

class AdminState extends State<Admin> {
  Article? currentArticle;
  final ArticleService articleService = ArticleService();
  final TextEditingController themeController = TextEditingController();
  final TextEditingController difficultyController = TextEditingController();
  List<TextEditingController> hintControllers = [TextEditingController()];
  final TextEditingController contentController = TextEditingController();
  bool isContentEditable = false;

  void fetchArticle() async {
    var articleData = await articleService.fetchRandomWikipediaArticle();
    if (articleData != null) {
      setState(() {
        currentArticle = Article(
            title: articleData['title'],
            content: articleData['contentToShow'],
            url: articleData['url'],
            theme: '',
            difficulty: '',
            hints: [],
            revealedWords: {},
            bestGuesses: {});
        contentController.text = currentArticle!.content;
        Log.logger.i(currentArticle.toString());
      });
    }
  }

  void toggleContentEditMode() {
    setState(() {
      isContentEditable = !isContentEditable;
    });
  }

  void addHintField() {
    setState(() {
      hintControllers.add(TextEditingController());
    });
  }

  void removeHintField(int index) {
    if (hintControllers.length > 1) {
      setState(() {
        hintControllers.removeAt(index);
      });
    }
  }

  void saveArticle() async {
    if (currentArticle != null) {
      try {
        currentArticle = currentArticle!.copyWith(
          theme: themeController.text,
          difficulty: difficultyController.text,
          content: contentController.text,
          hints: hintControllers.map((controller) => controller.text).toList(),
        );
        await articleService.createArticle(currentArticle!);
        Log.logger.i("article sauvegardé");
      } catch (e) {
        Log.logger.i("article pas sauvegardé");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> contentLines = currentArticle?.content.split('\n') ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: currentArticle == null
          ? Center(
              child: ElevatedButton(
                onPressed: fetchArticle,
                child: const Text('Récupérer un article'),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: fetchArticle,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor),
                    child: const Text('Changer d\'article'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(currentArticle!.title,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  GestureDetector(
                    onTap: showEditContentDialog,
                    child: Container(
                      height: 350,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: contentLines.map((line) {
                            bool isTitle =
                                line.startsWith('{{{') && line.endsWith('}}}');
                            String displayText = isTitle
                                ? line.substring(3, line.length - 3)
                                : line;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: isTitle ? 8.0 : 4.0),
                              child: Text(
                                displayText,
                                style: TextStyle(
                                  fontWeight: isTitle
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: themeController,
                    decoration: const InputDecoration(hintText: 'Thème'),
                  ),
                  TextField(
                    controller: difficultyController,
                    decoration: const InputDecoration(hintText: 'Difficulté'),
                  ),
                  ...List.generate(hintControllers.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hintControllers[index],
                            decoration: InputDecoration(
                              hintText: 'Indice ${index + 1}',
                            ),
                          ),
                        ),
                        if (hintControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => removeHintField(index),
                          ),
                        if (index == hintControllers.length - 1)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: addHintField,
                          ),
                      ],
                    );
                  }),
                  ElevatedButton(
                    onPressed: saveArticle,
                    child: const Text('Sauvegarder l\'article'),
                  ),
                ],
              ),
            ),
    );
  }

  void showEditContentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController dialogController =
            TextEditingController(text: currentArticle?.content);
        return AlertDialog(
          title: const Text("Editer le contenu"),
          content: TextField(
            controller: dialogController,
            decoration: const InputDecoration(hintText: 'Contenu'),
            maxLines: null,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sauvegarder'),
              onPressed: () {
                setState(() {
                  contentController.text = dialogController.text;
                  currentArticle =
                      currentArticle?.copyWith(content: dialogController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
