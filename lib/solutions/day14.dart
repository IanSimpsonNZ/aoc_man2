// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import "package:async/async.dart" show StreamQueue;

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

int min(a, b) => (a < b) ? a : b;
int max(a, b) => (a > b) ? a : b;

class BlockedMap {
  Set<Coord> blocked = {};
  int minY = 0;
  int maxY = 0;
  int minX = 1000000;
  int maxX = 0;
  int floor = 0;
  bool useFloor = false;

  bool isBlocked(Coord p) =>
      ((useFloor && p.y == floor) || blocked.contains(p));

  void print(void Function(String) say) {
    for (int y = 0; y <= maxY + 1; y++) {
      String line = '';
      for (int x = minX - 1; x <= maxX + 1; x++) {
        if (blocked.contains(Coord(x, y))) {
          line = '$line#';
        } else {
          line = '$line.';
        }
      }
      say(line);
    }
  }
}

Future<BlockedMap> getBlocked(Stream<String> lines) async {
  var result = BlockedMap();

  await for (final line in lines) {
    List<String> points = line.split('->').map((s) => s.trim()).toList();
    for (int i = 0; i < points.length - 1; i++) {
      List<String> nums = points[i].split(',');
      final p1 = Coord(int.parse(nums[0]), int.parse(nums[1]));
      nums = points[i + 1].split(',');
      final p2 = Coord(int.parse(nums[0]), int.parse(nums[1]));
      result.maxY = max(result.maxY, p1.y);
      result.maxY = max(result.maxY, p2.y);
      result.maxX = max(result.maxX, p1.x);
      result.maxX = max(result.maxX, p2.x);
      result.minX = min(result.minX, p1.x);
      result.minX = min(result.minX, p2.x);

      final dx = p1.x - p2.x;
      final dy = p1.y - p2.y;

      if (dx == 0) {
        int startY = 0;
        int endY = 0;
        if (p1.y < p2.y) {
          startY = p1.y;
          endY = p2.y;
        } else {
          startY = p2.y;
          endY = p1.y;
        }
        for (int y = startY; y <= endY; y++) {
          result.blocked.add(Coord(p1.x, y));
        }
      } else if (dy == 0) {
        int startX = 0;
        int endX = 0;
        if (p1.x < p2.x) {
          startX = p1.x;
          endX = p2.x;
        } else {
          startX = p2.x;
          endX = p1.x;
        }
        for (int x = startX; x <= endX; x++) {
          result.blocked.add(Coord(x, p1.y));
        }
      } else {
        devtools.log('Diagonal line? ${p1.toString()} -> ${p2.toString()}');
      }
    }
  }

  result.floor = result.maxY + 2;

  return result;
}

int simulateSand(
    {required BlockedMap blockedMap,
    required bool Function({required Coord p, required BlockedMap map})
        endCondition}) {
  bool fallenThrough = false;
  int numUnits = 0;

  while (!fallenThrough) {
    var sandPos = Coord(500, 0);
    bool moving = true;
    numUnits++;

    while (moving) {
      final down = sandPos + Coord(0, 1);
      final downLeft = sandPos + Coord(-1, 1);
      final downRight = sandPos + Coord(1, 1);
      if (!blockedMap.isBlocked(down)) {
        sandPos = down;
      } else if (!blockedMap.isBlocked(downLeft)) {
        sandPos = downLeft;
      } else if (!blockedMap.isBlocked(downRight)) {
        sandPos = downRight;
      } else {
        blockedMap.blocked.add(sandPos);
        moving = false;
      }
      if (endCondition(p: sandPos, map: blockedMap)) {
        fallenThrough = true;
        moving = false;
      }
    }
  }

  return numUnits;
}

class Day14P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 14 Part 1');

    bool endCondition({required Coord p, required BlockedMap map}) =>
        p.y > map.maxY;

    var blockedMap = await getBlocked(lines());
    blockedMap.print(say);

    final numUnits =
        simulateSand(blockedMap: blockedMap, endCondition: endCondition);
    say('The answer is ${numUnits - 1}');
  }
}

class Day14P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 14 Part 2');

    bool endCondition({required Coord p, required BlockedMap map}) =>
        p == Coord(500, 0);

    var blockedMap = await getBlocked(lines());
    blockedMap.useFloor = true;
    blockedMap.print(say);

    final numUnits =
        simulateSand(blockedMap: blockedMap, endCondition: endCondition);
    say('The answer is $numUnits');
  }
}
