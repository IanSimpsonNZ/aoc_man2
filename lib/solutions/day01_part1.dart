import 'package:aoc_manager/solutions/generic_solution.dart';

class Day01P1 extends Solution {
  @override
  Future<int> solution() async {
    say('Day 1 Part 1');
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
    say('The answer is $maxTotal');
    return total;
  }
}
