// views/guess_page.dart
import 'package:flutter/material.dart';
import 'package:hidden_words_front/logic/game_logic.dart';
import 'package:hidden_words_front/logic/world_analyzer.dart';
import 'package:hidden_words_front/models/article.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  GuessPageState createState() => GuessPageState();
}

class GuessPageState extends State<GuessPage> {
  TextEditingController inputWordController = TextEditingController();
  late GameLogic gameLogic;
  bool isTextVisible = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Initialize gameLogic with a default Article
    gameLogic = GameLogic(Article(
      title: 'Default Title',
      content: 'Default Content',
      theme: '',
      url: '',
      difficulty: '',
      hints: [],
      revealedWords: {},
      bestGuesses: {},
    ));
    loadGameState();
  }

  Future<void> loadGameState() async {
    setState(() {
      loading = true;
    });
    bool loaded = await gameLogic.loadGameState();
    if (loaded) {
      setState(() {});
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void dispose() {
    inputWordController.dispose();
    super.dispose();
  }

  void getNewArticle() async {
    setState(() {
      loading = true;
    });
    await gameLogic.fetchNewArticle();
    setState(() {
      loading = false;
    });
  }

  void revealWord(String word, String guess, double similarity) {
    setState(() {
      gameLogic.revealWord(word, guess, similarity);
      gameLogic.saveGameState();
    });
  }

  bool isPunctuation(String word) {
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

  @override
  Widget build(BuildContext context) {
    List<String> lines = gameLogic.currentArticle.content.split('\n');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Words'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
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
                                  gameLogic.currentArticle.title,
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
                                      if (isPunctuation(word)) {
                                        return _buildWordContainer(
                                            word, false, false);
                                      }
                                      String displayWord = isTextVisible
                                          ? word
                                          : gameLogic
                                                  .currentArticle.revealedWords
                                                  .contains(word)
                                              ? word
                                              : gameLogic.currentArticle
                                                      .bestGuesses[word] ??
                                                  ' ' * word.length;
                                      bool isBestGuess = gameLogic
                                          .currentArticle.bestGuesses
                                          .containsKey(word);

                                      return _buildWordContainer(
                                          displayWord, isBestGuess, true);
                                    }).toList(),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: inputWordController,
                    decoration: const InputDecoration(
                      hintText: "Tapez un mot",
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    String inputWord = inputWordController.text;
                    if (inputWord.isNotEmpty) {
                      WordAnalyzer().findSimilarWords(
                          inputWord, gameLogic.currentArticle.content,
                          (String word, String guess, double similarity) {
                        revealWord(word, guess, similarity);
                      });
                    }
                  },
                  child: const Text("Chercher"),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getNewArticle,
        tooltip: 'Change Article',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
