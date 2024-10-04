import 'dart:convert';
import 'dart:io';

import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';

class Solution {
  Stream<String> lines(path) =>
      utf8.decoder.bind(File(path).openRead()).transform(const LineSplitter());

  void say(String message, DayBloc dayEventHandler) {
    dayEventHandler.add(DaySendMessage(message: message));
  }

  Future<int> run(String inputFile, DayBloc dayEventHandler) async {
    say("Generic Solution", dayEventHandler);
    await for (final line in lines(inputFile)) {
      say(line, dayEventHandler);
    }
    return 0;
  }
}
