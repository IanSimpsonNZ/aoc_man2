import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:isolate';

//import 'dart:developer' as devtools show log;

class Solution {
  String? _inputFile;
  SendPort? sendPort;

  get inputFile => _inputFile;

  void init(String fileName) async {
    _inputFile = fileName;
  }

  Stream<String> lines() => utf8.decoder
      .bind(File(_inputFile!).openRead())
      .transform(const LineSplitter());

  void say(String message) {
    assert(sendPort != null);
    sendPort?.send(message);
  }

  Future<void> solution(SendPort newSendPort) async {
    sendPort = newSendPort;

    try {
      await specificSolution(say);
      say('Done');
    } catch (e) {
      final err = e as Error;
      sendPort?.send(RemoteError(err.toString(), err.stackTrace.toString()));
    }
  }

  Future<void> specificSolution(void Function(String) say) async {
    say("Generic Solution");
    await for (final line in lines()) {
      await Future.delayed(const Duration(seconds: 1));
      say(line);
    }
  }
}
