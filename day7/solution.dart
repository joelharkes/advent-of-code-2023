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
    if (handType == other.handType) {
      // compare cards
      for (var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var otherCard = other.cards[i];
        if (card.value != otherCard.value) {
          return card.value > otherCard.value;
        }
      }
      throw Exception('Hands are equal');
      // return false;
    }
    return handType.index > other.handType.index;
  }

  int compareTo(Hand other) {
    if (winsFrom(other)) {
      return 1;
    }
    return -1;
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
        return 11;
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

  @override
  String toString() {
    return this.label;
  }
}
