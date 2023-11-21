import 'package:flutter/material.dart';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:hidden_words_front/logic/difficulties.dart';
import 'package:hidden_words_front/logic/themes.dart';
import 'package:hidden_words_front/models/article.dart';
import 'package:hidden_words_front/services/article_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AddArticle extends StatefulWidget {
  const AddArticle({super.key});

  @override
  AddArticleState createState() => AddArticleState();
}

class AddArticleState extends State<AddArticle> {
  Article? currentArticle;
  final ArticleService articleService = ArticleService();
  String? selectedDifficulty;
  String? selectedTheme;
  List<TextEditingController> hintControllers = [TextEditingController()];
  final TextEditingController contentController = TextEditingController();
  bool isContentEditable = false;
  bool loading = false;

  void fetchArticle() async {
    setState(() {
      loading = true;
    });
    resetForm();
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
        setState(() {
          loading = false;
        });
      });
    }
  }

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
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

  void resetForm() {
    contentController.clear();
    hintControllers.clear();
    hintControllers.add(TextEditingController());
    selectedTheme = null;
    selectedDifficulty = null;
  }

  void saveArticle() async {
    setState(() {
      loading = true;
    });
    if (currentArticle != null) {
      try {
        currentArticle = currentArticle!.copyWith(
          theme: selectedTheme,
          difficulty: selectedDifficulty,
          content: contentController.text,
          hints: hintControllers.map((controller) => controller.text).toList(),
        );
        await articleService.createArticle(currentArticle!);
        Log.logger.i("article sauvegardé");
        resetForm();
        fetchArticle();
      } catch (e) {
        Log.logger.i("article pas sauvegardé");
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> contentLines = currentArticle?.content.split('\n') ?? [];

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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
                          onTap: () => _launchURL(currentArticle!.url),
                          child: Text(
                            currentArticle!.url,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: GestureDetector(
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
                                  bool isTitle = line.startsWith('{{{') &&
                                      line.endsWith('}}}');
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
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedTheme,
                                hint: const Text('Thème'),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedTheme = newValue;
                                  });
                                },
                                items: articlesThemes
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: DropdownButton<String>(
                                value: selectedDifficulty,
                                hint: const Text('Difficulté'),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedDifficulty = newValue;
                                  });
                                },
                                items: articlesDifficulties
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        ],
                      ),
                      ...List.generate(hintControllers.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
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
                          ),
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
