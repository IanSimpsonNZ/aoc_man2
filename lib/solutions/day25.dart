// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' show min, max;

// import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
// import 'package:aoc_manager/solutions/helpers/coord.dart';

// import 'dart:developer' as devtools show log;

class Day25P1 extends Solution {
  int lineVal(String line) {
    int result = 0;
    int digitVal = 1;
    for (int cpos = line.length - 1; cpos >= 0; cpos--) {
      int thisVal = 0;
      final c = line[cpos];
      switch (c) {
        case '=':
          thisVal = -2;
        case '-':
          thisVal = -1;
        default:
          thisVal = int.parse(c);
      }
      result += thisVal * digitVal;
      digitVal *= 5;
    }

    return result;
  }

  String encode(int value) {
    String result = '';

    while (value > 0) {
      final rem = value % 5;
      value ~/= 5;
      if (rem == 3) {
        result = '=$result';
        value++;
      } else if (rem == 4) {
        result = '-$result';
        value++;
      } else {
        result = '$rem$result';
      }
    }

    return result;
  }

  @override
  Future<void> specificSolution() async {
    say('Day 25 Part 1');

    int total = 0;
    await for (final line in lines()) {
      total += lineVal(line);
    }

    say('Answer is ${encode(total)}');
  }
}

class Day25P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 25 Part 2');
  }
}
