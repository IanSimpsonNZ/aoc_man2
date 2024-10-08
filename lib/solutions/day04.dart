// import 'dart:convert';
import 'dart:isolate';

// import 'package:collection/collection.dart';

import 'package:aoc_manager/solutions/generic_solution.dart';

class Assignment {
  final int start;
  final int end;

  Assignment({required this.start, required this.end}) {
    assert(start <= end);
  }

  bool contains(Assignment other) => (start <= other.start && end >= other.end);

  bool overlaps(Assignment other) =>
      ((start <= other.start && end >= other.start) ||
          (start <= other.end && end >= other.end));
}

class Day04P1 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 4 Part 1');

    final answer = (await lines()
            .where((line) => line.isNotEmpty)
            .map((line) => line.split(','))
            .map((assignmentPairStr) => assignmentPairStr
                .map((assignmentStr) => assignmentStr
                    .split('-')
                    .map((numStr) => int.parse(numStr))
                    .toList())
                .map(
                    (intList) => Assignment(start: intList[0], end: intList[1]))
                .toList())
            .where((assignmentPair) =>
                assignmentPair[0].contains(assignmentPair[1]) ||
                assignmentPair[1].contains(assignmentPair[0]))
            .toList())
        .length;

    say('The answer is $answer');
  }
}

class Day04P2 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;

    say('Day 4 Part 2');

    final answer = (await lines()
            .where((line) => line.isNotEmpty)
            .map((line) => line.split(','))
            .map((assignmentPairStr) => assignmentPairStr
                .map((assignmentStr) => assignmentStr
                    .split('-')
                    .map((numStr) => int.parse(numStr))
                    .toList())
                .map(
                    (intList) => Assignment(start: intList[0], end: intList[1]))
                .toList())
            .where((assignmentPair) =>
                assignmentPair[0].overlaps(assignmentPair[1]) ||
                assignmentPair[1].overlaps(assignmentPair[0]))
            .toList())
        .length;

    say('The answer is $answer');
  }
}
