import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:isolate';

class Solution {
  String? _inputFile;
  SendPort? sendPort;

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

    say("Generic Solution");
    await for (final line in lines()) {
      await Future.delayed(const Duration(seconds: 1));
      say(line);
    }
  }
}
