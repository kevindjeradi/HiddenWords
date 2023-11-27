// logic/world_analyzer.dart
import 'package:characters/characters.dart';
import 'package:hidden_words_front/helpers/logger.dart';
import 'package:text_analysis/text_analysis.dart';

class WordAnalyzer {
  String removePunctuation(String text) {
    return text.replaceAll(RegExp(r'(?<=\w)[.,:;]+'), '');
  }

  double getSimilarity(String? guess, String word) {
    if (guess == null) return 0;
    return TermSimilarity(guess, word).characterSimilarity;
  }

  String normalize(String word) {
    Map<String, String> diacriticsMap = {
      'à': 'a',
      'á': 'a',
      'â': 'a',
      'ä': 'a',
      'ã': 'a',
      'å': 'a',
      'ā': 'a',
      'ç': 'c',
      'ć': 'c',
      'č': 'c',
      'è': 'e',
      'é': 'e',
      'ê': 'e',
      'ë': 'e',
      'ē': 'e',
      'ė': 'e',
      'ę': 'e',
      'ì': 'i',
      'í': 'i',
      'î': 'i',
      'ï': 'i',
      'ī': 'i',
      'į': 'i',
      'ı': 'i',
      'ł': 'l',
      'ñ': 'n',
      'ń': 'n',
      'ň': 'n',
      'ò': 'o',
      'ó': 'o',
      'ô': 'o',
      'ö': 'o',
      'õ': 'o',
      'ø': 'o',
      'ō': 'o',
      'ù': 'u',
      'ú': 'u',
      'û': 'u',
      'ü': 'u',
      'ū': 'u',
      'ÿ': 'y',
      'ź': 'z',
      'ż': 'z',
      'ž': 'z',
      'À': 'A',
      'Á': 'A',
      'Â': 'A',
      'Ä': 'A',
      'Ã': 'A',
      'Å': 'A',
      'Ā': 'A',
      'Ç': 'C',
      'Ć': 'C',
      'Č': 'C',
      'È': 'E',
      'É': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Ē': 'E',
      'Ė': 'E',
      'Ę': 'E',
      'Ì': 'I',
      'Í': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ī': 'I',
      'Į': 'I',
      'I': 'I',
      'Ł': 'L',
      'Ñ': 'N',
      'Ń': 'N',
      'Ň': 'N',
      'Ò': 'O',
      'Ó': 'O',
      'Ô': 'O',
      'Ö': 'O',
      'Õ': 'O',
      'Ø': 'O',
      'Ō': 'O',
      'Ù': 'U',
      'Ú': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ū': 'U',
      'Ÿ': 'Y',
      'Ź': 'Z',
      'Ż': 'Z',
      'Ž': 'Z',
    };

    // Using the characters package to handle grapheme clusters
    String normalized = word.characters
        .map((c) {
          String normalizedChar = diacriticsMap[c] ?? c;
          return normalizedChar;
        })
        .join()
        .toLowerCase();

    return normalized;
  }

  void findSimilarWords(
      String inputWord, String inputText, Function revealWordCallback) {
    String normalizedInputWord = normalize(removePunctuation(inputWord));

    List<String> wordsInText = inputText.split(' ');

    for (String word in wordsInText) {
      String normalizedWord = normalize(removePunctuation(word));

      TermSimilarity similarity =
          TermSimilarity(normalizedInputWord, normalizedWord);

      if (similarity.characterSimilarity >= 0.65) {
        Log.logger.i(
            "Similarité de zinzin: $normalizedInputWord <-> $normalizedWord (Similarité: ${similarity.characterSimilarity})");
        revealWordCallback(word, inputWord, similarity.characterSimilarity);
      }
    }
  }
}
