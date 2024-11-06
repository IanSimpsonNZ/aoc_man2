// import 'dart:convert';
// import 'dart:io';
import 'dart:math' show min, max;

// import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/helpers/coord.dart';

// import 'dart:developer' as devtools show log;

class Elf {
  Coord position;
  Coord? proposedPosition;

  Elf(this.position);

  @override
  String toString() => position.toString();
}

const elfChar = '#';

class Field {
  List<Elf> elves = [];
  int preferredDirection = 0;
  bool anElfMoved = true;

  final List<List<Coord>> checkFree = [
    [Coord(-1, -1), Coord(0, -1), Coord(1, -1)],
    [Coord(-1, 1), Coord(0, 1), Coord(1, 1)],
    [Coord(-1, -1), Coord(-1, 0), Coord(-1, 1)],
    [Coord(1, -1), Coord(1, 0), Coord(1, 1)]
  ];

  int directionIdx(int d) => d % 4;

  int minX = 0;
  int minY = 0;
  int maxX = 0;
  int maxY = 0;

  Future<void> getElves(Stream<String> lines) async {
    int y = 0;
    await for (final line in lines) {
      if (line.isEmpty) break;
      for (int x = 0; x < line.length; x++) {
        if (line[x] == elfChar) {
          elves.add(Elf(Coord(x, y)));
        }
      }
      y++;
    }
  }

  void getminMax() {
    minX = elves.first.position.x;
    minY = elves.first.position.y;
    maxX = elves.first.position.x;
    maxY = elves.first.position.y;
    for (final elf in elves) {
      minX = min(minX, elf.position.x);
      maxX = max(maxX, elf.position.x);
      minY = min(minY, elf.position.y);
      maxY = max(maxY, elf.position.y);
    }
  }

  void print(void Function(String) say) {
    getminMax();
    say('minX $minX');
    say('maxX $maxX');
    say('minY $minY');
    say('maxY $maxY');
    List<String> graphic = [];
    for (int y = minY; y <= maxY; y++) {
      graphic.add('.' * (maxX - minX + 1));
    }

    for (final elf in elves) {
      final xPos = elf.position.x - minX;
      final yPos = elf.position.y - minY;
      graphic[yPos] = graphic[yPos].replaceRange(xPos, xPos + 1, elfChar);
    }

    for (final line in graphic) {
      say(line);
    }
  }

  bool _isClear(Coord elfPos, int direction) {
    for (final elf in elves) {
      for (final testCoord in checkFree[direction]) {
        if (elf.position == elfPos + testCoord) {
          return false;
        }
      }
    }
    return true;
  }

  void getPrposedMoves() {
    for (final elf in elves) {
      elf.proposedPosition = null;
      Coord? firstClearMove;
      bool allClear = true;
      for (int dir = 0; dir < 4; dir++) {
        final realDir = directionIdx(dir + preferredDirection);
        if (_isClear(elf.position, realDir)) {
          firstClearMove ??= elf.position + checkFree[realDir][1];
        } else {
          allClear = false;
        }
      }
      if (!allClear) {
        elf.proposedPosition = firstClearMove;
      }
    }
  }

  void makeMove() {
    Map<Coord, int> proposedMoves = {};
    for (final elf in elves) {
      if (elf.proposedPosition != null) {
        if (proposedMoves.keys.contains(elf.proposedPosition)) {
          proposedMoves[elf.proposedPosition!] =
              proposedMoves[elf.proposedPosition!]! + 1;
        } else {
          proposedMoves[elf.proposedPosition!] = 1;
        }
      }
    }

    anElfMoved = false;
    for (final elf in elves) {
      if (elf.proposedPosition != null &&
          proposedMoves[elf.proposedPosition] == 1) {
        elf.position = elf.proposedPosition!;
        anElfMoved = true;
      }
    }
  }

  int calcEmpty() => (maxX - minX + 1) * (maxY - minY + 1) - elves.length;
}

const numRounds = 10;

class Day23P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 23 Part 1');

    final field = Field();
    await field.getElves(lines());

    for (int i = 0; i < numRounds; i++) {
      field.getPrposedMoves();
      field.makeMove();

      // field.print(say);
      // say('------------------------------');

      field.preferredDirection++;
    }

    field.getminMax();
    say('X size is ${field.maxX} - ${field.minX} + 1 = ${field.maxX - field.minX + 1}');
    say('Y size is ${field.maxY} - ${field.minY} + 1 = ${field.maxY - field.minY + 1}');
    say('There are ${field.elves.length} elves');

    say('The answer is ${field.calcEmpty()}');
  }
}

class Day23P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 23 Part 2');

    final field = Field();
    await field.getElves(lines());

    int roundNum = 0;
    while (field.anElfMoved) {
      field.getPrposedMoves();
      field.makeMove();
      field.preferredDirection++;
      roundNum++;
    }

    say('The answer is $roundNum');
  }
}
