// import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// import 'package:collection/collection.dart';

import 'package:aoc_manager/solutions/generic_solution.dart';

const startOfPacketLen = 4;
const startOfMessageLen = 14;

mixin HeaderFunc {
  int? getSignal({required List<int> signal, required int headerLen}) {
    int? answer;
    for (int i = 0; i < signal.length - headerLen; i++) {
      final testHeader = signal.sublist(i, i + headerLen);
      if (testHeader.length == testHeader.toSet().length) {
        answer = i + headerLen;
        break;
      }
    }
    return answer;
  }
}

class Day06P1 extends Solution with HeaderFunc {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 6 Part 1');

    final signal = await File(inputFile!).openRead().first;

    final answer = getSignal(signal: signal, headerLen: startOfPacketLen);

    if (answer == null) {
      say('No header found');
    } else {
      say('The answer is $answer');
    }
  }
}

class Day06P2 extends Solution with HeaderFunc {
  @override
  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;
    say('Day 6 Part 2');

    final signal = await File(inputFile!).openRead().first;
    final answer = getSignal(signal: signal, headerLen: startOfMessageLen);

    if (answer == null) {
      say('No header found');
    } else {
      say('The answer is $answer');
    }
  }
}
