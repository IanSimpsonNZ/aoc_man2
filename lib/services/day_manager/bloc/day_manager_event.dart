import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class DayEvent {
  const DayEvent();
}

class DayInitialiseEvent extends DayEvent {
  const DayInitialiseEvent();
}

class DayChangeDayEvent extends DayEvent {
  final int newDay;
  const DayChangeDayEvent(this.newDay);
}

class DayChangePartEvent extends DayEvent {
  final int newPart;
  const DayChangePartEvent(this.newPart);
}

class DayChangeDirEvent extends DayEvent {
  final String? newDir;
  const DayChangeDirEvent(this.newDir);
}

class DayChangeFileEvent extends DayEvent {
  final FilePickerResult? newFile;
  const DayChangeFileEvent(this.newFile);
}

class DayChangeRootDirEvent extends DayEvent {
  final String? newRootDir;

  const DayChangeRootDirEvent(this.newRootDir);
}

class DayClearPrefsEvent extends DayEvent {
  const DayClearPrefsEvent();
}

class DayRunEvent extends DayEvent {
  final DayBloc dayEventHandler;
  const DayRunEvent(this.dayEventHandler);
}

class DayPauseEvent extends DayEvent {
  const DayPauseEvent();
}

class DayHaltEvent extends DayEvent {
  const DayHaltEvent();
}

class DaySendMessage extends DayEvent {
  final String message;

  const DaySendMessage({required this.message});
}

class DayClearOutputEvent extends DayEvent {
  const DayClearOutputEvent();
}

class DayShowStackTraceEvent extends DayEvent {
  final Error error;

  const DayShowStackTraceEvent({required this.error});
}
