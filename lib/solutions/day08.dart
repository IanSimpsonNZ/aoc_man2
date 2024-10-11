import 'dart:convert';

import 'package:aoc_manager/solutions/generic_solution.dart';

// import 'dart:developer' as devtools show log;

class Forrest {
  List<List<int>> forrest = [];
  List<List<bool>> visible = [];

  Future<void> loadForrest(Stream<String> lines) async {
    int? lineLength;
    final code0 = ascii.encode('0')[0];

    forrest.clear();
    await for (final line in lines) {
      if (line.isEmpty) break;

      lineLength ??= line.length;
      assert(lineLength == line.length);

      forrest.add(
          ascii.encode(line).map((asciiCode) => asciiCode - code0).toList());
    }
  }

  void print(void Function(String) say) {
    for (final row in forrest) {
      say(row.fold<String>('', (str, newNum) => '$str$newNum'));
    }
  }

  void calcVisible() {
    assert(forrest.isNotEmpty);

    visible.clear();
    List<int> maxHeights = [];

    for (final row in forrest) {
      // If maxHeights is empty we are on the first row
      // so set up maxHeights and set all trees to visble
      if (maxHeights.isEmpty) {
        maxHeights = [...forrest.first];
        visible.add(List.filled(row.length, true));
        continue;
      }

      int rowMax = 0;
      List<bool> visibleRow = List<bool>.filled(row.length, true);
      for (final (treeNum, tree) in row.indexed) {
        // first tree in row is always visible
        // and leave visiblity as default = true
        if (treeNum == 0) {
          rowMax = row.first;
          continue;
        }

        if (tree <= rowMax) {
          visibleRow[treeNum] = false;
        } else {
          // tree is default set to visible
          rowMax = tree;
        }

        // Trees are visible by default
        // The above row scan from left will have marked some as not visible
        // Check they remain invisible from top
        if (tree > maxHeights[treeNum]) {
          maxHeights[treeNum] = tree;
          visibleRow[treeNum] = true;
        }
      }

      // Now scan from right to left
      rowMax = row.last;
      visibleRow.last = true;
      for (int treeNum = row.length - 2; treeNum >= 0; treeNum--) {
        final tree = row[treeNum];
        if (tree > rowMax) {
          rowMax = tree;
          visibleRow[treeNum] = true;
        }
      }

      visible.add(visibleRow);
    }

    // Slightly wasteful to calc last row when it is always visible
    // but never mind
    visible.last = List<bool>.filled(visible.last.length, true);
    maxHeights = [...forrest.last];
    for (int rowNum = forrest.length - 2; rowNum >= 0; rowNum--) {
      final row = forrest[rowNum];
      for (final (treeNum, tree) in row.indexed) {
        if (tree > maxHeights[treeNum]) {
          maxHeights[treeNum] = tree;
          visible[rowNum][treeNum] = true;
        }
      }
    }
  }

  int countVisible() => visible.fold<int>(
        0,
        (acc, thisRow) =>
            acc +
            thisRow.fold<int>(
              0,
              (rowAcc, treeVis) => rowAcc + (treeVis ? 1 : 0),
            ),
      );

  int _getDistance(
      {required int treeRow,
      required treeColumn,
      required int deltaRow,
      required int deltaCol}) {
    int distance = 0;

    if (deltaRow == -1 && treeRow == 0) return 0;
    if (deltaRow == 1 && treeRow == forrest.length - 1) return 0;
    if (deltaCol == -1 && treeColumn == 0) return 0;
    if (deltaCol == 1 && treeColumn == forrest[0].length - 1) return 0;

    // devtools.log('Actually trying row: $treeRow, col: $treeColumn');

    final treeHeight = forrest[treeRow][treeColumn];
    // devtools.log('treeHeight is $treeHeight');
    int row = treeRow;
    int col = treeColumn;
    do {
      distance++;
      row += deltaRow;
      col += deltaCol;
      if (forrest[row][col] >= treeHeight) break;
    } while (row > 0 &&
        row < forrest.length - 1 &&
        col > 0 &&
        col < forrest[0].length - 1);
    return distance;
  }

  int _scenicScore({required int row, required int col, required int tree}) {
    return _getDistance(
            treeRow: row, treeColumn: col, deltaRow: 0, deltaCol: 1) *
        _getDistance(treeRow: row, treeColumn: col, deltaRow: 0, deltaCol: -1) *
        _getDistance(treeRow: row, treeColumn: col, deltaRow: 1, deltaCol: 0) *
        _getDistance(treeRow: row, treeColumn: col, deltaRow: -1, deltaCol: 0);
  }

  int maxScenicScore() {
    int maxScore = 0;
    for (int row = 1; row < forrest.length - 1; row++) {
      for (int col = 1; col < forrest[row].length - 1; col++) {
        final score = _scenicScore(row: row, col: col, tree: forrest[row][col]);
        // devtools.log('Score for row: $row, col: $col is $score');
        if (score > maxScore) maxScore = score;
      }
    }
    return maxScore;
  }
}

class Day08P1 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 8 Part 1');

    final forrest = Forrest();
    await forrest.loadForrest(lines());
    forrest.print(say);
    forrest.calcVisible();

    say('Answer is ${forrest.countVisible()}');
  }
}

class Day08P2 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 8 Part 2');

    final forrest = Forrest();
    await forrest.loadForrest(lines());

    say('Answer is ${forrest.maxScenicScore()}');
  }
}
