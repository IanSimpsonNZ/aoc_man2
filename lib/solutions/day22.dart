// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' show max;

import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

const moveIcon = ['>', 'v', '<', '^'];

class PassMap {
  List<String> passMap = [];
  List<String> graphic = [];
  List<int> minX = [];
  List<int> minY = [];
  List<int> maxY = [];
  String instructions = '';
  Coord position = Coord(0, 0);

  final up = Coord(0, -1);
  final down = Coord(0, 1);
  final left = Coord(-1, 0);
  final right = Coord(1, 0);

  // Add 1 to turn right, -1 to turn left.
  int direction = 0;
  List<Coord> moveVec = [];

  PassMap() {
    moveVec = [right, down, left, up];
  }

  void turn(String turnDir) {
    direction += turnDir == 'R' ? 1 : -1;
    direction %= moveVec.length;
  }

  bool isValid(Coord coord) {
    if (coord.y < 0) return false;
    if (coord.y >= passMap.length) return false;
    if (coord.x < 0) return false;
    if (coord.x >= passMap[coord.y].length) return false;
    if (passMap[coord.y][coord.x] == ' ') return false;
    return true;
  }

  // Late hack - returns true is we cross to another face
  // Part 1 doesn't have faces, so always false
  bool checkBoundsPt1(Coord coord) {
    switch (direction) {
      case 0: // right
        if (coord.x >= passMap[coord.y].length) {
          coord.x = minX[coord.y];
        }
      case 1: // down
        if (coord.y > maxY[coord.x]) {
          coord.y = minY[coord.x];
        }
      case 2: // left
        if (coord.x < minX[coord.y]) {
          coord.x = passMap[coord.y].length - 1;
        }
      case 3: // up
        if (coord.y < minY[coord.x]) {
          coord.y = maxY[coord.x];
        }
      default:
        devtools.log('Invalid direction: $direction');
    }
    return false;
  }

  void move(int steps, bool Function(Coord) checkBounds) {
    for (int s = 0; s < steps; s++) {
      Coord nextPos = position.clone() + moveVec[direction];
      final oldDirection = direction;
      final movedFace = checkBounds(nextPos);
      final char = passMap[nextPos.y][nextPos.x];
      if (char == '#') {
        if (movedFace) {
          direction = oldDirection;
        }
        break;
      }
      position = nextPos;
      assert(graphic[position.y][position.x] != '#');
      graphic[position.y] = graphic[position.y]
          .replaceRange(position.x, position.x + 1, moveIcon[direction]);
    }
  }

  void followPath(bool Function(Coord) checkBounds) {
    assert(graphic[position.y][position.x] != '#');
    graphic[position.y] = graphic[position.y]
        .replaceRange(position.x, position.x + 1, moveIcon[direction]);
    int cursor = 0;
    String numStr = '';
    while (cursor < instructions.length) {
      final char = instructions[cursor];
      cursor++;

      if (char == 'L' || char == 'R') {
        if (numStr.isNotEmpty) {
          move(int.parse(numStr), checkBounds);
          numStr = '';
        }
        turn(char);
        continue;
      }

      numStr = '$numStr$char';
    }

    if (numStr.isNotEmpty) {
      move(int.parse(numStr), checkBounds);
    }
  }

  Future<void> loadMap(Stream<String> Function() lines) async {
    int maxLen = 0;
    var lineQueue = StreamQueue<String>(lines());
    while (await lineQueue.hasNext) {
      final line = await lineQueue.next;
      if (line.isEmpty) break;
      passMap.add(line);
      minX.add(line.indexOf(RegExp(r'[.#]')));
      if (line.length > maxLen) {
        maxLen = line.length;
      }
    }

    instructions = await lineQueue.next;
    lineQueue.cancel();

    for (int col = 0; col < maxLen; col++) {
      int thisMinY = passMap.length;
      for (int y = 0; y < passMap.length; y++) {
        if (col >= passMap[y].length) continue;
        final char = passMap[y][col];
        if (char != ' ') {
          thisMinY = y;
          break;
        }
      }
      assert(thisMinY != passMap.length);
      minY.add(thisMinY);

      int thisMaxY = -1;
      for (int y = passMap.length - 1; y >= 0; y--) {
        if (col >= passMap[y].length) continue;
        final char = passMap[y][col];
        if (char != ' ') {
          thisMaxY = y;
          break;
        }
      }
      assert(thisMaxY != -1);
      maxY.add(thisMaxY);
    }

    position = Coord(minX[0], 0);

    for (final line in passMap) {
      graphic.add(line);
    }
  }

  void print(void Function(String) say) {
    say(minY.toString());
    for (final (rowNum, line) in passMap.indexed) {
      say('$rowNum:${minX[rowNum]} $line ${line.length - 1}');
    }
    say(maxY.toString());
    say('');
    say(instructions);
  }
}

class Day22P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 22 Part 1');

    var myPassMap = PassMap();
    await myPassMap.loadMap(lines);
    myPassMap.print(say);
    say('Starting position is ${myPassMap.position.toString()}');
    say('Direction is ${myPassMap.direction}');
    myPassMap.followPath(myPassMap.checkBoundsPt1);

    say('Position is ${myPassMap.position.toString()}');
    say('Direction is ${myPassMap.direction}');

    final answer = 1000 * (myPassMap.position.y + 1) +
        4 * (myPassMap.position.x + 1) +
        myPassMap.direction;
    say('The answer is $answer');
  }
}

enum Face {
  top,
  front,
  left,
  right,
  bottom,
  back,
}

const int northFace = 0;
const int eastFace = 1;
const int southFace = 2;
const int westFace = 3;

const verticalLoop = [Face.top, Face.front, Face.bottom, Face.back];
const horizontalLoop = [Face.front, Face.right, Face.back, Face.left];

class FaceDetails {
  final Face face;
  final Coord topLeft;
  List<Face?> adjacentFace = List<Face?>.filled(4, null);
  int horizFolds = 0;
  int vertFolds = 0;

  FaceDetails(this.face, this.topLeft);

  @override
  bool operator ==(Object other) => other is FaceDetails && face == other.face;
  @override
  int get hashCode => face.hashCode;

  @override
  String toString() => face.name;

  void print(void Function(String) say) {
    say(face.toString());
    say('North: ${adjacentFace[northFace]}');
    say('South: ${adjacentFace[southFace]}');
    say('West : ${adjacentFace[westFace]}');
    say('East : ${adjacentFace[eastFace]}');
  }
}

class CubeMap {
  final int edgeSize;
  PassMap map2D = PassMap();
  Map<Coord, FaceDetails> faceMap = {};
  Map<Face, FaceDetails> faceDetails = {};

  Map<String, int> branchLog = {};

  final Coord north;
  final Coord south;
  final Coord west;
  final Coord east;

  CubeMap(this.edgeSize)
      : north = Coord(0, -edgeSize),
        south = Coord(0, edgeSize),
        west = Coord(-edgeSize, 0),
        east = Coord(edgeSize, 0);

  int _idx4(int rawIdx) => rawIdx % verticalLoop.length;

  void storeFace(
    Face face,
    Coord topLeft,
    Face? fromFace,
    int fromDir,
    int hfolds,
    int vfolds,
  ) {
    if (!map2D.isValid(topLeft)) return;
    if (faceMap.containsKey(topLeft)) return;

    FaceDetails faceDeets = FaceDetails(face, topLeft);
    faceDeets.horizFolds = hfolds;
    faceDeets.vertFolds = vfolds;

    if (face == Face.top) {
      faceDeets.adjacentFace[northFace] = Face.back;
      faceDeets.adjacentFace[southFace] = Face.front;
      faceDeets.adjacentFace[westFace] = Face.left;
      faceDeets.adjacentFace[eastFace] = Face.right;
    } else {
      final oppositeFace = _idx4(fromDir + 2);
      final leftFace = _idx4(fromDir - 1);
      final rightFace = _idx4(fromDir + 1);
      faceDeets.adjacentFace[fromDir] = fromFace;
      switch (fromFace) {
        case Face.top:
          faceDeets.adjacentFace[oppositeFace] = Face.bottom;
          switch (face) {
            case Face.front:
              faceDeets.adjacentFace[leftFace] = Face.left;
              faceDeets.adjacentFace[rightFace] = Face.right;
            case Face.left:
              faceDeets.adjacentFace[leftFace] = Face.back;
              faceDeets.adjacentFace[rightFace] = Face.front;
            case Face.right:
              faceDeets.adjacentFace[leftFace] = Face.front;
              faceDeets.adjacentFace[rightFace] = Face.back;
            case Face.back:
              faceDeets.adjacentFace[leftFace] = Face.right;
              faceDeets.adjacentFace[rightFace] = Face.left;
            default:
              devtools.log(
                  'Incompatible faces - this is $face and came from $fromFace from direction $fromDir');
          }
        case Face.front:
          faceDeets.adjacentFace[oppositeFace] = Face.back;
          switch (face) {
            case Face.top:
              devtools.log('How are we back at top?');
            case Face.left:
              faceDeets.adjacentFace[leftFace] = Face.top;
              faceDeets.adjacentFace[rightFace] = Face.bottom;
            case Face.right:
              faceDeets.adjacentFace[leftFace] = Face.bottom;
              faceDeets.adjacentFace[rightFace] = Face.top;
            case Face.bottom:
              faceDeets.adjacentFace[leftFace] = Face.left;
              faceDeets.adjacentFace[rightFace] = Face.right;
            default:
              devtools.log(
                  'Incompatible faces - this is $face and came from $fromFace from direction $fromDir');
          }
        case Face.left:
          faceDeets.adjacentFace[oppositeFace] = Face.right;
          switch (face) {
            case Face.front:
              faceDeets.adjacentFace[leftFace] = Face.bottom;
              faceDeets.adjacentFace[rightFace] = Face.top;
            case Face.top:
              devtools.log('How are we back at top?');
            case Face.bottom:
              faceDeets.adjacentFace[leftFace] = Face.back;
              faceDeets.adjacentFace[rightFace] = Face.front;
            case Face.back:
              faceDeets.adjacentFace[leftFace] = Face.top;
              faceDeets.adjacentFace[rightFace] = Face.bottom;
            default:
              devtools.log(
                  'Incompatible faces - this is $face and came from $fromFace from direction $fromDir');
          }
        case Face.right:
          faceDeets.adjacentFace[oppositeFace] = Face.left;
          switch (face) {
            case Face.front:
              faceDeets.adjacentFace[leftFace] = Face.top;
              faceDeets.adjacentFace[rightFace] = Face.bottom;
            case Face.top:
              devtools.log('How are we back at top?');
            case Face.bottom:
              faceDeets.adjacentFace[leftFace] = Face.front;
              faceDeets.adjacentFace[rightFace] = Face.back;
            case Face.back:
              faceDeets.adjacentFace[leftFace] = Face.bottom;
              faceDeets.adjacentFace[rightFace] = Face.top;
            default:
              devtools.log(
                  'Incompatible faces - this is $face and came from $fromFace from direction $fromDir');
          }
        case Face.bottom:
          faceDeets.adjacentFace[oppositeFace] = Face.top;
          switch (face) {
            case Face.front:
              faceDeets.adjacentFace[leftFace] = Face.right;
              faceDeets.adjacentFace[rightFace] = Face.left;
            case Face.left:
              faceDeets.adjacentFace[leftFace] = Face.front;
              faceDeets.adjacentFace[rightFace] = Face.back;
            case Face.right:
              faceDeets.adjacentFace[leftFace] = Face.back;
              faceDeets.adjacentFace[rightFace] = Face.front;
            case Face.back:
              faceDeets.adjacentFace[leftFace] = Face.left;
              faceDeets.adjacentFace[rightFace] = Face.right;
            default:
              devtools.log(
                  'Incompatible faces - this is $face and came from $fromFace from direction $fromDir');
          }
        case Face.back:
          faceDeets.adjacentFace[oppositeFace] = Face.front;
          switch (face) {
            case Face.top:
              devtools.log('How are we back at top?');
            case Face.left:
              faceDeets.adjacentFace[leftFace] = Face.bottom;
              faceDeets.adjacentFace[rightFace] = Face.top;
            case Face.right:
              faceDeets.adjacentFace[leftFace] = Face.top;
              faceDeets.adjacentFace[rightFace] = Face.bottom;
            case Face.bottom:
              faceDeets.adjacentFace[leftFace] = Face.right;
              faceDeets.adjacentFace[rightFace] = Face.left;
            default:
              devtools.log(
                  'Incompatible faces - this is $face and came from $fromFace from direction $fromDir');
          }
        case null:
      }
    }
    assert(!faceMap.containsValue(faceDeets));

    faceMap[topLeft] = faceDeets;
    faceDetails[face] = faceDeets;

    switch (face) {
      case Face.top:
        // Don't try topLeft + north as we always start at the top
        storeFace(
            Face.left, topLeft + west, face, eastFace, hfolds, vfolds - 1);
        storeFace(
            Face.right, topLeft + east, face, westFace, hfolds, vfolds + 1);
        storeFace(
            Face.front, topLeft + south, face, northFace, hfolds + 1, vfolds);
      // case Face.front:
      default:
        // Shouldn't need this as we always start with top
        storeFace(verticalLoop[_idx4(hfolds - 1)], topLeft + north, face,
            southFace, hfolds - 1, vfolds);
        storeFace(horizontalLoop[_idx4(vfolds - 1)], topLeft + west, face,
            eastFace, hfolds, vfolds - 1);
        storeFace(horizontalLoop[_idx4(vfolds + 1)], topLeft + east, face,
            westFace, hfolds, vfolds + 1);
        storeFace(verticalLoop[_idx4(hfolds + 1)], topLeft + south, face,
            northFace, hfolds + 1, vfolds);
    }
  }

  bool checkBoundsPt2(Coord coord) {
    bool movedFace = false;
    switch (map2D.direction) {
      case 0: // right
        if (coord.x >= map2D.passMap[coord.y].length) {
          movedFace = true;
          coord.x--;
          final topLeft = Coord(
              coord.x ~/ edgeSize * edgeSize, coord.y ~/ edgeSize * edgeSize);
          final thisFace = faceMap[topLeft]!;
          final nextFace = faceDetails[thisFace.adjacentFace[eastFace]!]!;
          if (nextFace.adjacentFace[northFace]! == thisFace.face) {
            branchLog['Right-North'] = branchLog['Right-North']! + 1;
            map2D.direction = 1; // down
            final newX = edgeSize - (coord.y - topLeft.y) - 1;
            coord.x = nextFace.topLeft.x + newX;
            coord.y = nextFace.topLeft.y;
          } else if (nextFace.adjacentFace[southFace]! == thisFace.face) {
            branchLog['Right-South'] = branchLog['Right-South']! + 1;
            map2D.direction = 3; // up
            final newX = coord.y - topLeft.y;
            coord.x = nextFace.topLeft.x + newX;
            coord.y = nextFace.topLeft.y + edgeSize - 1;
          } else if (nextFace.adjacentFace[eastFace]! == thisFace.face) {
            branchLog['Right-East'] = branchLog['Right-East']! + 1;
            map2D.direction = 2; // left
            final newY = edgeSize - (coord.y - topLeft.y) - 1;
            coord.x = nextFace.topLeft.x + edgeSize - 1;
            coord.y = nextFace.topLeft.y + newY;
          } else if (nextFace.adjacentFace[westFace]! == thisFace.face) {
            branchLog['Right-West'] = branchLog['Right-West']! + 1;
            // direction stays right
            coord.x = nextFace.topLeft.x;
            coord.y = nextFace.topLeft.y + coord.y - topLeft.y;
          } else {
            devtools.log('checkBounds2: move right - could not match face');
          }
        }
      case 1: // down
        if (coord.y > map2D.maxY[coord.x]) {
          movedFace = true;
          coord.y--;
          final topLeft = Coord(
              coord.x ~/ edgeSize * edgeSize, coord.y ~/ edgeSize * edgeSize);
          final thisFace = faceMap[topLeft]!;
          final nextFace = faceDetails[thisFace.adjacentFace[southFace]!]!;
          if (nextFace.adjacentFace[northFace]! == thisFace.face) {
            branchLog['Down-North'] = branchLog['Down-North']! + 1;
            // direction stays down
            coord.x = nextFace.topLeft.x + coord.x - topLeft.x;
            coord.y = nextFace.topLeft.y;
          } else if (nextFace.adjacentFace[southFace]! == thisFace.face) {
            branchLog['Down-South'] = branchLog['Down-South']! + 1;
            map2D.direction = 3; // up
            final newX = edgeSize - (coord.x - topLeft.x) - 1;
            coord.x = nextFace.topLeft.x + newX;
            coord.y = nextFace.topLeft.y + edgeSize - 1;
          } else if (nextFace.adjacentFace[eastFace]! == thisFace.face) {
            branchLog['Down-East'] = branchLog['Down-East']! + 1;
            map2D.direction = 2; // left
            final newY = coord.x - topLeft.x;
            coord.x = nextFace.topLeft.x + edgeSize - 1;
            coord.y = nextFace.topLeft.y + newY;
          } else if (nextFace.adjacentFace[westFace]! == thisFace.face) {
            branchLog['Down-West'] = branchLog['Down-West']! + 1;
            map2D.direction = 0; // right
            final newY = edgeSize - (coord.x - topLeft.x) - 1;
            coord.x = nextFace.topLeft.x;
            coord.y = nextFace.topLeft.y + newY;
          } else {
            devtools.log('checkBounds2: move down - could not match face');
          }
        }
      case 2: // left
        if (coord.x < map2D.minX[coord.y]) {
          movedFace = true;
          coord.x++;
          final topLeft = Coord(
              coord.x ~/ edgeSize * edgeSize, coord.y ~/ edgeSize * edgeSize);
          final thisFace = faceMap[topLeft]!;
          final nextFace = faceDetails[thisFace.adjacentFace[westFace]!]!;
          if (nextFace.adjacentFace[northFace]! == thisFace.face) {
            branchLog['Left-North'] = branchLog['Left-North']! + 1;
            map2D.direction = 1; // down
            coord.x = nextFace.topLeft.x + coord.y - topLeft.y;
            coord.y = nextFace.topLeft.y;
          } else if (nextFace.adjacentFace[southFace]! == thisFace.face) {
            branchLog['Left-South'] = branchLog['Left-South']! + 1;
            map2D.direction = 3; // up
            final newX = edgeSize - (coord.y - topLeft.y) - 1;
            coord.x = nextFace.topLeft.x + newX;
            coord.y = nextFace.topLeft.y + edgeSize - 1;
          } else if (nextFace.adjacentFace[eastFace]! == thisFace.face) {
            branchLog['Left-East'] = branchLog['Left-East']! + 1;
            // direction stays left
            coord.x = nextFace.topLeft.x + edgeSize - 1;
            coord.y = nextFace.topLeft.y + coord.y - topLeft.y;
          } else if (nextFace.adjacentFace[westFace]! == thisFace.face) {
            branchLog['Left-West'] = branchLog['Left-West']! + 1;
            map2D.direction = 0; // right
            final newY = edgeSize - (coord.y - topLeft.y) - 1;
            coord.x = nextFace.topLeft.x;
            coord.y = nextFace.topLeft.y + newY;
          } else {
            devtools.log('checkBounds2: move left - could not match face');
          }
        }
      case 3: // up
        if (coord.y < map2D.minY[coord.x]) {
          movedFace = true;
          coord.y++;
          final topLeft = Coord(
              coord.x ~/ edgeSize * edgeSize, coord.y ~/ edgeSize * edgeSize);
          final thisFace = faceMap[topLeft]!;
          final nextFace = faceDetails[thisFace.adjacentFace[northFace]!]!;
          if (nextFace.adjacentFace[northFace]! == thisFace.face) {
            branchLog['Up-North'] = branchLog['Up-North']! + 1;
            map2D.direction = 1; // down
            final newX = edgeSize - (coord.x - topLeft.x) - 1;
            coord.x = nextFace.topLeft.x + newX;
            coord.y = nextFace.topLeft.y;
          } else if (nextFace.adjacentFace[southFace]! == thisFace.face) {
            branchLog['Up-South'] = branchLog['Up-South']! + 1;
            // direction stays up
            coord.x = nextFace.topLeft.x + coord.x - topLeft.x;
            coord.y = nextFace.topLeft.y + edgeSize - 1;
          } else if (nextFace.adjacentFace[eastFace]! == thisFace.face) {
            branchLog['Up-East'] = branchLog['Up-East']! + 1;
            map2D.direction = 2; // left
            final newY = edgeSize - (coord.x - topLeft.x) - 1;
            coord.x = nextFace.topLeft.x + edgeSize - 1;
            coord.y = nextFace.topLeft.y + newY;
          } else if (nextFace.adjacentFace[westFace]! == thisFace.face) {
            branchLog['Up-West'] = branchLog['Up-West']! + 1;

            map2D.direction = 0; // right
            final newY = coord.x - topLeft.x;
            coord.x = nextFace.topLeft.x;
            coord.y = nextFace.topLeft.y + newY;
          } else {
            devtools.log('checkBounds2: move up - could not match face');
          }
        }
      default:
        devtools.log('checkBounds2: Invalid direction: ${map2D.direction}');
    }
    return movedFace;
  }
}

class Day22P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 22 Part 2');

    int faceSize = 4;
    if ((await lines().first).length % 50 == 0) {
      faceSize = 50;
    }

    var cubeMap = CubeMap(faceSize);
    await cubeMap.map2D.loadMap(lines);
    cubeMap.storeFace(Face.top, cubeMap.map2D.position, null, 0, 0, 0);
    say(cubeMap.faceMap.toString());
    for (final face in cubeMap.faceMap.values) {
      face.print(say);
      say('-----------------');
    }

    const moveDirection = ['Right', 'Down', 'Left', 'Up'];
    const edgeName = ['North', 'South', 'East', 'West'];
    for (final moveDir in moveDirection) {
      for (final edge in edgeName) {
        cubeMap.branchLog['$moveDir-$edge'] = 0;
      }
    }

    cubeMap.map2D.followPath(cubeMap.checkBoundsPt2);

    say('');
    say('');
    for (final line in cubeMap.map2D.graphic) {
      say(line);
    }

    for (final key in cubeMap.branchLog.keys) {
      say('$key - ${cubeMap.branchLog[key]}');
    }

    say('Position is ${cubeMap.map2D.position.toString()}');
    say('Direction is ${cubeMap.map2D.direction}');

    final answer = 1000 * (cubeMap.map2D.position.y + 1) +
        4 * (cubeMap.map2D.position.x + 1) +
        cubeMap.map2D.direction;
    say('The answer is $answer');
  }
}

// Test routes
// Right-North - 1
// Down-South - 1
// Up-West - 1

// Real routes
// Right-South - 18
// Right-East - 6
// Down-North - 11
// Down-East - 15
// Left-North - 28
// Left-West - 45
// Up-South - 14
// Up-West - 36