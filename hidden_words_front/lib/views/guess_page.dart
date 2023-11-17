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
                children: words
                    .map((word) => Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(word),
                        ))
                    .toList(),
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
                wordAnalyzer.findSimilarWords(inputWord, article);
              },
              child: const Text("Chercher"),
            ),
          ],
        ),
      ),
    );
  }
}
