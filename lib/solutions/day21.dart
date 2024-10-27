// import 'dart:convert';
// import 'dart:io';
// import 'dart:math' show max;
// import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
// import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

class MonkeyJob {
  int? number;
  String leftParam = '';
  String rightParam = '';
  String operator = '';

  String print() {
    if (number != null) {
      return '$number';
    }
    return '$leftParam $operator $rightParam';
  }
}

const root = 'root';

class Day21P1 extends Solution {
  Map<String, MonkeyJob> monkeys = {};

  int calc(String rootName) {
    final monkey = monkeys[rootName]!;
    if (monkey.number != null) {
      return monkey.number!;
    }
    final leftVal = calc(monkey.leftParam);
    final rightVal = calc(monkey.rightParam);
    switch (monkey.operator) {
      case '+':
        return leftVal + rightVal;
      case '-':
        return leftVal - rightVal;
      case '*':
        return leftVal * rightVal;
      case '/':
        return leftVal ~/ rightVal;
      default:
        devtools.log('Invalid operator - "${monkey.operator}"');
        return 0;
    }
  }

  Future<void> getMonkeys() async {
    await for (final line in lines()) {
      if (line.isEmpty) break;

      final lineParts = line.split(':');
      final monkeyName = lineParts[0];
      final monkey = MonkeyJob();
      monkey.number = int.tryParse(lineParts[1]);
      if (monkey.number == null) {
        final formula = lineParts[1].trim().split(' ');
        monkey.leftParam = formula[0];
        monkey.rightParam = formula[2];
        monkey.operator = formula[1];
      }
      monkeys[monkeyName] = monkey;
    }
  }

  @override
  Future<void> specificSolution() async {
    say('Day 21 Part 1');

    await getMonkeys();
    say('The answer is ${calc(root)}');
  }
}

const human = 'humn';

class Day21P2 extends Day21P1 {
  int? tryCalc(String rootName) {
    if (rootName == human) return null;

    final monkey = monkeys[rootName]!;

    if (rootName == root) {
      final leftVal = tryCalc(monkey.leftParam);
      final rightVal = tryCalc(monkey.rightParam);
      if (leftVal == null) {
        say('Human is on left');
        return rightVal;
      }

      say('Human is on right');
      return leftVal;
    }

    if (monkey.number != null) {
      return monkey.number!;
    }

    final leftVal = tryCalc(monkey.leftParam);
    final rightVal = tryCalc(monkey.rightParam);
    if (rightVal == null || leftVal == null) return null;

    int? returnVal;
    switch (monkey.operator) {
      case '+':
        returnVal = leftVal + rightVal;
      case '-':
        returnVal = leftVal - rightVal;
      case '*':
        returnVal = leftVal * rightVal;
      case '/':
        returnVal = leftVal ~/ rightVal;
      default:
        devtools.log('Invalid operator - "${monkey.operator}"');
        returnVal = 0;
    }
    monkey.number = returnVal;
    return returnVal;
  }

  int calcFromRight(String operator, String rightName, int target) {
    final rightVal = monkeys[rightName]!.number;
    assert(rightVal != null);
    switch (operator) {
      case '+':
        return target - rightVal!;
      case '-':
        return target + rightVal!;
      case '*':
        return target ~/ rightVal!;
      case '/':
        return target * rightVal!;
      default:
        devtools.log('Invalid operator in calcFromRight - "$operator"');
        return 0;
    }
  }

  int calcFromLeft(String operator, String leftName, int target) {
    final leftVal = monkeys[leftName]!.number;
    assert(leftVal != null);
    switch (operator) {
      case '+':
        return target - leftVal!;
      case '-':
        return leftVal! - target;
      case '*':
        return target ~/ leftVal!;
      case '/':
        return leftVal! ~/ target;
      default:
        devtools.log('Invalid operator in calcFromLeft - "$operator"');
        return 0;
    }
  }

  int pushdown(String monkeyName, int target) {
    final monkey = monkeys[monkeyName]!;
    if (monkey.leftParam == human) {
      return calcFromRight(monkey.operator, monkey.rightParam, target);
    }
    if (monkey.rightParam == human) {
      return calcFromLeft(monkey.operator, monkey.leftParam, target);
    }

    int? leftVal = monkeys[monkey.leftParam]!.number;
    if (leftVal == null) {
      final newTarget =
          calcFromRight(monkey.operator, monkey.rightParam, target);
      return pushdown(monkey.leftParam, newTarget);
    }
    final newTarget = calcFromLeft(monkey.operator, monkey.leftParam, target);
    return pushdown(monkey.rightParam, newTarget);
  }

  @override
  Future<void> specificSolution() async {
    say('Day 21 Part 2');

    await getMonkeys();

    final target = tryCalc(root)!;
    say('The target is $target');

    final leftLeg = monkeys[root]!.leftParam;
    final rightLeg = monkeys[root]!.rightParam;

    final leftVal = monkeys[leftLeg]!.number;
    String startLeg;
    if (leftVal == null) {
      startLeg = leftLeg;
    } else {
      startLeg = rightLeg;
    }

    say('The answer is ${pushdown(startLeg, target)}');
  }
}
