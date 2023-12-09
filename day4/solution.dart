import 'dart:collection';
import 'dart:math';
import 'package:path/path.dart' show dirname, join;
import 'package:collection/collection.dart';
import 'dart:io' show File, Platform;

import 'package:string_extensions/string_extensions.dart';

void main() {
  print('Hello, World!');
  // get file in current directory.
  var path = Platform.script.path;
  print(path);
  var file = File(join(dirname(path), 'input.txt'));
  var lines = file.readAsLinesSync();
  var scratchCards = lines.map(parseScratchCard).toList();
  var totalPoints = scratchCards.map((e) => e.points()).sum;
  print(totalPoints);

  // part 2 - matches gives you an additional instance of next cards.
  // count total instances of cards.
  var queue = Queue.of(scratchCards);
  int processedAmount = 0;
  while (queue.isNotEmpty) {
    var card = queue.removeFirst();
    // could be optimized by keeping active record of copies of each card.
    // instead of adding same card to the queue multiple times.
    var matches = card.matchingWinningNumbers();
    for (var i = 1; i <= matches; i++) {
      var cardToAdd = scratchCards[card.cardNumber + i - 1]; // offset 0;
      queue.add(cardToAdd);
    }
    processedAmount++;
  }
  print(processedAmount);
}

class ScratchCard {
  int cardNumber;
  final List<int> winningNumbers;
  final List<int> scratchNumbers;

  ScratchCard(this.cardNumber, this.winningNumbers, this.scratchNumbers);

  int matchingWinningNumbers() {
    return winningNumbers
        .where((element) => scratchNumbers.contains(element))
        .length;
  }

  num points() {
    var matches = matchingWinningNumbers();
    if (matches == 0) {
      return 0;
    }
    return pow(2, matches - 1);
  }
}

ScratchCard parseScratchCard(String input) {
  var parts = input.split(': ');
  var game = parts[0];
  var gameNumber = game.split(' ').last.toInt();
  var numbers = parts[1].split(' | ');
  var winningNumbers = numbers[0]
      .split(' ')
      .where((element) => element.isNotEmpty)
      .map((e) => e.toInt() as int)
      .toList();
  var scratchNumbers = numbers[1]
      .split(' ')
      .where((element) => element.isNotEmpty)
      .map((e) => e.toInt() as int)
      .toList();
  return ScratchCard(gameNumber as int, winningNumbers, scratchNumbers);
}
