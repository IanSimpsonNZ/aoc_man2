import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'dart:developer' as devtools show log;

// import 'dart:developer' as devtools show log;
import 'dart:isolate';

// import 'dart:isolate';

// import 'package:aoc_manager/solutions/solution_args.dart';

class Solution {
  String? _inputFile;
  // Isolate? solutionIsolate;
  //Capability? _paused;
  //StreamController<String?>? solutionStreamController;
  // ReceivePort? receivePort = ReceivePort();
  //SendPort? _sendPort;

  // Solution() {
  //   // final sendPort = receivePort.sendPort;

  //   void start() async {
  //     if (solutionIsolate != null) {
  //       devtools.log('Trying to start isolate twice?');
  //     } else if (_inputFile == null) {
  //       devtools.log('Trying to run solution with no data file');
  //     } else {
  //       solutionIsolate = await Isolate.spawn(solution, sendPort);
  //       solutionIsolate!.addOnExitListener(sendPort, response: null);
  //     }
  //   }

  //   void pause() {
  //     if (solutionIsolate == null) {
  //       devtools.log("Trying to pause isolate when it hasn't been created");
  //     } else if (_paused != null) {
  //       devtools.log('Trying to pause when we are already paused?');
  //     } else {
  //       devtools.log('Pausing the isolate');
  //       _paused = solutionIsolate!.pause();
  //     }
  //   }

  //   void resume() {
  //     if (solutionIsolate == null) {
  //       devtools.log("Trying to resume isolate when it hasn't been created");
  //     } else if (_paused == null) {
  //       devtools.log("Trying to resume when we aren't paused?");
  //     } else {
  //       devtools.log('Resuming the isolate');
  //       solutionIsolate!.pause(_paused);
  //       _paused = null;
  //     }
  //   }

  //   void cancel() {
  //     if (solutionIsolate == null) {
  //       devtools.log('Trying to halt non-existent islate?');
  //     } else {
  //       solutionIsolate!.kill();
  //     }
  //   }

  //   solutionStreamController = StreamController<String?>(
  //     onListen: () => start,
  //     onPause: () => pause,
  //     onResume: () => resume,
  //     onCancel: () => cancel,
  //   );

  //   solutionStreamController!.addStream(receivePort as Stream<String?>);
  // }

  void init(String fileName) async {
    devtools.log('Starting init');
    _inputFile = fileName;
    //_sendPort = receivePort.sendPort;
    // receivePort = ReceivePort();
    // devtools.log('got ReceivePort - is of type ${receivePort!.runtimeType}');
    // devtools.log('sendPort is of type ${receivePort!.sendPort.runtimeType}');
    // // solutionIsolate = await Isolate.spawn(solution, receivePort!.sendPort);
    // devtools.log('Finished init');
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

  // Stream<String?> solution(StreamController<String?> controller) async* {
  //   controller.add("Generic Solution");
  //   await for (final line in lines()) {
  //     await Future.delayed(const Duration(seconds: 1));
  //     controller.add(line);
  //   }
  // }
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
