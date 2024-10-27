// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' show max;
// import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
// import 'package:aoc_manager/solutions/helpers/coord.dart';

// import 'dart:developer' as devtools show log;

class Number {
  final int value;
  int moveCount = 0;

  Number(this.value);

  @override
  String toString() => '$value';
}

class Number2 {
  int value;
  final int moveOrder;
  int moveCount = 0;

  Number2(this.value, this.moveOrder);

  @override
  String toString() => '$value';
}

class Day20P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 20 Part 1');

    List<Number> message = [];

    await for (final line in lines()) {
      if (line.isEmpty) {
        break;
      }
      message.add(Number(int.parse(line)));
    }

    int cursor = 0;
    while (cursor < message.length) {
      if (message[cursor].moveCount != 0) {
        cursor++;
        continue;
      }

      final number = message.removeAt(cursor);
      // say('Moving ${number.value}');
      number.moveCount++;
      int newPosition = (number.value + cursor) % message.length;
      if (newPosition == 0 && number.value < 0) {
        newPosition = message.length;
      }
      if (newPosition <= cursor) {
        cursor++;
      }
      message.insert(newPosition, number);

      // say(message.toString());
    }

    final zeroPos = message.indexWhere((n) => n.value == 0);
    final answer = message[(zeroPos + 1000) % message.length].value +
        message[(zeroPos + 2000) % message.length].value +
        message[(zeroPos + 3000) % message.length].value;

    say('The answer is $answer');
  }
}

class Day20P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 20 Part 2');

    List<Number2> message = [];

    int moveOrder = 0;
    await for (final line in lines()) {
      if (line.isEmpty) {
        break;
      }
      message.add(Number2(int.parse(line), moveOrder));
      moveOrder++;
    }

    const key = 811589153;

    for (final num in message) {
      num.value *= key;
    }
    const numIters = 10;

    for (var i = 0; i < numIters; i++) {
      int cursor = 0;
      while (cursor < message.length) {
        final numIdx = message.indexWhere((v) => v.moveOrder == cursor);

        final number = message.removeAt(numIdx);
        // say('Moving ${number.value}');
        number.moveCount++;
        int newPosition = (number.value + numIdx) % message.length;
        if (newPosition == 0 && number.value < 0) {
          newPosition = message.length;
        }
        message.insert(newPosition, number);

        cursor++;

        // say(message.toString());
      }
    }

    final zeroPos = message.indexWhere((n) => n.value == 0);
    final answer = message[(zeroPos + 1000) % message.length].value +
        message[(zeroPos + 2000) % message.length].value +
        message[(zeroPos + 3000) % message.length].value;

    say('The answer is $answer');
  }

  // 129 too low
}
