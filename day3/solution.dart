import 'dart:collection';
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
  var grid = new Matrix(lines.map((e) => e.split('').toList()).toList());
  final uniquePartNumbers = UniquePartNumbers();
  grid.forEachCell((coordinate, cell) {
    if (parseSchematicType(cell) == SchematicType.Part) {
      var numbers = findNumbers(grid, coordinate);
      uniquePartNumbers.addAll(numbers);
    }
  });

  var sumOfPartNumbers = uniquePartNumbers.map((parts) => parts.number).sum;
  print(sumOfPartNumbers);

  // part 2: find gears
  var gearRatios = <int>[];
  grid.forEachCell((coordinate, cell) {
    if (cell == '*') {
      var numbers = findNumbers(grid, coordinate);
      // 2 numbers means its a gear
      if (numbers.length == 2) {
        var gearRatio = numbers.map((e) => e.number).reduce((a, b) => a * b);
        gearRatios.add(gearRatio);
      }
    }
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
  final Coordinate coordinate;
  PartNumber(this.number, this.coordinate);

  bool equals(PartNumber other) {
    return this.coordinate.equals(other.coordinate);
  }

  @override
  int get hashCode => coordinate.hashCode;
}

UniquePartNumbersType findNumbers(Matrix<String> grid, Coordinate coordinate) {
  var uniqueNumbers = UniquePartNumbers();
  grid.getNeighbourCoordinates(coordinate).forEach((neighbourCoordinate) {
    var cell = grid.getCell(neighbourCoordinate) ?? '.';
    if (parseSchematicType(cell) == SchematicType.PartNumber) {
      uniqueNumbers.add(findNumber(grid, neighbourCoordinate));
    }
  });
  return uniqueNumbers;
}

PartNumber findNumber(Matrix<String> grid, Coordinate coordinate) {
  var startX = coordinate.x;

  while (parseSchematicType(
          (grid.getCell(Coordinate(startX, coordinate.y))) ?? '.') ==
      SchematicType.PartNumber) {
    startX--;
  }
  startX++; // back one to far.

  var numberString = '';
  var currentX = startX;
  while (parseSchematicType(
          (grid.getCell(Coordinate(currentX, coordinate.y)) ?? '.')) ==
      SchematicType.PartNumber) {
    numberString += grid.getCell(Coordinate(currentX, coordinate.y)) as String;
    currentX++;
  }
  var value = int.parse(numberString);
  return PartNumber(value, Coordinate(startX, coordinate.y));
}

class Coordinate {
  final int x;
  final int y;
  Coordinate(this.x, this.y);

  bool equals(Coordinate other) {
    return this.x == other.x && this.y == other.y;
  }

  @override
  int get hashCode => x.hashCode + y.hashCode;
}

class Matrix<T> {
  final List<List<T>> _matrix;
  Matrix(this._matrix);

  T? getCell(Coordinate coordinate) {
    var x = coordinate.x;
    var y = coordinate.y;
    if (x < 0 || y < 0) {
      return null;
    }
    if (y >= this._matrix.length) {
      return null;
    }
    var row = this._matrix[y];
    if (x >= row.length) {
      return null;
    }
    return row[x];
  }

  void forEachCell(void Function(Coordinate coordinate, T cell) callback) {
    for (var y = 0; y < _matrix.length; y++) {
      var row = _matrix[y];
      for (var x = 0; x < row.length; x++) {
        callback(Coordinate(x, y), row[x]);
      }
    }
  }

  List<Coordinate> getNeighbourCoordinates(Coordinate coordinate) {
    var x = coordinate.x;
    var y = coordinate.y;
    var neighbours = <Coordinate>[];
    for (var i = -1; i <= 1; i++) {
      for (var j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) {
          continue;
        }
        var cell = getCell(Coordinate(x + i, y + j));
        if (cell != null) {
          neighbours.add(Coordinate(x + i, y + j));
        }
      }
    }
    return neighbours;
  }
}

typedef UniquePartNumbersType = HashSet<PartNumber>;
UniquePartNumbersType UniquePartNumbers([List<PartNumber>? parts]) {
  var set = HashSet<PartNumber>(
    equals: (a, b) => a.equals(b),
    hashCode: (a) => a.hashCode,
  );
  if (parts != null) {
    set.addAll(parts);
  }
  return set;
}
