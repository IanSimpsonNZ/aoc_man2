import 'package:aoc_manager/solutions/generic_solution.dart';

class Day01P2 extends Solution {
  final top3 = [0, 0, 0];
  @override
  Future<int> solution() async {
    say('Day 1 Part 2');
    var total = 0;
    await for (final line in lines()) {
      if (line.isNotEmpty) {
        total += int.parse(line);
      } else {
        // say('total is $total');
        // say('top3 are ${top3.toString()}');
        slotIn(total);
        total = 0;
      }
    }
    slotIn(total);

    say('top3 are ${top3.toString()}');
    final answer = top3.reduce((a, b) => a + b);
    say('The answer is $answer');
    return total;
  }

  void slotIn(newTot) {
    var testNum = newTot;
    for (int idx = 0; idx < top3.length; idx++) {
      if (testNum > top3[idx]) {
        final tmp = top3[idx];
        top3[idx] = testNum;
        testNum = tmp;
      }
    }
  }
}
