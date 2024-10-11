enum Operator {
  noop(cycles: 1),
  addx(cycles: 2);

  const Operator({required this.cycles});

  final int cycles;
}

class Instruction {
  final Operator opcode;
  final int operand;

  Instruction({required this.opcode, required this.operand});
}
