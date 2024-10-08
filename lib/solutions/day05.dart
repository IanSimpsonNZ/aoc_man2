// import 'dart:convert';
import 'dart:isolate';

// import 'package:collection/collection.dart';

import 'package:aoc_manager/solutions/generic_solution.dart';

enum BoxMoverState {
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
}

class Day05P1 extends Solution with BoxBuilder {
  void move({required int number, required int from, required int to}) {
    for (int i = 0; i < number; i++) {
      columns![to].insert(0, columns![from].removeAt(0));
    }
  }

  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 5 Part 1');

    BoxMoverState state = BoxMoverState.gettingBoxes;

    await for (final line in lines()) {
      switch (state) {
        case BoxMoverState.gettingBoxes:
          if (line.isEmpty) {
            state = BoxMoverState.movingBoxes;
            break;
          }

          final boxRow = getBoxes(line);
          columns ??= List.generate(boxRow.length, (i) => <String>[]);
          if (boxRow[0] == '1') {
            final checkNumCols = int.parse(boxRow.last);
            assert(checkNumCols == columns!.length);
            break;
          }

          boxRow.asMap().forEach((colIndex, box) {
            if (box != ' ') {
              columns![colIndex].add(box);
              say('Adding $box to column $colIndex');
            }
          });

        case BoxMoverState.movingBoxes:
          if (line.isEmpty) continue;
          final words = line.split(' ');
          say(words.toString());
          final number = int.parse(words[1]);
          final from = int.parse(words[3]) - 1;
          final to = int.parse(words[5]) - 1;
          move(number: number, from: from, to: to);
      }
    }

    String answer = '';
    for (final col in columns!) {
      say(col.toString());
      answer = '$answer${col.first}';
    }

    say('The answer is $answer');
  }
}

class Day05P2 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;

    say('Day 5 Part 2');

    final answer = await lines();

    say('The answer is $answer');
  }
}
