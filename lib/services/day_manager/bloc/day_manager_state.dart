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
  final String dataDirName;
  final String dataFileName;
  final String progDirName;
  final String progFileName;
  final String rootDir;
  final bool isRunning;
  final bool isPaused;
  final List<String> messages;
  final List<String> errorMessages;
  final Exception? exception;

  const DayReady(
    this.exception, {
    required this.dayNum,
    required this.partNum,
    required this.dataDirName,
    required this.dataFileName,
    required this.progDirName,
    required this.progFileName,
    required this.rootDir,
    required this.isRunning,
    required this.isPaused,
    required this.messages,
    required this.errorMessages,
  });
}
