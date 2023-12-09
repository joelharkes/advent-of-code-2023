import 'dart:collection';

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
  var grid = lines.map((e) => e.split('').toList()).toList();
  final uniquePartNumbers = HashSet<PartNumber>(
    equals: (a, b) => a.x == b.x && a.y == b.y,
    hashCode: (a) => a.x.hashCode + a.y.hashCode,
  );
  grid.forEachIndexed((y, row) {
    row.forEachIndexed((x, element) {
      if (parseSchematicType(element) == SchematicType.Part) {
        var numbers = findNumbers(grid, x, y);
        uniquePartNumbers.addAll(numbers);
      }
    });
  });

  var sumOfPartNumbers = uniquePartNumbers.map((parts) => parts.number).sum;
  print(sumOfPartNumbers);

  // part 2: find gears
  var gearRatios = <int>[];
  grid.forEachIndexed((y, row) {
    row.forEachIndexed((x, element) {
      if (element == '*') {
        var numbers = findNumbers(grid, x, y);
        final uniquePartNumbers = HashSet<PartNumber>(
          equals: (a, b) => a.x == b.x && a.y == b.y,
          hashCode: (a) => a.x.hashCode + a.y.hashCode,
        );
        uniquePartNumbers.addAll(numbers);
        if (uniquePartNumbers.length == 2) {
          var gearRatio =
              uniquePartNumbers.map((e) => e.number).reduce((a, b) => a * b);
          gearRatios.add(gearRatio);
        }
      }
    });
  });
  var sumOfGearsRatios = gearRatios.sum;
  gearRatios.reduce((value, element) => value * element);
  print(sumOfGearsRatios);
}

enum SchematicType {
  Empty,
  PartNumber,
  Part,
}

// method to turn string into type
SchematicType parseSchematicType(String input) {
  switch (input) {
    case '.':
      return SchematicType.Empty;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      return SchematicType.PartNumber;
    default:
      return SchematicType.Part;
  }
}

class PartNumber {
  final int number;
  final int x;
  final int y;
  PartNumber(this.number, this.x, this.y);
}

List<PartNumber> findNumbers(List<List<String>> grid, int x, int y) {
  List<PartNumber> numbers = [];
  for (var i = -1; i <= 1; i++) {
    for (var j = -1; j <= 1; j++) {
      var field = grid[y + i][x + j];
      if (parseSchematicType(field) == SchematicType.PartNumber) {
        numbers.add(findNumber(grid, x + j, y + i));
      }
    }
  }
  return numbers;
}

PartNumber findNumber(List<List<String>> grid, int x, int y) {
  var startX = x;

  while (
      parseSchematicType(grid.getCell(startX, y)) == SchematicType.PartNumber) {
    startX--;
  }
  startX++; // back one to far.

  var numberString = '';
  var currentX = startX;
  while (parseSchematicType(grid.getCell(currentX, y)) ==
      SchematicType.PartNumber) {
    numberString += grid[y][currentX];
    currentX++;
  }
  var value = int.parse(numberString);
  return PartNumber(value, startX, y);
}

extension NumberParsing on List<List<String>> {
  // major domain hack but im lazy :D
  String getCell(x, y) {
    if (x < 0 || y < 0) {
      return '.';
    }
    if (y >= this.length) {
      return '.';
    }
    var row = this[y];
    if (x >= row.length) {
      return '.';
    }
    return row[x];
  }
}
