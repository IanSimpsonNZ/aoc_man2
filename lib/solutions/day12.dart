import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
//import "package:async/async.dart" show StreamQueue;

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/helpers/coord.dart';

//import 'dart:developer' as devtools show log;

class ElevationMap {
  List<List<int>> map = [];
  Coord? start;
  Coord? finish;

  int get xLen {
    if (map.isNotEmpty) {
      return map[0].length;
    } else {
      return 0;
    }
  }

  int get yLen => map.length;

  ElevationMap clone(ElevationMap oldMap) {
    var newMap = ElevationMap();
    for (final row in oldMap.map) {
      newMap.map.add([...row]);
    }
    newMap.start = start;
    newMap.finish = finish;
    return newMap;
  }

  int getHeight(Coord p) => map[p.y][p.x];
  void setHeight(Coord p, int v) {
    map[p.y][p.x] = v;
  }

  Future<void> getMap(Stream<String> lines) async {
    final codeS = ascii.encode('S')[0];
    final codeE = ascii.encode('E')[0];
    final codea = ascii.encode('a')[0];
    final codez = ascii.encode('z')[0];

    int? lineLen;
    for (final (y, line) in (await lines.toList()).indexed) {
      lineLen ??= line.length;
      assert(lineLen == line.length);

      map.add(ascii.encode(line));
      for (final (x, elevation) in map.last.indexed) {
        if (elevation == codeS) {
          start = Coord(x, y);
          map.last[x] = codea;
        } else if (elevation == codeE) {
          finish = Coord(x, y);
          map.last[x] = codez;
        }
      }
    }

    assert(start != null);
    assert(finish != null);
  }

  bool isInBounds(Coord coord) =>
      (coord.x >= 0 && coord.y >= 0 && coord.x < xLen && coord.y < yLen);
}

class Day12P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 12 Part 1');

    var map = ElevationMap();
    await map.getMap(lines());

    const footprint = 32;
    final dUp = Coord(0, 1);
    final dDown = Coord(0, -1);
    final dRight = Coord(1, 0);
    final dLeft = Coord(-1, 0);

    int step = 0;
    Set<Coord> nextSteps = {map.finish!};
    bool found = false;
    do {
      say("Step $step: testing ${nextSteps.length} positions");
      final theseSteps = nextSteps;
      nextSteps = {};
      step++;
      for (final thisStep in theseSteps) {
        final up = thisStep + dUp;
        final down = thisStep + dDown;
        final right = thisStep + dRight;
        final left = thisStep + dLeft;

        for (final testPos in [up, down, left, right]) {
          if (testPos == map.start) {
            found = true;
            break;
          }
          if (map.isInBounds(testPos) &&
              (map.getHeight(testPos) >= map.getHeight(thisStep) - 1)) {
            nextSteps.add(testPos.clone());
          }
        }

        map.setHeight(thisStep, footprint);

        if (found) break;
      }
    } while (!found && nextSteps.isNotEmpty);

    if (found) {
      say('The answer is $step steps');
    } else {
      say('Could not get there?');
    }
  }
}

class Day12P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 12 Part 2');

    var map = ElevationMap();
    await map.getMap(lines());

    const footprint = 32;
    final dUp = Coord(0, 1);
    final dDown = Coord(0, -1);
    final dRight = Coord(1, 0);
    final dLeft = Coord(-1, 0);
    final codea = ascii.encode('a')[0];

    int step = 0;
    Set<Coord> nextSteps = {map.finish!};
    bool found = false;
    do {
      // say("Step $step: testing ${nextSteps.length} positions");
      final theseSteps = nextSteps;
      nextSteps = {};
      step++;
      for (final thisStep in theseSteps) {
        final up = thisStep + dUp;
        final down = thisStep + dDown;
        final right = thisStep + dRight;
        final left = thisStep + dLeft;

        for (final testPos in [up, down, left, right]) {
          if (!map.isInBounds(testPos)) continue;
          if (map.getHeight(testPos) >= map.getHeight(thisStep) - 1) {
            if (map.getHeight(testPos) == codea) {
              say('Found low point in row ${testPos.y}, col ${testPos.x}');
              found = true;
              break;
            }
            nextSteps.add(testPos.clone());
          }
        }

        map.setHeight(thisStep, footprint);

        if (found) break;
      }
    } while (!found && nextSteps.isNotEmpty);

    if (found) {
      say('The answer is $step steps');
    } else {
      say('Could not get there?');
    }
  }
}
