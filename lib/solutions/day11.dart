//import 'dart:convert';
import "package:async/async.dart" show StreamQueue;

import 'package:aoc_manager/solutions/generic_solution.dart';

import 'dart:developer' as devtools show log;

class Operation {
  int? a;
  int? b;
  String? op;

  Operation(String formula) {
    final components = formula.split(' ');
    if (components[0] != 'old') a = int.parse(components[0]);
    if (components[2] != 'old') b = int.parse(components[2]);
    op = components[1];
    assert(op == '*' || op == '+');
  }

  int calculate(int oldValue) {
    assert(op != null);
    final actualA = a ?? oldValue;
    final actualB = b ?? oldValue;
    final int result;
    if (op == '+') {
      result = actualA + actualB;
    } else {
      result = actualA * actualB;
    }
    return result;
  }

  String print() => '${a ?? 'old'} $op ${b ?? 'old'}';
}

class Monkey {
  List<int> itemList = [];
  Operation? operation;
  int? divisibleBy;
  int? trueMonkey;
  int? falseMonkey;
  int inspectionCount = 0;

  Monkey(List<String> definition) {
    final header = definition[0].split(' ');
    assert(header[0] == 'Monkey');

    final rawItemList = definition[1].split(':')[1].split(',');
    itemList = rawItemList.map((itemStr) => int.parse(itemStr)).toList();

    operation = Operation(definition[2].split('=')[1].trim());

    divisibleBy = int.parse(definition[3].split(' ').last);

    final rawTrue = definition[4].trim().split(' ');
    assert(rawTrue[1] == 'true:');
    trueMonkey = int.parse(rawTrue.last);

    final rawFalse = definition[5].trim().split(' ');
    assert(rawFalse[1] == 'false:');
    falseMonkey = int.parse(rawFalse.last);
  }

  void log() {
    devtools.log('Starting items: ${itemList.toString()}');
    devtools.log('Operation: new = ${operation?.print()}');
    devtools.log('Test: divisible by $divisibleBy');
    devtools.log('If true: throw to monkey $trueMonkey');
    devtools.log('If false: throw to monkey $falseMonkey');
  }
}

class Day11P1 extends Solution {
  List<Monkey> monkeys = [];

  Future<void> getMonkeys() async {
    final queue = StreamQueue<String>(lines());
    while (await queue.hasNext) {
      final monkeyDefn = await queue.take(6);
      monkeys.add(Monkey(monkeyDefn));
      await queue.take(1);
    }
    queue.cancel();
  }

  void playTurn(int monkeyNum) {
    final monkey = monkeys[monkeyNum];
    final itemList = monkey.itemList;
    while (itemList.isNotEmpty) {
      monkey.inspectionCount++;
      final worryLevel = monkey.operation!.calculate(itemList[0]) ~/ 3;
      if (worryLevel % monkey.divisibleBy! == 0) {
        monkeys[monkey.trueMonkey!].itemList.add(worryLevel);
      } else {
        monkeys[monkey.falseMonkey!].itemList.add(worryLevel);
      }
      itemList.removeAt(0);
    }
  }

  @override
  Future<void> specificSolution() async {
    say('Day 11 Part 1');

    await getMonkeys();
    for (int round = 0; round < 20; round++) {
      for (int monkeyNum = 0; monkeyNum < monkeys.length; monkeyNum++) {
        playTurn(monkeyNum);
      }
    }

    int first = 0;
    int second = 0;
    for (final (monkeyNum, monkey) in monkeys.indexed) {
      final inspections = monkey.inspectionCount;
      say('Monkey $monkeyNum inspected items $inspections times.');
      if (inspections >= first) {
        second = first;
        first = inspections;
      } else if (inspections > second) {
        second = inspections;
      }
    }
    say('The answer is $first * $second = ${first * second}');
  }
}

class Day11P2 extends Day11P1 {
  int commonDiv = 0;

  @override
  void playTurn(int monkeyNum) {
    final monkey = monkeys[monkeyNum];
    final itemList = monkey.itemList;
    while (itemList.isNotEmpty) {
      monkey.inspectionCount++;
      final worryLevel = monkey.operation!.calculate(itemList[0]) % commonDiv;
      if (worryLevel % monkey.divisibleBy! == 0) {
        monkeys[monkey.trueMonkey!].itemList.add(worryLevel);
      } else {
        monkeys[monkey.falseMonkey!].itemList.add(worryLevel);
      }
      itemList.removeAt(0);
    }
  }

  @override
  Future<void> specificSolution() async {
    say('Day 11 Part 2');

    await getMonkeys();

    commonDiv = monkeys.fold<int>(
        1, (product, monkey) => product * monkey.divisibleBy!);

    for (int round = 0; round < 10000; round++) {
      for (int monkeyNum = 0; monkeyNum < monkeys.length; monkeyNum++) {
        playTurn(monkeyNum);
      }
    }

    int first = 0;
    int second = 0;
    for (final (monkeyNum, monkey) in monkeys.indexed) {
      final inspections = monkey.inspectionCount;
      say('Monkey $monkeyNum inspected items $inspections times.');
      if (inspections >= first) {
        second = first;
        first = inspections;
      } else if (inspections > second) {
        second = inspections;
      }
    }
    say('The answer is $first * $second = ${first * second}');
  }
}
