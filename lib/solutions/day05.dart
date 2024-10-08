// import 'dart:convert';
import 'dart:isolate';

// import 'package:collection/collection.dart';

import 'package:aoc_manager/solutions/generic_solution.dart';

enum BoxMoverState {
  initialise,
  gettingBoxes,
  movingBoxes,
}

mixin BoxBuilder {
  List<List<String>>? columns;

  final boxStrLen = 4;
  List<String> getBoxes(String line) {
    List<String> result = [];
    int i;
    for (i = 0; i + boxStrLen < line.length; i += boxStrLen) {
      result.add(line[i + 1]);
    }
    if (i + 1 < line.length) {
      result.add(line[i + 1]);
    }
    return result;
  }

  Future<String> run(
    Stream<String> Function() lines,
    void Function({required int number, required int from, required int to})
        moveStrategy,
    void Function(String) say,
  ) async {
    BoxMoverState state = BoxMoverState.initialise;

    await for (final line in lines()) {
      switch (state) {
        case BoxMoverState.initialise:
          final testRow = getBoxes(line);
          columns = List.generate(testRow.length, (i) => <String>[]);
          state = BoxMoverState.gettingBoxes;
          continue GetBoxRow;

        GetBoxRow:
        case BoxMoverState.gettingBoxes:
          if (line.isEmpty) {
            state = BoxMoverState.movingBoxes;
            break;
          }
          final boxRow = getBoxes(line);
          if (boxRow[0] == '1') {
            final checkNumCols = int.parse(boxRow.last);
            assert(checkNumCols == columns!.length);
            break;
          }

          boxRow.asMap().forEach((colIndex, box) {
            if (box != ' ') {
              columns![colIndex].add(box);
              // say('Adding $box to column $colIndex');
            }
          });

        case BoxMoverState.movingBoxes:
          if (line.isEmpty) continue;
          final words = line.split(' ');
          // say(words.toString());
          final number = int.parse(words[1]);
          final from = int.parse(words[3]) - 1;
          final to = int.parse(words[5]) - 1;
          moveStrategy(number: number, from: from, to: to);
      }
    }

    String answer = '';
    for (final col in columns!) {
      answer = '$answer${col.first}';
    }

    return answer;
  }
}

class Day05P1 extends Solution with BoxBuilder {
  void moveOne({required int number, required int from, required int to}) {
    for (int i = 0; i < number; i++) {
      columns![to].insert(0, columns![from].removeAt(0));
    }
  }

  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 5 Part 1');

    say('The answer is ${await run(lines, moveOne, say)}');
  }
}

class Day05P2 extends Solution with BoxBuilder {
  void moveStack({required int number, required int from, required int to}) {
    for (int i = number - 1; i >= 0; i--) {
      columns![to].insert(0, columns![from].removeAt(i));
    }
  }

  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 5 Part 2');

    say('The answer is ${await run(lines, moveStack, say)}');
  }
}
