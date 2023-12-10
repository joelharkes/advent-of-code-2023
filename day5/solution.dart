import 'package:path/path.dart' show dirname, join;
import 'package:collection/collection.dart';
import 'dart:io' show File, Platform;

void main() {
  print('Hello, World!');
  // get file in current directory.
  var path = Platform.script.path;
  print(path);
  var file = File(join(dirname(path), 'input.txt'));
  var lines = file.readAsLinesSync();
  var almanac = deserializeAlmanac(lines);
  print(almanac.seeds.length);
  var lowest =
      almanac.seeds.map((seed) => almanac.translateOrKeepOriginal(seed)).min;
  print('lowest: $lowest');

  // part 2
  var lowestOfRange = almanac
      .getSeedRanges()
      .map((seedRange) =>
          // very slow but works for now.
          Iterable<int>.generate(seedRange.$2, (i) => i + seedRange.$1)
              .map((seedNumber) => almanac.translateOrKeepOriginal(seedNumber))
              .min)
      .min;
  print('lowest range: $lowestOfRange');
}

Almanac deserializeAlmanac(List<String> input) {
  var iterator = input.iterator;
  iterator.moveNext();
  var seeds = iterator.current
      .replaceFirst('seeds: ', '')
      .split(' ')
      .map((e) => int.parse(e))
      .toList();
  var maps = <TranslationMap>[];
  iterator.moveNext(); // empty row
  while (iterator.moveNext()) {
    var name = iterator.current;
    var ranges = <TranslationRange>[];
    while (iterator.moveNext() && iterator.current.isNotEmpty) {
      var rangeLine = iterator.current;
      var translationNumbers =
          rangeLine.split(' ').map((e) => int.parse(e)).toList();
      ranges.add(TranslationRange(
          translationNumbers[0], translationNumbers[1], translationNumbers[2]));
    }
    var translationMap = TranslationMap(name, ranges);
    maps.add(translationMap);
  }

  return Almanac(seeds, maps);
}

class Almanac {
  List<int> seeds;
  List<TranslationMap> translationMaps;
  Almanac(this.seeds, this.translationMaps);

  int translate(int seedNumber) {
    var finalDestination = translationMaps.fold(
        seedNumber, (previous, element) => element.translate(seedNumber));
    return finalDestination;
  }

  int translateOrKeepOriginal(int seedNumber) {
    var finalDestination = translationMaps.fold(seedNumber,
        (currentNumber, map) => map.translateOrKeepOriginal(currentNumber));
    return finalDestination;
  }

  List<(int, int)> getSeedRanges() {
    var seedRanges = <(int, int)>[];
    for (var i = 0; i < seeds.length; i += 2) {
      seedRanges.add((seeds[i], seeds[i + 1]));
    }
    return seedRanges;
  }
}

class TranslationMap {
  String name;
  List<TranslationRange> ranges;
  TranslationMap(this.name, this.ranges);

  int translate(int number) {
    for (var range in ranges) {
      if (range.isInRange(number)) {
        return range.translate(number);
      }
    }
    throw Exception('Number $number is not in any range of map $name');
  }

  int translateOrKeepOriginal(int number) {
    for (var range in ranges) {
      if (range.isInRange(number)) {
        return range.translate(number);
      }
    }
    return number;
  }
}

class TranslationRange {
  int destinationStart;
  int sourceStart;
  int rangeLength;
  TranslationRange(this.destinationStart, this.sourceStart, this.rangeLength);

  bool isInRange(int number) {
    return number >= sourceStart && number < sourceStart + rangeLength;
  }

  int translate(int number) {
    if (!isInRange(number)) {
      throw Exception('Number $number is not in range');
    }
    return destinationStart + (number - sourceStart);
  }
}
