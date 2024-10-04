import 'dart:convert';
import 'dart:io';

import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';

class Solution {
  String? _inputFile;
  DayBloc? _dayEventHandler;

  Stream<String> lines() => utf8.decoder
      .bind(File(_inputFile!).openRead())
      .transform(const LineSplitter());

  void say(String message) {
    _dayEventHandler!.add(DaySendMessage(message: message));
  }

  Future<int> run(String inputFile, DayBloc dayEventHandler) async {
    _inputFile = inputFile;
    _dayEventHandler = dayEventHandler;
    assert(_inputFile != null && _dayEventHandler != null);
    return await solution();
  }

  Future<int> solution() async {
    say("Generic Solution");
    await for (final line in lines()) {
      say(line);
    }
    return 0;
  }
}
