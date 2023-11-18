import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:hidden_words_front/logic/world_analyzer.dart';
import 'package:hidden_words_front/services/article_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  GuessPageState createState() => GuessPageState();
}

class GuessPageState extends State<GuessPage> {
  TextEditingController inputWordController = TextEditingController();
  final WordAnalyzer wordAnalyzer = WordAnalyzer();
  String title = 'Titre';
  String content = "Texte de base pour tester, banane bananier";
  Set<String> revealedWords = <String>{};
  Map<String, String> bestGuesses = {};
  ArticleService articleService = ArticleService();
  bool isTextVisible = false;
  bool loading = false;

  Future<void> saveArticle(String title, String content) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('article_title', title);
    await prefs.setString('article_content', content);
    await prefs.setStringList('revealed_words', revealedWords.toList());
    await prefs.setString('best_guesses', json.encode(bestGuesses));
  }

  Future<void> loadArticle() async {
    setState(() {
      loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String loadedTitle = prefs.getString('article_title') ?? 'Titre';
    String loadedContent = prefs.getString('article_content') ??
        'Texte de base pour tester, banane bananier';
    List<String> loadedRevealedWords =
        prefs.getStringList('revealed_words') ?? [];
    String? loadedBestGuessesStr = prefs.getString('best_guesses');
    Map<String, String> loadedBestGuesses = loadedBestGuessesStr != null
        ? Map<String, String>.from(json.decode(loadedBestGuessesStr))
        : {};

    Log.logger.i("Title: $loadedTitle");
    Log.logger.i("Content: $loadedContent");

    setState(() {
      title = loadedTitle;
      content = loadedContent;
      revealedWords = loadedRevealedWords.toSet();
      bestGuesses = loadedBestGuesses;
      loading = false;
    });
  }

  Future<void> getNewArticle() async {
    try {
      setState(() {
        loading = true;
      });
      var articleData = await articleService.fetchRandomWikipediaArticle();

      if (articleData != null) {
        // Reset revealedWords and bestGuesses for the new article
        revealedWords.clear();
        bestGuesses.clear();

        // Update local storage with the cleared state
        await saveArticle('', '');

        setState(() {
          title = articleData['title'];
          content = articleData['contentToShow'];
        });

        // Now save the new article data to local storage
        await saveArticle(title, content);

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      Log.logger.e("Error fetching article: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadArticle();
  }

  @override
  void dispose() {
    inputWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> lines = content.split('\n');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Words'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: loading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 24),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isTextVisible = !isTextVisible;
                              });
                            },
                            icon: Icon(isTextVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: lines.map((line) {
                            List<String> words = line.split(' ');
                            return Wrap(
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: words.map((word) {
                                if (word.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                // Check if the word is a punctuation mark
                                if (isPunctuation(word)) {
                                  return _buildWordContainer(
                                      word, false, false);
                                }

                                // Existing logic for other words
                                String displayWord = isTextVisible
                                    ? word
                                    : revealedWords.contains(word)
                                        ? word
                                        : bestGuesses[word] ??
                                            ' ' * word.length;
                                bool isBestGuess =
                                    bestGuesses.containsKey(word);

                                return _buildWordContainer(
                                    displayWord, isBestGuess, true);
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: inputWordController,
                          decoration: const InputDecoration(
                            hintText: "Entrez un mot",
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          String inputWord = inputWordController.text;
                          wordAnalyzer.findSimilarWords(
                              inputWord, content, revealWord);
                        },
                        child: const Text("Chercher"),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getNewArticle,
        tooltip: 'Changer d\'article',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  bool isPunctuation(String word) {
    // A simple check for common punctuation marks
    return "!.,;:'\"?()-".contains(word);
  }

  Widget _buildWordContainer(String word, bool isBestGuess, bool isObfuscated) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        word,
        style: TextStyle(
          fontStyle:
              isObfuscated && isBestGuess ? FontStyle.italic : FontStyle.normal,
          color: isObfuscated && isBestGuess ? Colors.red : Colors.black,
        ),
      ),
    );
  }

  void revealWord(String word, String guess, double similarity) {
    setState(() {
      if (revealedWords.contains(word)) {
        return;
      }
      if (similarity == 1) {
        revealedWords.add(word);
        bestGuesses.remove(word);
      } else if (!bestGuesses.containsKey(word) ||
          similarity >= WordAnalyzer().getSimilarity(bestGuesses[word], word)) {
        bestGuesses[word] = guess;
      }
    });
  }
}
