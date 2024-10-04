import 'package:aoc_manager/solutions/generic_solution.dart';

class Day01P1 extends Solution {
  @override
  Future<int> solution() async {
    say('Day 1 Part 1');
    var total = 0;
    await for (final line in lines()) {
      if (line.isNotEmpty) total += int.parse(line);
    }
    say('The total is $total');
    return total;
  }
}
