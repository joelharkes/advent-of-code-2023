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
  var games = lines.map(parseLine).toList();
  games.sort((a, b) => a.hand.compareTo(b.hand));
  // game was modified to only work for part 2.
  // to see part 1 look in git history.
  var sumOfWinnings =
      games.mapIndexed((index, game) => game.bet * (index + 1)).sum;
  print(sumOfWinnings);
}

Play parseLine(String line) {
  var parts = line.split(' ');
  var cards = parts[0].split('').map((e) => Card(e)).toList();
  var bet = int.parse(parts[1]);
  return Play(Hand(cards), bet);
}

class Play {
  Hand hand;
  int bet;
  Play(this.hand, this.bet);

  @override
  String toString() {
    return this.hand.toString() + ' $bet';
  }
}

class Hand {
  List<Card> cards;
  Hand(this.cards);

  Map<String, List<Card>> get cardGroups {
    return cards.groupListsBy((element) => element.label);
  }

  HandType get handType {
    var groups = cardGroups;
    if (groups.length == 1) {
      return HandType.FiveOfAKind;
    }
    if (groups.length == 5) {
      return HandType.HighCard;
    }
    var biggestGroupSize = groups.values.map((cards) => cards.length).max;
    if (biggestGroupSize == 4) {
      return HandType.FourOfAKind;
    }
    if (biggestGroupSize == 3) {
      if (groups.length == 2) {
        return HandType.FullHouse;
      }
      return HandType.ThreeOfAKind;
    }
    var pairs = groups.values.where((cards) => cards.length == 2).length;
    if (pairs == 2) {
      return HandType.TwoPair;
    }
    if (pairs == 1) {
      return HandType.OnePair;
    }
    throw Exception('Unknown hand type');
  }

  bool winsFrom(Hand other) {
    var myHandType = this.replacedJokers().handType;
    var otherHandType = other.replacedJokers().handType;
    if (myHandType == otherHandType) {
      // compare cards
      return winsByCardValue(other);
      // return false;
    }
    return myHandType.index > otherHandType.index;
  }

  bool winsByCardValue(Hand other) {
    for (var i = 0; i < cards.length; i++) {
      var card = cards[i];
      var otherCard = other.cards[i];
      if (card.value != otherCard.value) {
        return card.value > otherCard.value;
      }
    }
    throw Exception('Hands are equal');
  }

  int compareTo(Hand other) {
    if (winsFrom(other)) {
      return 1;
    }
    return -1;
  }

  Hand replacedJokers() {
    var groups = cardGroups;
    if (!groups.containsKey('J')) {
      return this;
    }
    var nonJokerGroups =
        groups.values.where((element) => !element[0].isJoker()).toList();
    if (nonJokerGroups.isEmpty) {
      // all jokers so we can continue
      return this;
    }
    var biggestGroup =
        nonJokerGroups.reduce((a, b) => a.length > b.length ? a : b);
    var biggetsLabel = biggestGroup[0].label;
    var newCards = cards.map((card) {
      if (card.isJoker()) {
        return Card(biggetsLabel);
      }
      return card;
    }).toList();
    return Hand(newCards);
  }

  @override
  String toString() {
    return this.cards.map((e) => e.toString()).join('');
  }
}

enum HandType {
  HighCard,
  OnePair,
  TwoPair,
  ThreeOfAKind,
  FullHouse,
  FourOfAKind,
  FiveOfAKind,
}

class Card {
  String label;
  Card(this.label);

  int get value {
    switch (label) {
      case 'T':
        return 10;
      case 'J':
        return 1;
      case 'Q':
        return 12;
      case 'K':
        return 13;
      case 'A':
        return 14;
      default:
        return int.parse(label);
    }
  }

  bool isJoker() {
    return label == 'J';
  }

  @override
  String toString() {
    return this.label;
  }
}
