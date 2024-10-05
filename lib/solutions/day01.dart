import 'package:aoc_manager/solutions/generic_solution.dart';

class Day01P1 extends Solution {
  @override
  Stream<String> solution() async* {
    yield 'Day 1 Part 1';
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
    yield 'The answer is $maxTotal';
  }
}

class Day01P2 extends Solution {
  var _top3 = [0, 0, 0];
  @override
  Stream<String> solution() async* {
    yield 'Day 1 Part 2';
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

    yield 'top3 are ${_top3.toString()}';
    final answer = _top3.reduce((a, b) => a + b);
    yield answer.toString();
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
