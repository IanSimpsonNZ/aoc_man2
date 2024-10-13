//import 'dart:convert';

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

const numSegments = 10;

class Rope {
  List<Coord> rope;
  Set<Coord> tailTrack1 = {Coord(0, 0)};
  Set<Coord> tailTrack9 = {Coord(0, 0)};

  Rope() : rope = List<Coord>.generate(numSegments, (i) => Coord(0, 0));

  void moveHead(String dir, int numSteps) {
    assert(dir.isNotEmpty);
    assert(numSteps > 0);

    Coord delta = Coord(0, 0);
    switch (dir[0]) {
      case 'U':
        delta.y = 1;
      case 'D':
        delta.y = -1;
      case 'R':
        delta.x = 1;
      case 'L':
        delta.x = -1;
      default:
        devtools.log('Invalid direction: "$dir[0]"');
    }

    for (int i = 0; i < numSteps; i++) {
      rope[0] += delta;
      _moveTail(1);
    }
  }

  void _moveTail(int segNum) {
    assert(segNum > 0);
    if (segNum == numSegments) return;

    final Coord diff = rope[segNum - 1] - rope[segNum];
    Coord move = Coord(0, 0);

    if (diff.x.abs() == 2 && diff.y.abs() == 2) {
      move.x = diff.x ~/ 2;
      move.y = diff.y ~/ 2;
    } else if (diff.x.abs() == 2) {
      move.x = diff.x ~/ 2;
      move.y = diff.y;
    } else if (diff.y.abs() == 2) {
      move.y = diff.y ~/ 2;
      move.x = diff.x;
    }

    rope[segNum] += move;
    if (segNum == 1) tailTrack1.add(rope[segNum]);
    if (segNum == numSegments - 1) tailTrack9.add(rope[segNum]);

    _moveTail(segNum + 1);
  }
}

class Day09P1 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 9 Part 1');

    Rope rope = Rope();

    await for (final line in lines()) {
      final lineParts = line.split(' ');
      final dir = lineParts[0];
      final numSteps = int.parse(lineParts[1]);
      rope.moveHead(dir, numSteps);
    }

    say('Answer is ${rope.tailTrack1.length}');
  }
}

class Day09P2 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 9 Part 2');

    Rope rope = Rope();

    await for (final line in lines()) {
      final lineParts = line.split(' ');
      final dir = lineParts[0];
      final numSteps = int.parse(lineParts[1]);
      rope.moveHead(dir, numSteps);
    }

    say('Answer is ${rope.tailTrack9.length}');
  }
}
