import 'dart:developer' as devtools show log;

import 'package:aoc_manager/solutions/CPU/cpu_core.dart';

const lineLength = 40;

class CPUv2 {
  int X = 1;
  List<int> interrupts = [];

  Instruction _fetch(String assembly) {
    Operator opcode = Operator.noop;
    int operand = 0;

    final parts = assembly.split(' ');
    switch (parts[0].toLowerCase()) {
      case 'noop':
        break; // It's the derfault
      case 'addx':
        opcode = Operator.addx;
        operand = int.parse(parts[1]);
      default:
        devtools.log('Invalid instruction: "$assembly"');
    }
    return Instruction(opcode: opcode, operand: operand);
  }

  void _execute(Instruction instruction) {
    switch (instruction.opcode) {
      case Operator.noop:
        break; // Nothing to do
      case Operator.addx:
        X += instruction.operand;
    }
  }

  Stream<String> run(Stream<String> program) async* {
    int clock = 0;
    String scanLine = '';

    bool interrupt() {
      if (interrupts.isNotEmpty && clock == interrupts[0]) {
        interrupts.removeAt(0);
        return true;
      } else {
        return false;
      }
    }

    void tick() {
      scanLine =
          '$scanLine${((clock % lineLength) - X).abs() <= 1 ? '#' : '.'}';
      clock++;
    }

    await for (final line in program) {
      if (line.isEmpty) continue;
      Instruction instruction = _fetch(line);
      for (int c = 0; c < instruction.opcode.cycles - 1; c++) {
        tick();
        if (interrupt()) {
          yield scanLine;
          scanLine = '';
        }
      }
      tick();
      if (interrupt()) {
        yield scanLine;
        scanLine = '';
      }
      _execute(instruction);
    }
  }
}
