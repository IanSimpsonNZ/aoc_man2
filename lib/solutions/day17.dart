// import 'dart:convert';
// import 'dart:io';
import 'dart:math' show min, max;
// import "package:async/async.dart" show StreamQueue;

import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
// import 'package:aoc_manager/solutions/helpers/coord.dart';

// import 'dart:developer' as devtools show log;

void testLeft(Shape s, void Function(String) say) {
  final moved = s.left();
  s.print(say);
  if (!moved) say('Donk');
  say('');
}

void testRight(Shape s, void Function(String) say) {
  final moved = s.right();
  s.print(say);
  if (!moved) say('Donk');
  say('');
}

const maxShapeHeight = 4;
const columnWidth = 7; // bits
const leftCol = 64;
const startBit =
    16; // 7 bit int, two spaces from left (i.e start at 5th bit from right = 2^4)

String bitPrint(int line, String occupiedChar) {
  String lineStr = '';
  int bitMask = leftCol;
  for (int bit = columnWidth - 1; bit >= 0; bit--) {
    if (line & bitMask == 0) {
      lineStr = '$lineStr.';
    } else {
      lineStr = '$lineStr$occupiedChar';
    }
    bitMask ~/= 2;
  }
  return lineStr;
}

String bitPrintDual(
    int line1, String occupiedChar1, int line2, String occupiedChar2) {
  String lineStr = '';
  int bitMask = leftCol;
  for (int bit = columnWidth - 1; bit >= 0; bit--) {
    if ((line1 | line2) & bitMask == 0) {
      lineStr = '$lineStr.';
    } else if (line1 & bitMask != 0) {
      lineStr = '$lineStr$occupiedChar1';
    } else {
      lineStr = '$lineStr$occupiedChar2';
    }
    bitMask ~/= 2;
  }
  return lineStr;
}

class Shape {
  Uint8List data = Uint8List(maxShapeHeight);
  int leftBit = 0;
  int rightBit = 256;

  Shape(this.data, this.leftBit, this.rightBit);

  Shape.fromImage(List<String> image) {
    if (image.isEmpty || image.length > maxShapeHeight) return;
    int shapeLine = 0;
    for (final line in image.reversed) {
      int bitMask = startBit;
      for (final char in line.split('')) {
        if (char == '#') {
          data[shapeLine] |= bitMask;
          leftBit = max(leftBit, bitMask);
          rightBit = min(rightBit, bitMask);
        }
        bitMask ~/= 2;
        if (bitMask == 0) break;
      }
      shapeLine++;
    }
  }

  Shape.fromShape(Shape other) {
    data = Uint8List.fromList(other.data);
    leftBit = other.leftBit;
    rightBit = other.rightBit;
  }

  bool left() {
    if (leftBit == leftCol) return false;
    for (final (lineNum, line) in data.indexed) {
      data[lineNum] = line << 1;
    }
    leftBit *= 2;
    rightBit *= 2;
    return true;
  }

  bool right() {
    if (rightBit == 1) return false;
    for (final (lineNum, line) in data.indexed) {
      data[lineNum] = line >> 1;
    }
    leftBit ~/= 2;
    rightBit ~/= 2;
    return true;
  }

  bool moveJet(MyIterator<String> jet) {
    final thisJet = jet.next();
    assert(thisJet == '<' || thisJet == '>');
    if (thisJet == '<') {
      final tryMove = left();
      if (tryMove) {
        // devtools.log('Moved left');
      } else {
        // devtools.log('Hit wall left');
      }
      return tryMove;
    }
    final tryMove = right();
    if (tryMove) {
      // devtools.log('Moved right');
    } else {
      // devtools.log('Hit wall right');
    }
    return tryMove;
  }

  void print(void Function(String) say) {
    for (final line in data.reversed) {
      say(bitPrint(line, '#'));
    }
    say('$leftBit -> $rightBit');
  }
}

const floor = 0;
const dropHeight = 3;

class Tetris {
  List<int> stack = [];
  int top = floor;
  Map<int, List<int>> memory = {};
  int counter = 0;

  int operator [](int idx) {
    if (idx > stack.length - 1) {
      for (int i = stack.length; i <= idx; i++) {
        stack.add(0);
      }
      return 0;
    }
    return stack[idx];
  }

  void operator []=(int idx, int value) {
    final _ = this[idx];
    stack[idx] = value;
  }

  bool hasOverlap(Shape shape, int bottom) {
    int overlap = 0;
    for (int i = 0; i < maxShapeHeight; i++) {
      overlap += this[bottom + i] & shape.data.elementAt(i);
    }
    return overlap != 0;
  }

  Shape horizontalMove(Shape shape, int bottom, MyIterator<String> jet) {
    if (hasOverlap(shape, bottom)) {
      // devtools.log('Shape already blocked');
    }
    var testShape = Shape.fromShape(shape);
    final tryMove = testShape.moveJet(jet);
    if (tryMove) {
      // devtools.log('Moved Ok');
    } else {
      // devtools.log('Move blocked');
    }
    final overlap = hasOverlap(testShape, bottom);
    if (overlap) {
      // devtools.log('Has overlap');
    } else {
      // devtools.log('No overlap');
    }
    if (tryMove && !overlap) {
      // devtools.log('Horizontal move ok');
      return testShape;
    }
    // devtools.log('Horiaontal move blocked');
    return shape;
  }

  // Need to be able to print each step
  void drop(MyIterator<Shape> shapeIter, MyIterator<String> jet,
      void Function(String) say) {
    counter++;
    Shape shape = shapeIter.next()!;
    if (stack.isNotEmpty) {
      final stateHash =
          ((shapeIter.cursor * 10000) + jet.cursor) * 1000 + stack[top];
      if (memory.keys.contains(stateHash)) {
        memory[stateHash]!.add(counter);
        say('Repeat hash: $stateHash at ${memory[stateHash]}');
      } else {
        memory[stateHash] = [counter];
      }
    }
    int bottomOfShape = top + dropHeight;
    bool falling = true;
    while (falling) {
      // printWithShape(shape, bottomOfShape, say);
      shape = horizontalMove(shape, bottomOfShape, jet);
      // printWithShape(shape, bottomOfShape, say);

      falling = bottomOfShape > floor && !hasOverlap(shape, bottomOfShape - 1);
      if (falling) {
        bottomOfShape--;
      }
    }

    // Write the shape onto the stack
    for (int i = 0; i < maxShapeHeight; i++) {
      final shapeLine = shape.data.elementAt(i);
      if (shapeLine != 0) {
        // Shape may have "fallen down the side"
        // so need the max
        top = max(top, bottomOfShape + i + 1);
      }
      this[bottomOfShape + i] = this[bottomOfShape + i] | shapeLine;
    }
  }

  void print(void Function(String) say) {
    for (final line in stack.reversed) {
      say('|${bitPrint(line, '#')}|');
    }
    say('---------');
  }

  void printWithShape(
      Shape shape, int bottomOfShape, void Function(String) say) {
    String lineStr = '';
    for (int lineNum = stack.length - 1; lineNum >= 0; lineNum--) {
      if (lineNum >= bottomOfShape &&
          lineNum < bottomOfShape + maxShapeHeight) {
        final shapeLineNum = lineNum - bottomOfShape;
        if (stack[lineNum] & shape.data.elementAt(shapeLineNum) != 0) {
          lineStr = bitPrint(
              stack[lineNum] | shape.data.elementAt(shapeLineNum), 'X');
        } else {
          lineStr = bitPrintDual(
              shape.data.elementAt(shapeLineNum), '@', stack[lineNum], '#');
        }
      } else {
        lineStr = bitPrint(stack[lineNum], "#");
      }
      say('|$lineStr|');
    }
    say('---------');
    say('Top is $top');
  }
}

class MyIterator<T> {
  List<T> data;
  int cursor = 0;

  MyIterator(this.data);

  void reset() {
    cursor = 0;
  }

  void rewind(int i) {
    cursor = (cursor - i) % data.length;
  }

  T? next() {
    if (data.isEmpty) return null;
    final returnVal = data[cursor];
    cursor = (cursor + 1) % data.length;
    return returnVal;
  }
}

class Day17P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 17 Part 1');

    final hLine = Shape.fromImage([
      '####',
    ]);

    final cross = Shape.fromImage([
      '.#.',
      '###',
      '.#.',
    ]);

    final l = Shape.fromImage([
      '..#',
      '..#',
      '###',
    ]);

    final vLine = Shape.fromImage([
      '#',
      '#',
      '#',
      '#',
    ]);

    final square = Shape.fromImage([
      '##',
      '##',
    ]);

    final shapeList = [hLine, cross, l, vLine, square];
    final shapeIter = MyIterator(shapeList);
    final moveList = (await lines().first).split('');
    say('Jet is ${moveList.length} jets long');
    final moveIter = MyIterator(moveList);

    // for (int i = 0; i < 5; i++) {
    //   shapeIter.next()!.print(say);
    // }

    const numShapes = 2022;
    final game = Tetris();
    for (int i = 0; i < numShapes; i++) {
      game.drop(shapeIter, moveIter, say);
      // game.print(say);
      // say('');
      // say('----------------------------');
      // say('');
      // devtools.log('--------- Next shape');
    }

    say('The top is ${game.top}');
  }
}

class Day17P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 17 Part 2');

    final hLine = Shape.fromImage([
      '####',
    ]);

    final cross = Shape.fromImage([
      '.#.',
      '###',
      '.#.',
    ]);

    final l = Shape.fromImage([
      '..#',
      '..#',
      '###',
    ]);

    final vLine = Shape.fromImage([
      '#',
      '#',
      '#',
      '#',
    ]);

    final square = Shape.fromImage([
      '##',
      '##',
    ]);

    final shapeList = [hLine, cross, l, vLine, square];
    final shapeIter = MyIterator(shapeList);
    final moveList = (await lines().first).split('');
    say('Jet is ${moveList.length} jets long');
    final moveIter = MyIterator(moveList);

    say('There are ${shapeList.length} shapes');
    say('There are ${moveList.length} jets');
    final mult = shapeList.length * moveList.length;

    say('Multiple is $mult');

    // 27 + 35
    // 1,000,000,000,000 / 35 = 28,571,428,571.4
    // 28,571,428,571 * 35 = 999,999,999,985
    // 28,571,428,570 * 35 = 999,999,999,950
    //
    // So want height at 27 => 47
    // height change from 27 to 63 (check change from 63 to 98, 98 to 133) => 102 - 47 = 55; 155 - 102 = 53; 208 - 155 = 53
    // height change from 63 to (1000 - 27 - 950 + 63) = 86 => 132 - 102 = 30
    // Answer = 102 + 30 + 53 * 28,571,428,569 = 1,514,285,714,289
    //                                           1,514,285,714,288

    // Real answer?
    // 1,000,000,000,000 ~/ 1715 = 583,090,379
    // 1715 * 583,090,379 = 999,999,999,985 ! - need an extra 15!
    // 583,090,378
    // final gap = 1715 - 147  + 15 = 1583
    //
    // Height at 147 = 238
    // Gap = 2677 per 1715
    // final gap = height at (147 + 1715) to that + 1583
    //                       = 1862 to 3445 => 5386 - 2915 = 2471

    // Answer 7 = 238 + 2677 * 583,090,378 + 2471 = 1,560,932,944,615

    const numShapes = 3445;
    final game = Tetris();
    for (int i = 0; i < numShapes; i++) {
      game.drop(shapeIter, moveIter, say);
    }

    say('The top is ${game.top}');
  }
}
