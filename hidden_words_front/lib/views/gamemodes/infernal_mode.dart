// views/infernal_mode.dart
import 'package:flutter/material.dart';
import 'package:hidden_words_front/logic/game_logic.dart';
import 'package:hidden_words_front/logic/world_analyzer.dart';
import 'package:hidden_words_front/models/article.dart';

class InfernalMode extends StatefulWidget {
  const InfernalMode({super.key});

  @override
  InfernalModeState createState() => InfernalModeState();
}

class InfernalModeState extends State<InfernalMode> {
  TextEditingController inputWordController = TextEditingController();
  late GameLogic gameLogic;
  bool isTextVisible = false;
  bool loading = false;
  bool hasWon = false;

  @override
  void initState() {
    super.initState();
    // Initialize gameLogic with a default Article
    gameLogic = GameLogic(
        "infernal_mode",
        Article(
          id: '',
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
      inputWordController.clear();
      hasWon = false;
      loading = true;
    });
    await gameLogic.fetchNewArticle();
    setState(() {
      loading = false;
    });
  }

  void revealWord(String word, String guess, double similarity) {
    setState(() {
      String normalizedWord = WordAnalyzer().normalize(word);

      if (similarity == 1.0) {
        gameLogic.currentArticle.revealedWords.add(word);
        if (normalizedWord != word) {
          gameLogic.currentArticle.revealedWords.add(normalizedWord);
        }
      }

      gameLogic.saveGameState();

      var allWords = gameLogic.currentArticle.content.split(RegExp(r'\s+'));
      bool allRevealed = allWords.every((word) =>
          gameLogic.currentArticle.revealedWords.contains(word) ||
          gameLogic.currentArticle.revealedWords
              .contains(WordAnalyzer().normalize(word)));

      if (allRevealed && !hasWon) {
        hasWon = true;
        revealAllWords();
        showWinDialog();
      }
    });
  }

  void revealAllWords() {
    var words = gameLogic.currentArticle.content.split(RegExp(r'\s+'));
    gameLogic.currentArticle.revealedWords.addAll(words);
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You found the title of the article!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isPunctuation(String word) {
    return "!.,;:'\"?()-".contains(word);
  }

  Widget _buildTitleContainer(String title, bool isVisible) {
    String displayTitle =
        isTextVisible || gameLogic.currentArticle.revealedWords.contains(title)
            ? title
            : ' ' * gameLogic.currentArticle.title.length;

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        displayTitle,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildWordContainer(
    String word,
    bool isBestGuess,
    bool isObfuscated, {
    bool isTitle = false,
  }) {
    String normalizedWord = WordAnalyzer().normalize(word);

    bool isRevealed = gameLogic.currentArticle.revealedWords.contains(word) ||
        gameLogic.currentArticle.revealedWords.contains(normalizedWord);

    String displayWord = isTextVisible || isRevealed ? word : ' ' * word.length;

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: isTitle
          ? const EdgeInsets.symmetric(vertical: 16.0)
          : const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        displayWord,
        style: TextStyle(
          fontStyle:
              isObfuscated && isBestGuess ? FontStyle.italic : FontStyle.normal,
          fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
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
                                _buildTitleContainer(
                                  gameLogic.currentArticle.title,
                                  isTextVisible ||
                                      gameLogic.currentArticle.revealedWords
                                          .contains(
                                              gameLogic.currentArticle.title),
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
                                  // Check if the line is a title
                                  if (line.startsWith('{{{') &&
                                      line.endsWith('}}}')) {
                                    String title = line
                                        .substring(3, line.length - 3)
                                        .trim();

                                    String displayWord = isTextVisible
                                        ? title
                                        : gameLogic.currentArticle.revealedWords
                                                .contains(title)
                                            ? title
                                            : gameLogic.currentArticle
                                                    .bestGuesses[title] ??
                                                ' ' * title.length;
                                    bool isBestGuess = gameLogic
                                        .currentArticle.bestGuesses
                                        .containsKey(title);

                                    return _buildWordContainer(
                                        displayWord, isBestGuess, true,
                                        isTitle: true);
                                  }

                                  // Process normal lines
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
                      if (inputWord == gameLogic.currentArticle.title) {
                        revealWord(
                            gameLogic.currentArticle.title, inputWord, 1.0);
                      }
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
