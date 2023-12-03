import 'package:path/path.dart' show dirname, join;
import 'package:string_extensions/string_extensions.dart';
import 'dart:io' show File, Platform;

void main() {
  print('Hello, World!');
  // get file in current directory.
  var path = Platform.script.path;
  print(path);
  var file = File(join(dirname(path), 'input.txt'));
  var lines = file.readAsLinesSync();
  var digitFinder = RegExp(r'\d');

  var sum = 0;
  for (var line in lines) {
    var matches = digitFinder.allMatches(line);
    var firstDigit = matches.first.group(0) as String;
    var lastDigit = matches.last.group(0) as String;
    var parsedNumber = int.parse(firstDigit + lastDigit);
    sum += parsedNumber;
  }
  print(sum);

  // part 2
  var digitFinderV2 =
      RegExp(r'(\d|one|two|three|four|five|six|seven|eight|nine|zero)');
  var regexFindReversedDigits =
      RegExp(r'(\d|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin|orez)');
  final digitMap = {
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9',
    'zero': '0'
  };
  var sum2 = 0;
  for (var line in lines) {
    var firstMatch = digitFinderV2.firstMatch(line);
    var lastMatch = regexFindReversedDigits.firstMatch(line.reverse as String);
    var firstDigitText = firstMatch?.group(0) as String;
    var firstDigit = digitMap[firstDigitText] ?? firstDigitText;
    var lastDigitText = lastMatch?.group(0) as String;
    var lastDigit = digitMap[lastDigitText.reverse] ?? lastDigitText;
    var parsedNumber = int.parse(firstDigit + lastDigit);
    sum2 += parsedNumber;
  }
  print(sum2);
}
