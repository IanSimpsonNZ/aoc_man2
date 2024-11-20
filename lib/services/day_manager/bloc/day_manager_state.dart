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
  final bool isPaused;
  final List<String> messages;
  final List<String> errorMessages;
  final Exception? exception;

  const DayReady(
    this.exception, {
    required this.dayNum,
    required this.partNum,
    required this.dirName,
    required this.fileName,
    required this.rootDir,
    required this.isRunning,
    required this.isPaused,
    required this.messages,
    required this.errorMessages,
  });
}
