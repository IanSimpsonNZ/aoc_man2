import 'dart:isolate';

import 'dart:developer' as devtools show log;

import 'package:aoc_manager/solutions/generic_solution.dart';

class Day01P1 extends Solution {
  @override
  Future<void> solution(SendPort sendPort) async {
    devtools.log("We're in!");
    const String msg = 'Day 1 Part 1';
    devtools.log('Sending: $msg of type ${msg.runtimeType}');
    say('Day 1 Part 1', sendPort);
    var total = 0;
    var maxTotal = 0;
    await for (final line in lines()) {
      if (line.isNotEmpty) {
        total += int.parse(line);
      } else {
        if (total > maxTotal) {
          maxTotal = total;
        }
        total = 0;
      }
    }
    say('The answer is $maxTotal', sendPort);
  }
}

class Day01P2 extends Solution {
  var _top3 = [0, 0, 0];
  @override
  Future<void> solution(SendPort sendPort) async {
    say('Day 1 Part 2', sendPort);
    var total = 0;
    _top3 = [0, 0, 0];
    await for (final line in lines()) {
      if (line.isNotEmpty) {
        total += int.parse(line);
      } else {
        _slotIn(total);
        total = 0;
      }
    }
    _slotIn(total);

    say('top3 are ${_top3.toString()}', sendPort);
    final answer = _top3.reduce((a, b) => a + b);
    say(answer.toString(), sendPort);
  }

  void _slotIn(newTot) {
    var testNum = newTot;
    for (int idx = 0; idx < _top3.length; idx++) {
      if (testNum > _top3[idx]) {
        final tmp = _top3[idx];
        _top3[idx] = testNum;
        testNum = tmp;
      }
    }
  }
}
