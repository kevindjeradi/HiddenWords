// logic/world_analyzer.dart
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:text_analysis/text_analysis.dart';

class WordAnalyzer {
  String removePunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s]', unicode: true), '');
  }

  double getSimilarity(String? guess, String word) {
    if (guess == null) return 0;
    return TermSimilarity(guess, word).characterSimilarity;
  }

  String normalize(String word) {
    Map<String, String> diacriticsMap = {
      'à': 'a', 'á': 'a', 'â': 'a', 'ä': 'a', // Add more mappings as needed
      // ... other diacritic mappings ...
    };

    String normalized = word
        .split('')
        .map((c) {
          String normalizedChar = diacriticsMap[c] ?? c;
          Log.logger.i("Character: $c, Normalized: $normalizedChar");
          return normalizedChar;
        })
        .join()
        .toLowerCase();

    Log.logger.i("Original: $word, Normalized: $normalized");
    return normalized;
  }

  void findSimilarWords(
      String inputWord, String inputText, Function revealWordCallback) {
    String cleanedInputWord = removePunctuation(inputWord);
    String normalizedInputWord = normalize(cleanedInputWord);

    List<String> wordsInText = inputText.split(' ');

    for (String word in wordsInText) {
      String cleanedWord = removePunctuation(word);
      String normalizedWord = normalize(cleanedWord);

      Log.logger
          .i("Normalized Words: $normalizedInputWord <-> $normalizedWord");

      TermSimilarity similarity =
          TermSimilarity(normalizedInputWord, normalizedWord);

      if (similarity.characterSimilarity >= 0.65) {
        Log.logger.i(
            "Similarité de zinzin: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
        revealWordCallback(word, inputWord, similarity.characterSimilarity);
      }
    }
  }
}
