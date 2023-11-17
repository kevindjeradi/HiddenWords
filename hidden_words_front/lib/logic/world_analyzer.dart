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

  void findSimilarWords(
      String inputWord, String inputText, Function revealWordCallback) {
    String cleanedInputWord = removePunctuation(inputWord);
    List<String> wordsInText = inputText.split(' ');

    for (String word in wordsInText) {
      String cleanedWord = removePunctuation(word);
      TermSimilarity similarity = TermSimilarity(cleanedInputWord, cleanedWord);

      if (similarity.characterSimilarity >= 0.65) {
        Log.logger.i(
            "Similarité de zinzin: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
        revealWordCallback(word, inputWord, similarity.characterSimilarity);
      } else if (similarity.characterSimilarity > 0.5 &&
          similarity.characterSimilarity < 0.65) {
        Log.logger.i(
            "similarité okay tier: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
      } else if (similarity.characterSimilarity > 0.3 &&
          similarity.characterSimilarity < 0.5) {
        // Log.logger.i(
        //     "similarité moyenne: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
      } else {
        // Log.logger.i(
        //     "Similarité claquée au sol: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
      }
    }
  }
}
