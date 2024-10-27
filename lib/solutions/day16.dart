// import 'dart:convert';
// import 'dart:io';
import 'dart:math' show max;
// import "package:async/async.dart" show StreamQueue;

import 'package:aoc_manager/solutions/generic_solution.dart';
// import 'package:aoc_manager/solutions/helpers/coord.dart';

import 'dart:developer' as devtools show log;

class Valve {
  final int id;
  final String name;
  final int flowRate;
  final List<String> connections;

  const Valve(
      {required this.id,
      required this.name,
      required this.flowRate,
      required this.connections});

  String print() {
    return '$id: Valve $name has flow rate=$flowRate; tunnels lead to valves $connections';
  }
}

class ValveMap {
  Map<String, Valve> valves = {};
  Map<String, int> minDist = {};
  int counter = 0;
  int flowAvailable = 0;
  void Function(String) say;
  int maxFlow = 0;

  ValveMap(this.say);

  Future<void> getMap(Stream<String> lines) async {
    const namePos = 1;
    const flowPos = 4;
    const connStart = 9;
    for (final (id, line)
        in (await lines.where((l) => l.isNotEmpty).toList()).indexed) {
      final words = line.split(' ');
      final name = words[namePos];
      final flowStr =
          words[flowPos].replaceFirst('rate=', '').replaceAll(';', '');
      final flowRate = int.parse(flowStr);
      List<String> connections = [];
      for (int i = connStart; i < words.length; i++) {
        connections.add(words[i].replaceAll(',', ''));
      }
      valves[name] = Valve(
          id: id, name: name, flowRate: flowRate, connections: connections);
    }
  }

  String minDistKey(String v1Name, String v2Name) {
    assert(v1Name != v2Name);
    if (v1Name.compareTo(v2Name) < 0) {
      return '$v1Name$v2Name';
    }
    return '$v2Name$v1Name';
  }

  int? getDist3(String fromName, String toName) {
    final existingDist = minDist[minDistKey(fromName, toName)];
    if (existingDist != null) {
      return existingDist;
    }

    int numSteps = 1;
    Set<String> border = {toName};
    Set<String> nextBorder = {};
    while (border.isNotEmpty) {
      for (final thisValve in border) {
        for (final nextValve in valves[thisValve]!.connections) {
          if (nextValve == fromName) {
            return numSteps;
          }
          nextBorder.add(nextValve);
        }
      }
      numSteps++;
      border = nextBorder;
      nextBorder = {};
    }
    return null;
  }

  void calcMinDist() {
    for (final fromValve in valves.values) {
      for (final toValve
          in valves.values.where((v) => v.name != fromValve.name)) {
        int? thisDist = getDist3(fromValve.name, toValve.name);
        if (thisDist != null) {
          minDist[minDistKey(fromValve.name, toValve.name)] = thisDist;
        }
      }
    }
  }

  void printMinDist() {
    for (final fromValve in valves.values) {
      for (final toValve
          in valves.values.where((v) => v.name != fromValve.name)) {
        final key = minDistKey(fromValve.name, toValve.name);
        devtools.log('${fromValve.name} to ${toValve.name} = ${minDist[key]}');
      }
    }
  }

  int calcFlow(String startValveName, int clock, List<Valve> path) {
    int flow = 0;
    int cumulativeFlow = 0;
    var fromName = startValveName;
    for (final valve in path) {
      if (clock < 1) break;
      final timeTaken = minDist[minDistKey(fromName, valve.name)]!;
      final newClock = clock - timeTaken;
      if (newClock < 0) {
        cumulativeFlow += flow * clock;
        clock = 0;
        break;
      } else {
        cumulativeFlow += flow * timeTaken;
        clock = newClock;
      }
      clock--;
      cumulativeFlow += flow;
      flow += valve.flowRate;
      fromName = valve.name;
    }
    if (clock > 0) {
      cumulativeFlow += flow * clock;
    }
    return cumulativeFlow;
  }

  int factorial(int x) {
    int result = 1;
    for (int i = 2; i <= x; i++) {
      result *= i;
    }
    return result;
  }

  int calcMaxFlow(
      {required String startValveName,
      required int clock,
      required List<Valve> futureValves,
      required int flowRemaining,
      required int currentMax,
      required int flowSoFar,
      required int currentFlowRate,
      required String pathStr}) {
    counter++;

    if (clock < 1) {
      return max(flowSoFar, currentMax);
    }

    if (futureValves.isEmpty) {
      return max(flowSoFar + (clock * currentFlowRate), currentMax);
    }

    maxFlow = currentMax;

    assert(currentFlowRate + flowRemaining == flowAvailable);

    int maxFutureFlow = clock * currentFlowRate;
    if (clock > 2) {
      maxFutureFlow += (clock - 2) * flowRemaining;
    }

    if (flowSoFar + maxFutureFlow > currentMax) {
      for (final nextValve in futureValves) {
        final timeTaken = minDist[minDistKey(startValveName, nextValve.name)]!;
        final newClock = clock - timeTaken;
        int thisCumulativeFlow = flowSoFar;
        int thisClock = clock;

        if (newClock < 0) {
          thisCumulativeFlow += currentFlowRate * clock;
          thisClock = 0;
          counter++;
        } else {
          // Flow while we get there
          thisCumulativeFlow += currentFlowRate * timeTaken;
          thisClock = newClock;

          if (thisClock > 0) {
            // Take a minute to turn on the valve
            thisClock--;
            thisCumulativeFlow += currentFlowRate;

            final newFlowRate = currentFlowRate + nextValve.flowRate;
            final newFlowRemaining = flowRemaining - nextValve.flowRate;
            assert(newFlowRemaining >= 0);
            final newPathStr =
                '$pathStr ${nextValve.name}:c$thisClock:f$newFlowRate';
            final nextList =
                futureValves.where((v) => v.name != nextValve.name).toList();
            assert(futureValves.length - nextList.length == 1);
            thisCumulativeFlow = calcMaxFlow(
              startValveName: nextValve.name,
              clock: thisClock,
              futureValves: nextList,
              flowRemaining: newFlowRemaining,
              currentMax: maxFlow,
              flowSoFar: thisCumulativeFlow,
              currentFlowRate: newFlowRate,
              pathStr: newPathStr,
            );
          }
        }

        if (thisCumulativeFlow > maxFlow) {
          maxFlow = thisCumulativeFlow;
        }
      }
    } else {
      counter += factorial(futureValves.length);
    }

    return maxFlow;
  }
}

class Day16P1 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 16 Part 1');

    var map = ValveMap(say);
    await map.getMap(lines());

    say('Calculating minimum distances');
    map.calcMinDist();

    final valvesWithPressure =
        map.valves.values.where((v) => v.flowRate > 0).toList();
    say('${valvesWithPressure.map((v) => v.name)} have pressure');

    valvesWithPressure.sort((a, b) => b.flowRate - a.flowRate);
    say('Sorted values => ${valvesWithPressure.map((v) => v.name)}');

    final firstGuess = map.calcFlow('AA', 30, valvesWithPressure);
    say('First guess at max flow is $firstGuess');

    map.counter = 0;
    map.flowAvailable =
        valvesWithPressure.fold<int>(0, (acc, v) => acc += v.flowRate);
    say('Flow available is ${map.flowAvailable}');
    say('Total permutations is ${map.factorial(valvesWithPressure.length)}');

    say('Max flow is ${map.calcMaxFlow(
      startValveName: 'AA',
      clock: 30,
      futureValves: valvesWithPressure,
      flowRemaining: map.flowAvailable,
      currentMax: firstGuess,
      flowSoFar: 0,
      currentFlowRate: 0,
      pathStr: 'AA',
    )}');

    say('Tried ${map.counter} permuations');
  }
}

class Trip {
  int currentFlow;
  int cumulativeFlow;
  int flowRemaining;
  Valve? myTarget;
  int myTimeToTarget;
  Valve? eTarget;
  int eTimeToTarget;
  List<Valve> availableTargets;

  Trip({
    required this.myTarget,
    required this.myTimeToTarget,
    required this.eTarget,
    required this.eTimeToTarget,
    required this.availableTargets,
    required this.flowRemaining,
    required this.currentFlow,
    required this.cumulativeFlow,
  });

  Trip clone() => Trip(
        currentFlow: currentFlow,
        cumulativeFlow: cumulativeFlow,
        myTarget: myTarget,
        myTimeToTarget: myTimeToTarget,
        eTarget: eTarget,
        eTimeToTarget: eTimeToTarget,
        availableTargets: [],
        flowRemaining: flowRemaining,
      );

  int optiMax(int clock) {
    int estimate = cumulativeFlow + currentFlow * clock;

    int cMe = 0;
    int cE = 0;
    if (myTarget != null) {
      cMe = max(clock - (myTimeToTarget + 1), 0);
      estimate += cMe * myTarget!.flowRate;
    }
    if (eTarget != null) {
      cE = max(clock - (eTimeToTarget + 1), 0);
      estimate += cE * eTarget!.flowRate;
    }

    clock = max(cMe, cE) - 2;
    if (clock < 1) return estimate;

    int availableFlow = 0;
    for (final valve in availableTargets) {
      availableFlow += valve.flowRate;
      estimate += valve.flowRate * clock;
      clock -= 2;
      if (clock < 1) break;
    }

    if (clock < 1) return estimate;

    estimate += availableFlow * clock;
    return estimate;
  }
}

int dualMaxFlow(
  Trip trip,
  int clock,
  int currentMax,
  ValveMap map,
  void Function(String) say,
) {
  if (clock == 0) return max(trip.cumulativeFlow, currentMax);

  int maxFlow = currentMax;

  if (trip.myTarget != null) trip.myTimeToTarget--;
  assert(trip.myTimeToTarget >= -1);
  if (trip.eTarget != null) trip.eTimeToTarget--;
  assert(trip.eTimeToTarget >= -1);

  trip.cumulativeFlow += trip.currentFlow;

  if (trip.myTarget != null && trip.myTimeToTarget == -1) {
    trip.currentFlow += trip.myTarget!.flowRate;
    trip.flowRemaining -= trip.myTarget!.flowRate;
    assert(trip.flowRemaining >= 0);
  }
  if (trip.eTarget != null && trip.eTimeToTarget == -1) {
    trip.currentFlow += trip.eTarget!.flowRate;
    trip.flowRemaining -= trip.eTarget!.flowRate;
    assert(trip.flowRemaining >= 0);
  }

  if (trip.availableTargets.isEmpty) {
    if (trip.myTimeToTarget == -1) trip.myTarget = null;
    if (trip.eTimeToTarget == -1) trip.eTarget = null;
    // If we have finished moving, check for new maximum flow
    if (trip.myTarget == null && trip.eTarget == null) {
      // The "(clock - 1)" fixed the issue with the example data failing,
      // but real data working.
      // Just deal with it ...
      final thisFlow = trip.cumulativeFlow + trip.currentFlow * (clock - 1);
      if (thisFlow > maxFlow) {
        say('New max flow $thisFlow vs $maxFlow');
        return thisFlow;
      } else {
        return maxFlow;
      }
    } else {
      return dualMaxFlow(trip, clock - 1, maxFlow, map, say);
    }
  } else if (trip.myTimeToTarget > -1 && trip.eTimeToTarget > -1) {
    if (trip.optiMax(clock) > maxFlow) {
      return dualMaxFlow(trip, clock - 1, maxFlow, map, say);
    } else {
      return maxFlow;
    }
  } else if (trip.myTimeToTarget == -1 && trip.eTimeToTarget > -1) {
    // Elephant still going, we're stopped
    for (final myNextTarget in trip.availableTargets) {
      final newTrip = trip.clone();
      newTrip.myTarget = myNextTarget;
      newTrip.myTimeToTarget =
          map.minDist[map.minDistKey(trip.myTarget!.name, myNextTarget.name)]!;
      final nextAvailableTargets = trip.availableTargets
          .where((v) => v.name != myNextTarget.name)
          .toList();
      newTrip.availableTargets = nextAvailableTargets;
      if (newTrip.optiMax(clock) > maxFlow) {
        maxFlow = dualMaxFlow(newTrip, clock - 1, maxFlow, map, say);
      }
    }
  } else if (trip.myTimeToTarget > -1 && trip.eTimeToTarget == -1) {
    // We're still going, elephant stopped
    for (final eNextTarget in trip.availableTargets) {
      final newTrip = trip.clone();
      newTrip.eTarget = eNextTarget;
      newTrip.eTimeToTarget =
          map.minDist[map.minDistKey(trip.eTarget!.name, eNextTarget.name)]!;
      final nextAvailableTargets = trip.availableTargets
          .where((v) => v.name != eNextTarget.name)
          .toList();
      newTrip.availableTargets = nextAvailableTargets;
      if (newTrip.optiMax(clock) > maxFlow) {
        maxFlow = dualMaxFlow(newTrip, clock - 1, maxFlow, map, say);
      }
    }
  } else {
    // We're both stopped
    for (final myNextTarget in trip.availableTargets) {
      final availableETargets = trip.availableTargets
          .where((v) => v.name != myNextTarget.name)
          .toList();
      for (final eNextTarget in availableETargets) {
        final newTrip = trip.clone();
        newTrip.myTarget = myNextTarget;
        newTrip.myTimeToTarget = map
            .minDist[map.minDistKey(trip.myTarget!.name, myNextTarget.name)]!;
        newTrip.eTarget = eNextTarget;
        newTrip.eTimeToTarget =
            map.minDist[map.minDistKey(trip.eTarget!.name, eNextTarget.name)]!;
        final nextAvailableTargets =
            availableETargets.where((v) => v.name != eNextTarget.name).toList();
        newTrip.availableTargets = nextAvailableTargets;
        if (newTrip.optiMax(clock) > maxFlow) {
          maxFlow = dualMaxFlow(newTrip, clock - 1, maxFlow, map, say);
        }
      }
    }
  }
  return maxFlow;
}

class Day16P2 extends Solution {
  @override
  Future<void> specificSolution() async {
    say('Day 16 Part 2');

    var map = ValveMap(say);
    await map.getMap(lines());

    say('Calculating minimum distances');
    map.calcMinDist();

    final valvesWithPressure =
        map.valves.values.where((v) => v.flowRate > 0).toList();
    say('${valvesWithPressure.map((v) => v.name)} have pressure');

    valvesWithPressure.sort((a, b) => b.flowRate - a.flowRate);
    say('Sorted values => ${valvesWithPressure.map((v) => v.name)}');

    final firstGuess = map.calcFlow('AA', 30, valvesWithPressure);
    say('First guess at max flow is $firstGuess');

    map.counter = 0;
    map.flowAvailable =
        valvesWithPressure.fold<int>(0, (acc, v) => acc += v.flowRate);
    say('Flow available is ${map.flowAvailable}');
    say('Total permutations is ${map.factorial(valvesWithPressure.length)}');

    final singleMax = map.calcMaxFlow(
      startValveName: 'AA',
      clock: 30,
      futureValves: valvesWithPressure,
      flowRemaining: map.flowAvailable,
      currentMax: firstGuess,
      flowSoFar: 0,
      currentFlowRate: 0,
      pathStr: 'AA',
    );

    say('Single max = $singleMax');

    // A bit of hacking to bootstrap dualMaxFlow.
    // Set both me and Elephant to be sitting at AA
    // and allow an extra minute to open valve AA
    // (even though it has zero pressure)

    final startValve = map.valves['AA']!;
    const clock = 26;

    // Set up the possible combination of first steps
    final initialTrip = Trip(
        myTarget: startValve,
        myTimeToTarget: 0,
        eTarget: startValve,
        eTimeToTarget: 0,
        flowRemaining:
            valvesWithPressure.fold<int>(0, (acc, v) => acc += v.flowRate),
        availableTargets: valvesWithPressure,
        cumulativeFlow: 0,
        currentFlow: 0);

    final dualMax = dualMaxFlow(initialTrip, clock + 1, 0, map, say);

    say('The answer is $dualMax');
  }
}
