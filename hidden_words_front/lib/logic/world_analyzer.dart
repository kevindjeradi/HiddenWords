import 'package:hidden_words_front/helpers/logger.dart';
import 'package:text_analysis/text_analysis.dart';

class WordAnalyzer {
  void findSimilarWords(
      String inputWord, String inputText, Function revealWordCallback) {
    List<String> wordsInText = inputText.split(' ');

    for (String word in wordsInText) {
      TermSimilarity similarity = TermSimilarity(inputWord, word);

      if (similarity.characterSimilarity == 1) {
        revealWordCallback(word);
      } else if (similarity.characterSimilarity > 0.7) {
        Log.logger.i(
            "Similarité de zinzin: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
      } else if (similarity.characterSimilarity > 0.5 &&
          similarity.characterSimilarity < 0.7) {
        Log.logger.i(
            "similarité okay tier: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
      } else if (similarity.characterSimilarity > 0.3 &&
          similarity.characterSimilarity < 0.5) {
        Log.logger.i(
            "similarité moyenne: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
      } else {
        Log.logger.i(
            "Similarité claquée au sol: $inputWord <-> $word (Similarité: ${similarity.characterSimilarity})");
      }
    }
  }
}
