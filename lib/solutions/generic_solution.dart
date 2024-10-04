import 'dart:convert';
import 'dart:io';
import 'dart:developer' as devtools show log;

class Solution {
  final String? inputFile;

  Solution({
    this.inputFile,
  });

  Stream<String> lines(path) =>
      utf8.decoder.bind(File(path).openRead()).transform(const LineSplitter());

  void say(String message) {}

  Future<int> run() async {
    devtools.log("Generic Solution");
    if (inputFile == null) {
      devtools.log('No input file');
      return 0;
    }
    await for (final line in lines(inputFile)) {
      devtools.log(line);
    }
    return 0;
  }
}
