// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' show min, max;
// import "package:async/async.dart" show StreamQueue;

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/helpers/coord.dart';

// import 'dart:developer' as devtools show log;

// The "radius" is abs(x1 - x2) + abs(y1 - y2)
// Sensor can see rows Sy - radius to Sy + radius
// on row y, x range is  Sx +/- (radius - abs(Sy - y))
//
// So is S = (8,7) with B = (2,10)
// edge at row 10 = 8 +/- (9 - 3) = 8 +/- 6 = 2 to 14.

class Day15P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 15 Part 1');

    const targetLine = 2000000;
    say('Target row is $targetLine');

    Set<int> impactedRegion = {};
    Set<int> beaconsOnTarget = {};
    await for (final line in lines()) {
      final parts = line.split('=');
      final S = Coord(
        int.parse(parts[1].split(',')[0]),
        int.parse(parts[2].split(':')[0]),
      );
      final B = Coord(
        int.parse(parts[3].split(',')[0]),
        int.parse(parts[4].trim()),
      );

      if (B.y == targetLine) {
        beaconsOnTarget.add(B.x);
      }

      final radius = (S.x - B.x).abs() + (S.y - B.y).abs();
      if ((S.y - B.y).abs() <= radius) {
        final radiusAtLine = radius - (S.y - targetLine).abs();
        final minX = S.x - radiusAtLine;
        final maxX = S.x + radiusAtLine;
        for (int x = minX; x <= maxX; x++) {
          impactedRegion.add(x);
        }
      }
    }

    impactedRegion.removeWhere((x) => beaconsOnTarget.contains(x));

    say('The answer is ${impactedRegion.length}');
  }
}

class Signal {
  final Coord position;
  final int radius;

  int get x => position.x;
  int get y => position.y;
  int get xMin => position.x - radius;
  int get xMax => position.x + radius;
  int get yMin => position.y - radius;
  int get yMax => position.y + radius;

  const Signal({required this.position, required this.radius});

  bool isVisible(Coord p) {
    final dist = (position.x - p.x).abs() + (position.y - p.y).abs();
    return dist <= radius;
  }

  String print() => 'S:${position.print()} rad: $radius';
}

class Day15P2 extends Solution {
// From part 1 ...
// on row y, x range is  Sx +/- (radius - abs(Sy - y))
// So x = Sx +/- (rad - abs(Sy - y))
// x = Sx +/- (rad - (Sy - y)) and x = Sx +/- (rad - (y - Sy))
// x = Sx +/- (rad - Sy + y) and x = Sx +/- (rad + Sy - y)
//
// So the four sides are
// Test with example S = (8,7), rad = 9                                                   x = 12        x = 4
// x = Sx + rad - Sy + y => y = x - (Sx + rad - Sy)   y = x - (8 + 9 - 7)   y = x - 10    y = 2         y = -6 (oob)  - Bottom right
// x = Sx - rad + Sy - y => y = -x + (Sx - rad + Sy)  y = -x + (8 - 9 + 7)  y = -x + 6    y = -6 (oob)  y = 2         - Bottom left
// x = Sx + rad + Sy - y => y = -x + (Sx + rad + Sy)  y = -x + (8 + 9 + 7)  y = -x + 24   y = 12        y = 20 (oob)  - Top right
// x = Sx - rad - Sy + y => y = x - (Sx - rad - Sy)   y = x - (8 - 9 - 7)   y = x + 8     y = 20 (oob)  y = 12        - Top left
//
// Want 1 square gap between :
// top right & bottom left
// top left & bottom right
//
// Ytr - Ybl = -2 = -x + (Sxtr + radtr + Sytr) - (-x + (Sxbl - radbl + Sybl))
//           = -2 = -x + Sxtr + radtr + Sytr + x - Sxbl + radbl - Sybl
//           = -2 = Sxtr - Sxbl + Sytr - Sybl + radtr + redbl
//           = -2 = Sx1 - Sx2 + Sy1 - Sy2 + rad1 + rad2
//
// Ytl - Ybr = -2 = x - (Sxtl - radtl - Sytl) - (x - (Sxbr + radbr - Sybr))
//             -2 = x - (Sxtl - radtl - Sytl) - x + (Sxbr + radbr - Sybr)
//             -2 = x - Sxtl + radtl + Sytl - x + Sxbr + radbr - Sybr
//             -2 = Sxbr - Sxtl + Sytl - Sybr + radtl + radbr
//             -2 = Sx2 - Sx1 + Sy1 - Sy2 + rad1 + rad2

  @override
  Future<void> specificSolution() async {
    say('Day 15 Part 2');

    const maxScan = 4000000;

    say('Search space is $maxScan');

    List<Signal> signals = [];

    await for (final line in lines()) {
      final parts = line.split('=');
      final S = Coord(
        int.parse(parts[1].split(',')[0]),
        int.parse(parts[2].split(':')[0]),
      );
      final B = Coord(
        int.parse(parts[3].split(',')[0]),
        int.parse(parts[4].trim()),
      );

      final radius = (S.x - B.x).abs() + (S.y - B.y).abs();

      signals.add(Signal(position: S, radius: radius));
    }

    for (final signal in signals) {
      say(signal.print());
    }

    Signal? tr;
    Signal? tl;
    for (int i = 0; i < signals.length; i++) {
      for (int j = 0; j < signals.length; j++) {
        if (i == j) continue;
        final sig1 = signals[i];
        final sig2 = signals[j];
        if (sig1.x - sig2.x + sig1.y - sig2.y + sig1.radius + sig2.radius ==
            -2) {
          say('${sig1.position.print()} and ${sig2.position.print()} top right to bottom left');
          if (tr == null) {
            tr = sig1;
          } else {
            say('Oops - found multiple top right / bottom left combos');
          }
        }
        if (sig2.x - sig1.x + sig1.y - sig2.y + sig1.radius + sig2.radius ==
            -2) {
          say('${sig1.position.print()} and ${sig2.position.print()} top left to bottom right');
          if (tl == null) {
            tl = sig1;
          } else {
            say('Oops - found multiple top left / bottom right combos');
          }
        }
      }
    }

    if (tr == null || tl == null) {
      say("Didn't find any candidates");
    } else {
      // Need to find x where top right = top left
      // -x + (Sxtr + radtr + Sytr) = x - (Sxtl - radtl - Sytl)
      // 2x = (Sxtr + radtr + Sytr) + (Sxtl - radtl - Sytl)
      // x = (Sxtr + radtr + Sytr + Sxtl - radtl - Sytl) / 2
      final x = (tr.x + tr.radius + tr.y + tl.x - tl.radius - tl.y) ~/ 2;
      // y = tr for this x + 1
      //   = -x + (Sx + rad + Sy) + 1
      final y = -x + tr.x + tr.radius + tr.y + 1;
      say('Free position is ($x, $y)');
      say('Answer is ${x * 4000000 + y}');
    }
  }
}
