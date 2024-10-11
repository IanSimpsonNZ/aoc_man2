//import 'dart:convert';

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/CPU/cpu_v1.dart';
import 'package:aoc_manager/solutions/CPU/cpu_v2.dart';

// import 'dart:developer' as devtools show log;

class Day10P1 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 10 Part 1');

    int answer = 0;
    CPUv1 computer = CPUv1();
    computer.interrupts = [20, 60, 100, 140, 180, 220];

    await for (final signal in computer.run(lines())) {
      answer += signal;
    }

    say('Answer is $answer');
  }
}

class Day10P2 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 10 Part 2');

    CPUv2 computer = CPUv2();
    computer.interrupts = [40, 80, 120, 160, 200, 240];

    await for (final line in computer.run(lines())) {
      say(line);
    }
  }
}
