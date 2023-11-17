import 'package:flutter/material.dart';
import 'package:hidden_words_front/logic/world_analyzer.dart';

class GuessPage extends StatefulWidget {
  const GuessPage({super.key});

  @override
  GuessPageState createState() => GuessPageState();
}

class GuessPageState extends State<GuessPage> {
  TextEditingController inputWordController = TextEditingController();
  final WordAnalyzer wordAnalyzer = WordAnalyzer();
  String article = "Texte de base pour tester, banane bananier";
  Set<String> revealedWords = <String>{};
  Map<String, String> bestGuesses = {};

  @override
  void dispose() {
    inputWordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> words = article.split(' ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hidden Words'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: words.map((word) {
                  String displayWord = revealedWords.contains(word)
                      ? word
                      : bestGuesses[word] ?? ' ' * word.length;
                  bool isBestGuess = bestGuesses.containsKey(word);

                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(
                      displayWord,
                      style: TextStyle(
                        fontStyle:
                            isBestGuess ? FontStyle.italic : FontStyle.normal,
                        color: isBestGuess ? Colors.red : Colors.black,
                      ),
                    ),
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
                wordAnalyzer.findSimilarWords(inputWord, article, revealWord);
              },
              child: const Text("Chercher"),
            ),
          ],
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
