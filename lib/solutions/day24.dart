// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' show min, max;

// import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

class BlizzState {
  final Coord position;
  final int time;

  BlizzState({required this.position, required this.time});

  @override
  bool operator ==(Object other) =>
      other is BlizzState && other.position == position && other.time == time;
  @override
  int get hashCode => Object.hash(position, time);
}

class Blizzard {
  List<String> leftToRight = [];
  List<String> rightToLeft = [];
  List<String> topToBottom = [];
  List<String> bottomToTop = [];

  int numCols = 0;
  int numRows = 0;

  Coord entrance = Coord(0, -1);
  Coord exit = Coord(0, 0);

  Future<void> getMap(Stream<String> lines) async {
    int rowNum = 0;
    await for (final line in lines) {
      if (line.isEmpty) break;

      if (rowNum == 0) {
        assert(line[1] == '.');
        for (int col = 1; col < line.length - 1; col++) {
          topToBottom.add('');
          bottomToTop.add('');
        }
        rowNum++;
        continue;
      }

      if (line[1] == '#') {
        assert(line[line.length - 2] == '.');
        break;
      }

      leftToRight.add('');
      rightToLeft.add('');

      for (int lineCol = 1; lineCol < line.length - 1; lineCol++) {
        final col = lineCol - 1;
        switch (line[lineCol]) {
          case '>':
            leftToRight.last = '${leftToRight.last}>';
            rightToLeft.last = '${rightToLeft.last}.';
            topToBottom[col] = '${topToBottom[col]}.';
            bottomToTop[col] = '${bottomToTop[col]}.';
          case '<':
            leftToRight.last = '${leftToRight.last}.';
            rightToLeft.last = '${rightToLeft.last}<';
            topToBottom[col] = '${topToBottom[col]}.';
            bottomToTop[col] = '${bottomToTop[col]}.';
          case 'v':
            leftToRight.last = '${leftToRight.last}.';
            rightToLeft.last = '${rightToLeft.last}.';
            topToBottom[col] = '${topToBottom[col]}v';
            bottomToTop[col] = '${bottomToTop[col]}.';
          case '^':
            leftToRight.last = '${leftToRight.last}.';
            rightToLeft.last = '${rightToLeft.last}.';
            topToBottom[col] = '${topToBottom[col]}.';
            bottomToTop[col] = '${bottomToTop[col]}^';
          default:
            leftToRight.last = '${leftToRight.last}.';
            rightToLeft.last = '${rightToLeft.last}.';
            topToBottom[col] = '${topToBottom[col]}.';
            bottomToTop[col] = '${bottomToTop[col]}.';
        }
      }

      rowNum++;
    }

    numCols = topToBottom.length;
    numRows = leftToRight.length;

    exit = Coord(numCols - 1, numRows);
  }

  int getCol(int rawCol) => rawCol % numCols;
  int getRow(int rawRow) => rawRow % numRows;

  bool inBounds(Coord pos) {
    return (pos.x >= 0) &&
            (pos.x < numCols) &&
            (pos.y >= 0) &&
            (pos.y < numRows) ||
        (pos == entrance) ||
        (pos == exit);
  }

  bool isFree(Coord pos, int clock) {
    if (!inBounds(pos)) return false;
    if (pos == entrance || pos == exit) return true;

    final colLtr = getCol(pos.x - clock);
    final colRtl = getCol(pos.x + clock);
    final rowTtb = getRow(pos.y - clock);
    final rowBtt = getRow(pos.y + clock);
    return (leftToRight[pos.y][colLtr] == '.') &&
        (rightToLeft[pos.y][colRtl] == '.') &&
        (topToBottom[pos.x][rowTtb] == '.') &&
        (bottomToTop[pos.x][rowBtt] == '.');
  }

  void print(BlizzState state, void Function(String) say) {
    say('Time: ${state.time}');
    say('#.${'#' * (numCols - 2)}');
    for (int r = 0; r < numRows; r++) {
      String line = '#';
      for (int c = 0; c < numCols; c++) {
        String nextChar = '';
        if (state.position == Coord(c, r)) {
          nextChar = 'E';
        } else if (isFree(Coord(c, r), state.time)) {
          nextChar = '.';
        } else {
          nextChar = '@';
        }
        line = '$line$nextChar';
      }
      say('$line#');
    }
    say('${'#' * (numCols - 2)}.#');
  }

  int? getPath(Coord start, Coord goal, int startTime) {
    int? bestTime;
    Set<BlizzState> beenHere = {};
    List<BlizzState> stack = [BlizzState(position: start, time: startTime)];

    const crapLoopBreak = 1000;

    while (stack.isNotEmpty) {
      if (stack.length % 100000 == 0) {
        devtools.log(stack.length.toString());
      }

      final state = stack.removeLast();

      if (state.time > crapLoopBreak) continue;

      // Are we in a blizzard?
      if (!isFree(state.position, state.time)) continue;

      // Are we at the goal?
      if (state.position == goal) {
        bestTime ??= state.time;
        if (state.time <= bestTime) {
          bestTime = state.time;
          devtools.log('New best time - $bestTime');
        }
        continue;
      }

      // Can we still beat the best time?
      final int bestTimeFromHere;
      if (goal.y > start.y) {
        bestTimeFromHere = state.time +
            (goal.x - state.position.x) +
            (goal.y - state.position.y);
      } else {
        bestTimeFromHere = state.time +
            (state.position.x - goal.x) +
            (state.position.y - goal.y);
      }
      if (bestTime != null && bestTimeFromHere >= bestTime) {
        continue;
      }

      // Have we tried this route before?
      if (beenHere.contains(state)) {
        continue;
      } else {
        beenHere.add(state);
      }

      if (goal.y > start.y) {
        // Test the four directions - trying to get closer to goal first
        // Moving top left to bottom right -> (Down, Right), Wait, (Left, Up)
        // But reversed cos it's a stack
        if ((goal.x - state.position.x) > (goal.y - state.position.y)) {
          stack.add(BlizzState(
              position: state.position + Coord(-1, 0), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(0, -1), time: state.time + 1));
          stack.add(BlizzState(position: state.position, time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(0, 1), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(1, 0), time: state.time + 1));
        } else {
          stack.add(BlizzState(
              position: state.position + Coord(0, -1), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(-1, 0), time: state.time + 1));
          stack.add(BlizzState(position: state.position, time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(1, 0), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(0, 1), time: state.time + 1));
        }
      } else {
        // Test the four directions - trying to get closer to goal first
        // Moving bottom right to top left -> (Up, Left), Wait, (Right, Down)
        // But reversed cos it's a stack
        if ((state.position.x - goal.x) > (state.position.y - goal.y)) {
          stack.add(BlizzState(
              position: state.position + Coord(0, 1), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(1, 0), time: state.time + 1));
          stack.add(BlizzState(position: state.position, time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(0, -1), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(-1, 0), time: state.time + 1));
        } else {
          stack.add(BlizzState(
              position: state.position + Coord(0, 1), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(1, 0), time: state.time + 1));
          stack.add(BlizzState(position: state.position, time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(-1, 0), time: state.time + 1));
          stack.add(BlizzState(
              position: state.position + Coord(0, -1), time: state.time + 1));
        }
      }
    }
    return bestTime;
  }
}

class Day24P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 24 Part 1');

    final blizzard = Blizzard();
    await blizzard.getMap(lines());

    final trip1 = blizzard.getPath(blizzard.entrance, blizzard.exit, 0);
    say('The answer is $trip1');
  }
}

class Day24P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 24 Part 2');

    final blizzard = Blizzard();
    await blizzard.getMap(lines());

    final trip1 = blizzard.getPath(blizzard.entrance, blizzard.exit, 0);
    say('Time for trip 1 $trip1');

    final trip2 = blizzard.getPath(blizzard.exit, blizzard.entrance, trip1!);
    say('Time for trip 1 ${trip2! - trip1}');

    final trip3 = blizzard.getPath(blizzard.entrance, blizzard.exit, trip2);
    say('Time for trip 1 ${trip3! - trip2}');

    say('The answer is $trip3');
  }
}
