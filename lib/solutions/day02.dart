import 'dart:convert';
import 'dart:isolate';

import 'package:aoc_manager/solutions/generic_solution.dart';

class Day02P1 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 2 Part 1');

    //   My go
    // X   Y   Z
    //(R) (P) (S)
    const score = [
      [4, 8, 3], // (R) A
      [1, 5, 9], // (P) B  Their go
      [7, 2, 6], // (S) C
    ];

    final codeA = utf8.encode('A')[0];
    final codeX = utf8.encode('X')[0];

    final funcScore = await lines()
        .map((s) => s.split(' '))
        .map((charPair) => [
              utf8.encode(charPair[0])[0] - codeA,
              utf8.encode(charPair[1])[0] - codeX
            ])
        .map((idxPair) => score[idxPair[0]][idxPair[1]])
        .reduce((a, b) => a + b);

    // int totalScore = 0;
    // await for (final line in lines()) {
    //   if (line.length == 3) {
    //     final round = line.split(' ');
    //     final theirGo = ascii.encode(round[0])[0] - codeA;
    //     final myGo = ascii.encode(round[1])[0] - codeX;
    //     final thisScore = score[theirGo][myGo];
    //     totalScore += thisScore;
    //     say('${round.toString()} = $thisScore');
    //   }
    // }

    say('Answer is $funcScore');
  }
}

class Day02P2 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;

    say('Day 2 Part 2');
    //   My go
    // X   Y   Z
    //(L) (D) (W)
    const score = [
      [3 + 0, 1 + 3, 2 + 6], // (R) A
      [1 + 0, 2 + 3, 3 + 6], // (P) B  Their go
      [2 + 0, 3 + 3, 1 + 6], // (S) C
    ];

    final codeA = utf8.encode('A')[0];
    final codeX = utf8.encode('X')[0];

    int totalScore = 0;
    await for (final line in lines()) {
      if (line.length == 3) {
        final round = line.split(' ');
        final theirGo = ascii.encode(round[0])[0] - codeA;
        final myGo = ascii.encode(round[1])[0] - codeX;
        final thisScore = score[theirGo][myGo];
        totalScore += thisScore;
        say('${round.toString()} = $thisScore');
      }
    }

    say('Answer is $totalScore');
  }
}
