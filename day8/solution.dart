import 'package:path/path.dart' show dirname, join;
import 'package:collection/collection.dart';
import 'dart:io' show File, Platform;

import 'package:string_extensions/string_extensions.dart';

import '../day6/solution.dart';

void main() {
  // get file in current directory.
  var path = Platform.script.path;
  print(path);
  var file = File(join(dirname(path), 'input.txt'));
  var lines = file.readAsLinesSync();
  var moves = lines[0].split(''); // LRLRL
  var nodes = lines.skip(2).map(parseNode);
  var map = Map.fromEntries(nodes.map((e) => MapEntry(e.name, e)));
  var currentNode = map['AAA'] as Node;
  var steps = 0;
  steps = traverseCountSteps(currentNode, moves, map, (name) => name == 'ZZZ');
  print(steps);

  // part 2
  steps = 0;
  var startNodes =
      map.values.where((element) => element.name.endsWith('A')).toList();

  var countOfStepsToEnd = startNodes
      .map((start) =>
          traverseCountSteps(start, moves, map, (name) => name.endsWith('Z')))
      .toList();
  var result = countOfStepsToEnd.reduce(leastCommonDivisor);

  print('lol: ' + result.toString());
}

int leastCommonDivisor(int a, int b) {
  var gcd = a.gcd(b);
  return ((a ~/ gcd) * b).abs();
}

int traverseCountSteps(Node currentNode, List<String> moves,
    Map<String, Node> map, bool Function(String) hasReachedEndState) {
  var steps = 0;
  while (!hasReachedEndState(currentNode.name)) {
    var move = moves[steps % moves.length];
    currentNode = traverseOnce(map, move, currentNode);
    if (steps % 10000 == 0) print(currentNode.name + ' ' + steps.toString());
    steps++;
  }
  return steps;
}

Node traverseOnce(Map<String, Node> map, String move, Node currentNode) {
  if (move == 'L') {
    return map[currentNode.leftName] as Node;
  } else {
    return map[currentNode.rightName] as Node;
  }
}

Node parseNode(String line) {
  var reg = new RegExp(r'[A-Z]{3}');
  var matches = reg.allMatches(line).toList();

  return Node(matches[0].group(0) as String, matches[1].group(0) as String,
      matches[2].group(0) as String);
}

class Node {
  String name;
  String leftName;
  String rightName;
  Node(this.name, this.leftName, this.rightName);
}
