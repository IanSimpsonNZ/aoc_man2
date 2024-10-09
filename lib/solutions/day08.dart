import 'dart:convert';
import 'dart:isolate';

import 'package:aoc_manager/solutions/generic_solution.dart';

import 'dart:developer' as devtools show log;

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
  // List<int> maxHeights = [];
  // if (maxHeights.isEmpty) {
  //   // if empty, this is first row
  //   // This is how e create new List objects ...
  //   maxHeights = [...rowHeights];
  //   forrest.add([...maxHeights]);
  //   visible.add(List<bool>.filled(lineLength, false, growable: true));
  //   continue;
  // }

  // for all the other lines
  // across the row
  //
}

class Day08P1 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 8 Part 1');

    try {
      final forrest = Forrest();
      await forrest.loadForrest(lines());
      forrest.print(say);
    } catch (e) {
      final err = e as Error;
      sendPort?.send(RemoteError(err.toString(), err.stackTrace.toString()));
    }
  }
}

class Day08P2 extends Solution {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 8 Part 2');

    while (true) {}
  }
}
