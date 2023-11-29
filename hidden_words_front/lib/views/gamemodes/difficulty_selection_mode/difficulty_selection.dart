import 'package:flutter/material.dart';
import 'package:hidden_words_front/logic/difficulties.dart';
import 'package:hidden_words_front/views/gamemodes/difficulty_selection_mode/difficulty_mode.dart';

class DifficultySelection extends StatefulWidget {
  const DifficultySelection({super.key});

  @override
  DifficultySelectionState createState() => DifficultySelectionState();
}

class DifficultySelectionState extends State<DifficultySelection> {
  String selectedDifficulty = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selectionner une difficulté'),
      ),
      body: ListView(
        children: articlesDifficulties.map((difficulty) {
          return ListTile(
            title: Text(difficulty),
            onTap: () {
              setState(() {
                selectedDifficulty = difficulty;
              });
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    DifficultyMode(difficulty: selectedDifficulty),
              ));
            },
          );
        }).toList(),
      ),
    );
  }
}
