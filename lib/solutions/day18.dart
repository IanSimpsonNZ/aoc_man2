// import 'dart:convert';
// import 'dart:io';
import 'dart:math' show min, max;
// import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
// import 'package:aoc_manager/solutions/helpers/coord.dart';

// import 'dart:developer' as devtools show log;

class Coord3D {
  int x;
  int y;
  int z;

  Coord3D(this.x, this.y, this.z);

  Coord3D operator +(Coord3D c) => Coord3D(x + c.x, y + c.y, z + c.z);
  Coord3D operator -(Coord3D c) => Coord3D(x - c.x, y - c.y, z - c.z);
  @override
  bool operator ==(Object other) =>
      other is Coord3D && x == other.x && y == other.y && z == other.z;
  @override
  int get hashCode => Object.hash(x, y, z);

  Coord3D clone() => Coord3D(x, y, z);

  String print() => '($x, $y, $z)';
}

class CubeFace {
  late final Set<Coord3D> corners;

  CubeFace(Coord3D c1, Coord3D c2, Coord3D c3, Coord3D c4) {
    corners = {};
    corners.add(c1);
    corners.add(c2);
    corners.add(c3);
    corners.add(c4);
    assert(corners.length == 4);
  }

  CubeFace.fromFace(CubeFace face) {
    corners = Set.from(face.corners);
  }

  @override
  bool operator ==(Object other) =>
      other is CubeFace && corners.intersection(other.corners).length == 4;

  @override
  int get hashCode => Object.hashAllUnordered(corners);

  bool isNextTo(CubeFace other) {
    final numSameCorners = corners.intersection(other.corners).length;
    // devtools.log('Num same corners is $numSameCorners');
    assert(numSameCorners <= 2);
    return numSameCorners == 2;
  }

  String print() {
    String result = '';
    for (final corner in corners) {
      result = '$result${corner.print()} ';
    }
    return result;
  }
}

const cubeSize = 1;

class Cube {
  final Coord3D position;
  final Set<CubeFace> faces = {};

  Cube(this.position) {
    final plusX = position + Coord3D(cubeSize, 0, 0);
    final plusY = position + Coord3D(0, cubeSize, 0);
    final plusZ = position + Coord3D(0, 0, cubeSize);
    final plusXY = position + Coord3D(cubeSize, cubeSize, 0);
    final plusXZ = position + Coord3D(cubeSize, 0, cubeSize);
    final plusYZ = position + Coord3D(0, cubeSize, cubeSize);
    final plusXYZ = position + Coord3D(cubeSize, cubeSize, cubeSize);

    faces.add(CubeFace(position, plusX, plusXY, plusY));
    faces.add(CubeFace(plusZ, plusXZ, plusXYZ, plusYZ));
    faces.add(CubeFace(position, plusX, plusXZ, plusZ));
    faces.add(CubeFace(plusX, plusXY, plusXYZ, plusXZ));
    faces.add(CubeFace(plusXY, plusY, plusYZ, plusXYZ));
    faces.add(CubeFace(plusY, position, plusZ, plusYZ));
  }

  @override
  bool operator ==(Object other) =>
      other is Cube && faces.intersection(other.faces).length == 6;

  @override
  int get hashCode => Object.hashAllUnordered(faces);
}

const bigNum = 1000000000000;

class LavaBlob {
  Set<Cube> lava = {};
  Set<Cube> water = {};
  Set<CubeFace> faces = {};
  Set<CubeFace> interiorFaces = {};
  List<Cube> waterStack = [];
  int minX = bigNum;
  int maxX = -bigNum;
  int minY = bigNum;
  int maxY = -bigNum;
  int minZ = bigNum;
  int maxZ = -bigNum;

  void Function(String) say;

  LavaBlob(this.say);

  void add(Cube cube) {
    lava.add(cube);

    minX = min(minX, cube.position.x);
    maxX = max(maxX, cube.position.x + cubeSize);
    minY = min(minY, cube.position.y);
    maxY = max(maxY, cube.position.y + cubeSize);
    minZ = min(minZ, cube.position.z);
    maxZ = max(maxZ, cube.position.z + cubeSize);

    for (final face in cube.faces) {
      if (faces.contains(face)) {
        faces.remove(face);
      } else {
        faces.add(face);
      }
    }
  }

  void _flood() {
    while (waterStack.isNotEmpty) {
      final fromCube = waterStack.removeLast();
      // allow for 1 water cube around entire lava blob
      if (!(fromCube.position.x >= minX - cubeSize &&
          fromCube.position.x <= maxX &&
          fromCube.position.y >= minY - cubeSize &&
          fromCube.position.y <= maxY &&
          fromCube.position.z >= minZ - cubeSize &&
          fromCube.position.z <= maxZ)) {
        continue;
      }

      if (lava.contains(fromCube)) {
        continue;
      }

      if (water.contains(fromCube)) {
        continue;
      }

      water.add(fromCube);
      interiorFaces.removeAll(fromCube.faces);
      final thisX = fromCube.position.x;
      final thisY = fromCube.position.y;
      final thisZ = fromCube.position.z;
      // down
      waterStack.add(Cube(Coord3D(thisX, thisY, thisZ - cubeSize)));
      // right
      waterStack.add(Cube(Coord3D(thisX + cubeSize, thisY, thisZ)));
      // left
      waterStack.add(Cube(Coord3D(thisX - cubeSize, thisY, thisZ)));
      // back
      waterStack.add(Cube(Coord3D(thisX, thisY + cubeSize, thisZ)));
      // forward
      waterStack.add(Cube(Coord3D(thisX, thisY - cubeSize, thisZ)));
      // up
      waterStack.add(Cube(Coord3D(thisX, thisY, thisZ + cubeSize)));
    }
  }

  void findInteriorFaces() {
    interiorFaces = Set.from(faces);
    final cube1 =
        Cube(Coord3D(minX - cubeSize, minY - cubeSize, minZ - cubeSize));
    waterStack.add(cube1);
    _flood();
  }
}

class Day18P1 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 18 Part 1');

    var blob = LavaBlob(say);

    await for (final line in lines()) {
      if (line.isEmpty) continue;
      // say(line);
      final coords =
          line.split(',').map((numStr) => int.parse(numStr)).toList();
      final cube = Cube(Coord3D(coords[0], coords[1], coords[2]));
      blob.add(cube);
    }

    say('There are ${blob.faces.length} exposed faces');
  }
}

class Day18P2 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 18 Part 2');

    var blob = LavaBlob(say);

    await for (final line in lines()) {
      if (line.isEmpty) continue;
      final coords =
          line.split(',').map((numStr) => int.parse(numStr)).toList();
      final cube = Cube(Coord3D(coords[0], coords[1], coords[2]));
      blob.add(cube);
    }

    say('There are ${blob.faces.length} exposed faces');
    say('Flood box is x: ${blob.minX - cubeSize} - ${blob.maxX}, y: ${blob.minY - cubeSize} - ${blob.maxY}, z: ${blob.minZ - cubeSize} - ${blob.maxZ}');
    say('${blob.lava.length} lava cubes');
    final waterBox = (blob.maxX - (blob.minX - cubeSize) + cubeSize) *
        (blob.maxY - (blob.minY - cubeSize) + cubeSize) *
        (blob.maxZ - (blob.minZ - cubeSize) + cubeSize);
    say('Water box is $waterBox cubes');

    blob.findInteriorFaces();

    say('${blob.water.length} water cubes');
    say('There are ${waterBox - blob.lava.length - blob.water.length} interior cubes');
    say('${blob.interiorFaces.length} interior faces');
    final numExterior = blob.faces.length - blob.interiorFaces.length;
    say('There are $numExterior exterior faces');
  }
}
