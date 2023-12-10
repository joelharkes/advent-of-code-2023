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

  var times =
      lines[0].split(new RegExp(r'\s+')).skip(1).map(int.parse).toList();
  var distances =
      lines[1].split(new RegExp(r'\s+')).skip(1).map(int.parse).toList();

  var races =
      times.mapIndexed((index, time) => Race(time, distances[index])).toList();

  races.map((e) => e.amountOfWinningOptions()).forEach(print);

  var numbersOfWaysToWin = races.map((e) => e.amountOfWinningOptions()).product;
  print(numbersOfWaysToWin);

  // part 2
  var time =
      lines[0].replaceAll(' ', '').replaceFirst('Time:', '').toInt() as int;
  var highScore =
      lines[1].replaceAll(' ', '').replaceFirst('Distance:', '').toInt() as int;
  var race = Race(time, highScore);
  print(race.amountOfWinningOptions());
}

class Race {
  int maxTime;
  int highscoreDistance;
  Race(this.maxTime, this.highscoreDistance);

  List<RaceOption> raceOptions() {
    return Iterable<int>.generate(maxTime + 1, (i) => i)
        .map((e) => RaceOption(e, maxTime, e * (maxTime - e)))
        .toList();
  }

  List<RaceOption> raceOptionsThatGetHigherScore() {
    return raceOptions()
        .where((element) => element.distanceTraveled > highscoreDistance)
        .toList();
  }

  int amountOfWinningOptions() {
    return raceOptionsThatGetHigherScore().length;
  }
}

class RaceOption {
  int timePressingButton;
  int maxTime;
  int distanceTraveled;
  RaceOption(this.timePressingButton, this.maxTime, this.distanceTraveled);
}

extension ProductExtension<T extends num> on Iterable<T> {
  T get product {
    if (this.isEmpty) {
      return 0 as T;
    }
    return this.reduce((value, element) => value * element as T);
  }
}
