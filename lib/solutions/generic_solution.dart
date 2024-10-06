import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:developer' as devtools show log;

import 'dart:isolate';

class Solution {
  String? _inputFile;

  void init(String fileName) async {
    devtools.log('Starting init');
    _inputFile = fileName;
  }

  Stream<String> lines() => utf8.decoder
      .bind(File(_inputFile!).openRead())
      .transform(const LineSplitter());

  void say(String message, SendPort sendPort) {
    sendPort.send(message);
  }

  Future<void> solution(SendPort sendPort) async {
    say("Generic Solution", sendPort);
    await for (final line in lines()) {
      await Future.delayed(const Duration(seconds: 1));
      say(line, sendPort);
    }
  }
}
