// import 'dart:convert';
// import 'dart:io';
import 'dart:math' show max;
// import "package:async/async.dart" show StreamQueue;

// import 'dart:typed_data';

import 'package:aoc_manager/solutions/generic_solution.dart';
// import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

const String ore = 'ore';
const String clay = 'clay';
const String obsidian = 'obsidian';
const String geode = 'geode';
const doNothing = 'Wait';
const String defaultBuild = ore;

class Requirement {
  final int commodityIdx;
  final int amount;

  const Requirement(this.commodityIdx, this.amount);
}

class SimState {
  int time = 0;
  List<int> productionRate;
  List<int> stock = [];
  String history = '';

  SimState(List<int> initialProduction)
      : productionRate = List.from(initialProduction),
        stock = List.filled(initialProduction.length, 0);

  SimState.fromState(SimState other)
      : productionRate = List.from(other.productionRate),
        stock = List.from(other.stock),
        time = other.time,
        history = other.history;

  void tick() {
    time++;
    for (final (idx, prod) in productionRate.indexed) {
      stock[idx] += prod;
    }
  }
}

class Sim {
  int bpNum = 0;
  int maxTime = 0;
  Map<String, int> idxLookup = {};
  List<String> nameLookup = []; // Used for printing
  List<List<Requirement>> requirements = [];
  List<int> initialProduction = [];
  List<int> maxRequired = [];

  void Function(String) say;

  Sim(this.maxTime, this.say);

  void loadBluePrint(String blueprint) {
    // Add "Do nothing" commodity
    nameLookup.add(doNothing);
    const nothingIdx = 0;
    idxLookup[doNothing] = nothingIdx;
    initialProduction.add(0);
    // Requires 0 nothings, so will alwys trigger "canMake" - ie. always wait a turn as an option
    requirements.add([const Requirement(nothingIdx, 0)]);

    // Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
    final bpNumSplit = blueprint.split(':');
    // [Blueprint 1][ Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.]
    bpNum = int.parse(bpNumSplit[0].split(' ')[1]);

    final robotSpecList = bpNumSplit[1].split('.');
    // [ Each ore robot costs 4 ore][ Each clay robot costs 2 ore][ Each obsidian robot costs 3 ore and 14 clay][ Each geode robot costs 2 ore and 7 obsidian]
    //
    for (final (idx, rawSpec) in robotSpecList.indexed) {
      // Do Nothing is the first commodity
      final commodityIdx = idx + 1;
      final spec = rawSpec.trim();
      if (spec.isEmpty) break; // catch a space at end of line

      requirements.add([]);
      String commodityName = '';

      final requirementsList = spec.split('and');
      // [Each clay robot costs 2 ore]  OR  [Each obsidian robot costs 3 ore ][ 14 clay]
      for (int requirementIdx = 0;
          requirementIdx < requirementsList.length;
          requirementIdx++) {
        final words = requirementsList[requirementIdx].trim().split(' ');
        // [Each][obsidian][robot][costs][3][ore]   OR    [14][clay]

        if (requirementIdx == 0) {
          commodityName = words[1];
          nameLookup.add(commodityName);
          idxLookup[commodityName] = commodityIdx;
          if (commodityName == ore) {
            initialProduction.add(1);
          } else {
            initialProduction.add(0);
          }
        }

        final requirement = Requirement(
            idxLookup[words.last]!, int.parse(words[words.length - 2]));
        requirements[commodityIdx].add(requirement);
      }
    }

    maxRequired = List.filled(nameLookup.length, 0);
    for (final requirementList in requirements) {
      for (final requirement in requirementList) {
        maxRequired[requirement.commodityIdx] =
            max(maxRequired[requirement.commodityIdx], requirement.amount);
      }
    }
  }

  void print() {
    say('Blueprint number $bpNum');
    say('Max Time: $maxTime');
    String detailStr = '';
    for (final (commodityIdx, commodityName) in nameLookup.indexed) {
      detailStr =
          '$commodityName: Prod ${initialProduction[commodityIdx]}: Max ${maxRequired[commodityIdx]}: ';
      for (final requirementDeets in requirements[commodityIdx]) {
        detailStr =
            '$detailStr [${nameLookup[requirementDeets.commodityIdx]}, ${requirementDeets.amount}]';
      }
      say(detailStr);
    }
  }

  void printState(SimState state) {
    final canMake = getCanMake(state);
    say('Time: ${state.time}');
    for (final (commodityIdx, name) in nameLookup.indexed) {
      say('$name: Prod ${state.productionRate[commodityIdx]}: Stock ${state.stock[commodityIdx]}: ${canMake[commodityIdx] ? "Can Make" : ""}');
    }
  }

  List<bool> getCanMake(SimState state) {
    List<bool> result = [];
    for (final requirementList in requirements) {
      bool thisResult = true;
      for (final requirement in requirementList) {
        thisResult &=
            (state.stock[requirement.commodityIdx] >= requirement.amount);
      }
      result.add(thisResult);
    }

    return result;
  }

  void build(int commodityIdx, SimState state) {
    state.productionRate[commodityIdx]++;
    for (final requirement in requirements[commodityIdx]) {
      state.stock[requirement.commodityIdx] -= requirement.amount;
      assert(state.stock[requirement.commodityIdx] >= 0);
    }
    state.history = '${state.history}${nameLookup[commodityIdx]} ';
  }

  int runSim() {
    List<SimState> simList = [SimState(initialProduction)];
    int maxGeodes = 0;
    final geodeIdx = idxLookup[geode]!;
    final doNothingIdx = idxLookup[doNothing]!;
    const debugTime = 0;

    while (simList.isNotEmpty) {
      final state = simList.removeAt(0);
      if (state.time == maxTime) {
        if (state.stock[geodeIdx] > maxGeodes) {
          maxGeodes = state.stock[geodeIdx];
          say('New max = $maxGeodes : ${state.history}');
        }
        continue;
      }

      final timeLeft = maxTime - state.time;
      final baseGeodeAmount =
          state.stock[geodeIdx] + state.productionRate[geodeIdx] * timeLeft;

      final canMakeList = getCanMake(state);
      for (int commodityIdx = 0;
          commodityIdx < canMakeList.length;
          commodityIdx++) {
        final canMake = canMakeList[commodityIdx];
        if (canMake) {
          // Is it possible to beat the current maximum?
          final minTimeToBuildGeode = (commodityIdx == geodeIdx) ? 0 : 1;
          final newGeodeTime = timeLeft - minTimeToBuildGeode;

          // See examples at end of file for derivation of this magic formula ...
          final geodeRamp = (newGeodeTime * (newGeodeTime + 1)) ~/ 2;
          assert(geodeRamp >= 0);
          final maxPossibleGeode = baseGeodeAmount + geodeRamp;
          if (maxGeodes >= maxPossibleGeode) {
            continue;
          }

          // Check if we already have enough of this commodity for the rest of the sim
          if (commodityIdx != doNothingIdx &&
              commodityIdx != geodeIdx &&
              state.productionRate[commodityIdx] > 0 &&
              timeLeft > 0) {
            final available = state.stock[commodityIdx] ~/ timeLeft +
                state.productionRate[commodityIdx];
            if (available > maxRequired[commodityIdx]) {
              continue;
            }
          }
          final nextGen = SimState.fromState(state);
          nextGen.tick();
          build(commodityIdx, nextGen);
          if (state.time < debugTime) {
            devtools.log('Inserting ${nameLookup[commodityIdx]}');
            printState(nextGen);
          }
          simList.insert(0, nextGen);
        }
      }
    }

    return maxGeodes;
  }
}

class Day19P1 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 19 Part 1');

    const timeAllowed = 24;

    int totalQuality = 0;
    await for (final line in lines()) {
      final sim = Sim(timeAllowed, say);
      sim.loadBluePrint(line);

      sim.print();

      final geodes = sim.runSim();
      say('');
      say('BP: ${sim.bpNum} - $geodes geodes');
      say('');

      totalQuality += geodes * sim.bpNum;
    }

    say('The answer is $totalQuality');
  }
}

class Day19P2 extends Solution {
  @override
  Future<void> specificSolution(void Function(String) say) async {
    say('Day 19 Part 2');

    const timeAllowed = 32;

    int answer = 1;
    await for (final line in lines()) {
      final sim = Sim(timeAllowed, say);
      sim.loadBluePrint(line);

      sim.print();

      final geodes = sim.runSim();
      say('');
      say('BP: ${sim.bpNum} - $geodes geodes');
      say('');

      answer *= geodes;

      if (sim.bpNum == 3) {
        break;
      }
    }

    say('The answer is $answer');
  }
}


// 5 min left, current production 0
// base = 0
// (5 * 6) / 2 = 15
// max = 15
// actual ...
// 5: 0 + 1 = 1;
// 4: 1 + 1 = 2;
// 3: 2 + 1 = 3;
// 2: 3 + 1 = 4;
// 1: 4 + 1 = 5
// Total = 15!

// 5 min left, current production 5
// base = 25
// ( 5 * 6) / 2 = 15
// max = 40
// actual ...
// 5: 5 + 1 = 6;
// 4: 6 + 1 = 7;
// 3: 7 + 1 = 8;
// 2: 8 + 1 = 9;
// 1: 9 + 1 = 10
// Total = 40!

// 10 min left, current production 2
// base = 20
// 10 * 11 / 2 = 55
// max = 75
// actual ...
// 10: 2 + 1 = 3
//  9: 3 + 1 = 4
//  8: 4 + 1 = 5
//  7: 5 + 1 = 6
//  6: 6 + 1 = 7
//  5: 7 + 1 = 8
//  4: 8 + 1 = 9
//  3: 9 + 1 = 10
//  2: 10 + 1 = 11
//  1: 11 + 1 = 12
// Total = 5 * 15 = 75

// 10 min left, current production 0
// base = 0
// 10 * 11 / 2 = 55
// max = 55
// actual ...
// 10: 0 + 1 = 1
//  9: 1 + 1 = 2
//  8: 2 + 1 = 3
//  7: 3 + 1 = 4
//  6: 4 + 1 = 5
//  5: 5 + 1 = 6
//  4: 6 + 1 = 7
//  3: 7 + 1 = 8
//  2: 8 + 1 = 9
//  1: 9 + 1 = 10
// Total = 5 * 11 = 55