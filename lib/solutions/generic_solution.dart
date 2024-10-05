import 'dart:convert';
import 'dart:io';
// import 'dart:isolate';

// import 'package:aoc_manager/solutions/solution_args.dart';

class Solution {
  String? _inputFile;

  Stream<String> lines() => utf8.decoder
      .bind(File(_inputFile!).openRead())
      .transform(const LineSplitter());

  Stream<String?> run(String fileName) async* {
    _inputFile = fileName;
    assert(_inputFile != null);
    await for (final message in solution()) {
      yield message;
    }
    yield null;
  }

  Stream<String> solution() async* {
    yield "Generic Solution";
    await for (final line in lines()) {
      await Future.delayed(const Duration(seconds: 1));
      yield line;
    }
  }
}


// class Solution {
//   String? _inputFile;
//   SendPort? _sendPort;
//   //DayBloc? _dayEventHandler;

//   Stream<String> lines() => utf8.decoder
//       .bind(File(_inputFile!).openRead())
//       .transform(const LineSplitter());

//   void say(String message) {
//     _sendPort!.send(message);
//     //_dayEventHandler!.add(DaySendMessage(message: message));
//   }

//   void exitSolution() {
//     _sendPort!.send(null);
//   }

//   Future<void> run(SolutionArgs args) async {
//     _sendPort = args.sendPort;
//     _inputFile = args.fileName;
//     //_dayEventHandler = dayEventHandler;
//     assert(_inputFile != null && /*_dayEventHandler*/ _sendPort != null);
//     say('The answer is ${await solution()}');
//     //exitSolution();
//   }

//   Future<int> solution() async {
//     say("Generic Solution");
//     await for (final line in lines()) {
//       await Future.delayed(const Duration(seconds: 1));
//       say(line);
//     }
//     return 0;
//   }
// }
