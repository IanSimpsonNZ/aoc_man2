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

  const DayReady({
    required this.dayNum,
    required this.partNum,
    required this.dirName,
    required this.fileName,
  });
}

// class DayUpdateDayPanel extends DayState {
//   final int dayNum;
//   final int partNum;

//   const DayUpdateDayPanel({
//     required this.dayNum,
//     required this.partNum,
//   });
// }

// class DayUpdateFilePanel extends DayState {
//   final String dirName;
//   final String fileName;

//   const DayUpdateFilePanel({
//     required this.dirName,
//     required this.fileName,
//   });
// }
