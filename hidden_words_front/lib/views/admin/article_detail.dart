// article_detail.dart
import 'package:flutter/material.dart';
import 'package:hidden_words_front/logic/difficulties.dart';
import 'package:hidden_words_front/logic/themes.dart';
import 'package:hidden_words_front/models/article.dart';
import 'package:hidden_words_front/services/article_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleDetail extends StatefulWidget {
  final Article article;

  const ArticleDetail({
    super.key,
    required this.article,
  });

  @override
  ArticleDetailState createState() => ArticleDetailState();
}

class ArticleDetailState extends State<ArticleDetail> {
  late Article currentArticle;
  final ArticleService articleService = ArticleService();
  String? selectedDifficulty;
  String? selectedTheme;
  List<TextEditingController> hintControllers = [];
  final TextEditingController contentController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    currentArticle = widget.article;
    contentController.text = currentArticle.content;

    selectedTheme = articlesThemes.contains(currentArticle.theme)
        ? currentArticle.theme
        : articlesThemes.first;
    selectedDifficulty =
        articlesDifficulties.contains(currentArticle.difficulty)
            ? currentArticle.difficulty
            : articlesDifficulties.first;

    hintControllers = currentArticle.hints
        .map((hint) => TextEditingController(text: hint))
        .toList();
  }

  void _launchURL() async {
    if (!await launchUrl(Uri.parse(currentArticle.url))) {
      throw 'Could not launch ${currentArticle.url}';
    }
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
    setState(() {
      loading = true;
    });
    try {
      Article updatedArticle = currentArticle.copyWith(
        theme: selectedTheme,
        difficulty: selectedDifficulty,
        content: contentController.text,
        hints: hintControllers.map((controller) => controller.text).toList(),
      );
      await articleService.updateArticle(updatedArticle);
      // Assuming updateArticle is a method in ArticleService for saving changes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update article')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> contentLines = currentArticle.content.split('\n');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: _launchURL,
              child: Text(
                currentArticle.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: GestureDetector(
              onTap: _launchURL,
              child: Text(
                currentArticle.url,
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
                      bool isTitle =
                          line.startsWith('{{{') && line.endsWith('}}}');
                      String displayText =
                          isTitle ? line.substring(3, line.length - 3) : line;
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: isTitle ? 8.0 : 4.0),
                        child: Text(
                          displayText,
                          style: TextStyle(
                            fontWeight:
                                isTitle ? FontWeight.bold : FontWeight.normal,
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
                        .map<DropdownMenuItem<String>>((String value) {
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
                        .map<DropdownMenuItem<String>>((String value) {
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
    );
  }

  void showEditContentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController dialogController =
            TextEditingController(text: currentArticle.content);
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
                      currentArticle.copyWith(content: dialogController.text);
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
