import 'package:flutter/foundation.dart';

@immutable
abstract class DayState {
  const DayState();
}

class DayUninitialised extends DayState {
  const DayUninitialised();
}

class DayWorking extends DayState {
  const DayWorking();
}

class DayReady extends DayState {
  final int dayNum;
  final int partNum;
  final String dirName;
  final String fileName;
  final String rootDir;
  final bool isRunning;
  final List<String> messages;

  const DayReady(
      // this.newMessage,
      // If this is not null in output_panel add the message to the list.
      // on second thoughts, why can't the solution just update the singleton list directly
      // Then the ListView in output_panel just displays it? so both solution and output_panel
      // create an instance (the same instance as it's a singleton) of the output_list.
      // In which case I don't need this.
      {
    required this.dayNum,
    required this.partNum,
    required this.dirName,
    required this.fileName,
    required this.rootDir,
    required this.isRunning,
    required this.messages,
  });
}
