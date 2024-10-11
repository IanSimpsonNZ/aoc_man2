import 'dart:developer' as devtools show log;

import 'package:aoc_manager/solutions/CPU/cpu_core.dart';

class CPUv1 {
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

  Stream<int> run(Stream<String> program) async* {
    int clock = 0;

    bool interrupt() {
      if (interrupts.isNotEmpty && clock == interrupts[0]) {
        interrupts.removeAt(0);
        return true;
      } else {
        return false;
      }
    }

    await for (final line in program) {
      if (line.isEmpty) continue;
      Instruction instruction = _fetch(line);
      for (int c = 0; c < instruction.opcode.cycles - 1; c++) {
        clock++;
        if (interrupt()) yield X * clock;
      }
      clock++;
      if (interrupt()) yield X * clock;
      _execute(instruction);
    }
  }
}
