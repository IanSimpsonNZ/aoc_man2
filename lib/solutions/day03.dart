import 'dart:convert';
import 'dart:isolate';

import 'package:collection/collection.dart';

import 'package:aoc_manager/solutions/generic_solution.dart';

class Day03P1 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 3 Part 1');

    final codeCapA = utf8.encode('A')[0];
    final codeSmallA = utf8.encode('a')[0] - codeCapA;

    final answer = (await lines().map((line) => utf8.encode(line)).toList())
        .where((line) => line.isNotEmpty)
        .map((bytes) => [
              bytes.sublist(0, bytes.length ~/ 2),
              bytes.sublist(bytes.length ~/ 2, bytes.length)
            ])
        .map((pockets) => [pockets[0].toSet(), pockets[1].toSet()])
        .map((pocketSets) =>
            pocketSets.reduce((first, second) => first.intersection(second)))
        .toList()
        .where((list) => list.isNotEmpty)
        .map((listInts) => listInts.first - codeCapA)
        .map((c) => (c >= codeSmallA ? c - codeSmallA : c + 26) + 1)
        .reduce((a, b) => a + b);

    say('The answer is $answer');
  }
}

class Day03P2 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;

    say('Day 3 Part 2');
    final codeCapA = utf8.encode('A')[0];
    final codeSmallA = utf8.encode('a')[0] - codeCapA;

    final answer = (await lines().map((line) => utf8.encode(line)).toList())
        .where((line) => line.isNotEmpty)
        .toList()
        .slices(3)
        .map((groupOf3) => groupOf3
            .map((list) => list.toSet())
            .toList()
            .reduce((first, next) => first.intersection(next)))
        .map((setInts) => setInts.first - codeCapA)
        .map((c) => (c >= codeSmallA ? c - codeSmallA : c + 26) + 1)
        .reduce((a, b) => a + b);

    say('The answer is $answer');
  }
}
