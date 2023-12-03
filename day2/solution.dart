import 'package:path/path.dart' show dirname, join;
import 'package:string_extensions/string_extensions.dart';
import 'package:collection/collection.dart';
import 'dart:io' show File, Platform;

void main() {
  print('Hello, World!');
  // get file in current directory.
  var path = Platform.script.path;
  print(path);
  var file = File(join(dirname(path), 'input.txt'));
  var lines = file.readAsLinesSync();
  var gameParser = GameParser();
  var games = lines.map((line) => gameParser.parse(line)).toList();

  var totalStones = Cubes(12, 13, 14);
  var gameCounts = games
      .where((game) => game.canBePlayedWith(totalStones))
      .map((game) => game.id)
      .sum;
  print(gameCounts);

  // part 2
  var totalGamePower = games
      .map((game) => game.minimumStonesItCanBePlayedWith())
      .map((minimalStones) =>
          minimalStones.red * minimalStones.green * minimalStones.blue)
      .sum;

  print(totalGamePower);
}

class Cubes {
  int red = 0;
  int green = 0;
  int blue = 0;

  Cubes(this.red, this.green, this.blue);
}

class Game {
  List<Cubes> cubes = [];
  int id;
  Game(this.id, this.cubes);

  bool canBePlayedWith(Cubes totalStones) {
    return cubes.every((cube) =>
        cube.red <= totalStones.red &&
        cube.green <= totalStones.green &&
        cube.blue <= totalStones.blue);
  }

  Cubes minimumStonesItCanBePlayedWith() {
    var red = cubes.map((cube) => cube.red).max;
    var green = cubes.map((cube) => cube.green).max;
    var blue = cubes.map((cube) => cube.blue).max;
    return Cubes(red, green, blue);
  }
}

class GameParser {
  Game parse(String line) {
    var parts = line.split(': ');
    var id = int.parse(parts[0].split(' ')[1]);
    var grabs = parts[1].split('; ');
    var cubes = grabs.map((grab) => parseCube(grab)).toList();
    return Game(id, cubes);
  }

  Cubes parseCube(String gameString) {
    var cube = Cubes(0, 0, 0);
    var cubeParts = gameString.split(', ');
    for (var part in cubeParts) {
      var x = part.split(' ');
      var color = x[1];
      var amount = int.parse(x[0]);
      if (color == 'red') {
        cube.red = amount;
      } else if (color == 'green') {
        cube.green = amount;
      } else if (color == 'blue') {
        cube.blue = amount;
      }
    }

    return cube;
  }
}
