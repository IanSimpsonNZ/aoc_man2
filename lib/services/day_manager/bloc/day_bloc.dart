// import 'dart:isolate';

import 'dart:isolate';

import 'package:aoc_manager/constants/day_constants.dart';
import 'package:aoc_manager/constants/pref_constants.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:aoc_manager/services/day_manager/day_manager_exceptions.dart';
import 'package:aoc_manager/solutions/day01.dart';
import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' show join;
import 'dart:developer' as devtools show log;

class DayBloc extends Bloc<DayEvent, DayState> {
  final _prefs = SharedPreferencesAsync();
  String? _rootDir;
  int _dayNum = minDay;
  int _partNum = 1;
  String? _dirName;
  String? _fileName;
  bool _isRunning = false;
  bool _isPaused = false;

  final List<String> _messages = [];

  Solution? _solution;
  Capability? _pausedCapability;
  Isolate? _solutionTask;

  final _solutions = [
    [Day01P1(), Day01P2()], // 1
    [Solution(), Solution()], // 2
    [Solution(), Solution()], // 3
    [Solution(), Solution()], // 4
    [Solution(), Solution()], // 5
    [Solution(), Solution()], // 6
    [Solution(), Solution()], // 7
    [Solution(), Solution()], // 8
    [Solution(), Solution()], // 9
    [Solution(), Solution()], // 10
    [Solution(), Solution()], // 11
    [Solution(), Solution()], // 12
    [Solution(), Solution()], // 13
    [Solution(), Solution()], // 14
    [Solution(), Solution()], // 15
    [Solution(), Solution()], // 16
    [Solution(), Solution()], // 17
    [Solution(), Solution()], // 18
    [Solution(), Solution()], // 19
    [Solution(), Solution()], // 20
    [Solution(), Solution()], // 21
    [Solution(), Solution()], // 22
    [Solution(), Solution()], // 23
    [Solution(), Solution()], // 24
    [Solution(), Solution()], // 25
  ];

  // String? get rootDir => _rootDir;
  // int get dayNum => _dayNum;
  // int get partNum => _partNum;
  // String get dirName => _dirName ?? (_rootDir ?? '');
  // String get fileName => _fileName ?? '';
  // bool get isRunning => _isRunning;

  String _dayPartKey() => '${appNamePrefKey}_${_dayNum}_part';
  String _dayDirKey() => '${appNamePrefKey}_${_dayNum}_dir';
  String _dayFileKey() => '${appNamePrefKey}_${_dayNum}_${_partNum}_file';

  Future<void> _getPrefsForDay() async {
    _partNum = await _prefs.getInt(_dayPartKey()) ?? 1;
    _dirName = await _prefs.getString(_dayDirKey());
    _fileName = await _prefs.getString(_dayFileKey());
  }

  DayReady _newDayData({Exception? exception}) => DayReady(
        dayNum: _dayNum,
        partNum: _partNum,
        dirName: _dirName ?? (_rootDir ?? ''),
        fileName: _fileName ?? '',
        rootDir: _rootDir ?? '',
        isRunning: _isRunning,
        isPaused: _isPaused,
        messages: _messages,
        exception,
        // message,
        // clearOutput,
      );

  Future<void> _initPrefs() async {
    final currentDay = await _prefs.getInt(dayNumPrefKey);
    if (currentDay == null) {
      await _prefs.setInt(dayNumPrefKey, minDay);
      _dayNum = minDay;
    } else {
      _dayNum = currentDay;
    }
    for (var day = minDay; day <= maxDay; day++) {
      final partKey =
          '${appNamePrefKey}_${day}_part'; // NB uses "day" from loop, not _dayNum so don't use func
      final currentPart = await _prefs.getInt(partKey);
      if (currentPart == null) _prefs.setInt(partKey, 1);
    }

    // Load initial prefs
    _rootDir = await _prefs.getString(rootDirPrefKey);
    // Already have _dayNum from above
    await _getPrefsForDay();
  }

  DayBloc() : super(const DayUninitialised()) {
    // Initiate - get previous settings, or create them if first run
    on<DayInitialiseEvent>((event, emit) async {
      emit(const DayWorking());
      await _initPrefs();
      // Set up basic prefs if required
      emit(_newDayData());
    });

    // Update Day
    on<DayChangeDayEvent>(
      (event, emit) async {
        if (!_isRunning) {
          emit(const DayWorking());
          _dayNum = event.newDay;
          assert(_dayNum >= minDay && _dayNum <= maxDay);
          await _prefs.setInt(dayNumPrefKey, event.newDay);
          await _getPrefsForDay();
          emit(_newDayData());
        }
      },
    );

    // Update Part
    on<DayChangePartEvent>(
      (event, emit) async {
        if (!_isRunning) {
          emit(const DayWorking());
          _partNum = event.newPart;
          assert(_partNum == 1 || _partNum == 2);
          await _prefs.setInt(_dayPartKey(), event.newPart);
          await _getPrefsForDay();
          emit(_newDayData());
        }
      },
    );

    // Update Dir
    on<DayChangeDirEvent>(
      (event, emit) async {
        if (!_isRunning) {
          // Did we select a new directory?
          if (event.newDir != null) {
            emit(const DayWorking());
            // If it's a new drectory, clear the file selection
            if (event.newDir != _dirName) {
              await _prefs.remove(_dayFileKey());
              final tmp = _partNum;
              _partNum = (_partNum % 2) + 1;
              await _prefs.remove(_dayFileKey());
              _partNum = tmp;
              _fileName = null;
            }
            // and save the directory
            await _prefs.setString(_dayDirKey(), event.newDir!);
            _dirName = event.newDir;

            emit(_newDayData());
          }
        }
      },
    );

    // Update file
    on<DayChangeFileEvent>(
      (event, emit) async {
        if (!_isRunning) {
          // Did we select a new file?
          if (event.newFile != null) {
            assert(event.newFile!.count > 0);
            emit(const DayWorking());
            final fileName = event.newFile!.names.first;
            final pathName =
                event.newFile!.paths.first?.replaceAll('\\$fileName', '');
            // Update the path if they navigated away from default
            if (fileName != null) {
              await _prefs.setString(_dayFileKey(), fileName);
              _fileName = fileName;
              await _prefs.setString(_dayDirKey(), pathName!);
              _dirName = pathName;
            }
            emit(_newDayData());
          }
        }
      },
    );

    // Change root dir
    on<DayChangeRootDirEvent>(
      (event, emit) async {
        devtools.log((await _prefs.getAll()).toString());
        if (event.newRootDir != null) {
          _rootDir = event.newRootDir;
          await _prefs.setString(rootDirPrefKey, event.newRootDir!);
        }
      },
    );

    // Clear Preferences
    on<DayClearPrefsEvent>(
      (event, emit) async {
        emit(const DayWorking());
        await _prefs.clear();
        await _initPrefs(); // This sets _dayNum
        _rootDir = await _prefs.getString(rootDirPrefKey);
        await _getPrefsForDay();
        emit(_newDayData());
      },
    );

// Run the selected solution
    on<DayRunEvent>(
      (event, emit) async {
        if (!_isRunning) {
          if (_fileName != null && _fileName != '') {
            _isRunning = true;
            final file = join(_dirName!, _fileName!);
            _messages.add('Running solution for day $_dayNum, part $_partNum');
            _messages.add('Using : $file');
            emit(_newDayData());

            // Solution is a Streamcontroller
            // solution onListen kicks off the task as an isolate
            // Assigns the receiveport to the Streamcontrollers stream using addStream!!!!
            // Then this should work!
            // Keep Solution as a class member and use pause, resume (results in bufferring)
            // onCancel executes isolate.kill!!

            _solution = _solutions[_dayNum - 1][_partNum - 1];
            _solution!.init(file);
            final initPort = RawReceivePort();
            _solutionTask =
                await Isolate.spawn(_solution!.solution, initPort.sendPort);
            _solutionTask!.addOnExitListener(initPort.sendPort, response: null);
            final receivePort = ReceivePort.fromRawReceivePort(initPort);
            await emit.forEach(
              receivePort,
              onData: (message) {
                devtools.log('Got ... ${message.toString()}');
                if (message is String) {
                  _messages.add(message);
                } else if (message == null) {
                  _isRunning = false;
                  _messages.add('Process finished');
                }
                return _newDayData();
              },
            );
          } else {
            emit(_newDayData(exception: DayNoFileSelectedException()));
          }
        }
      },
    );

    // Toggle the pause mode
    on<DayPauseEvent>(
      (event, emit) {
        if (_isRunning) {
          if (_isPaused) {
            devtools.log('Un-pausing from DayBloc');
            _solutionTask!.resume(_pausedCapability!);
            _pausedCapability = null;
          } else {
            devtools.log('Pausing');
            _pausedCapability = _solutionTask!.pause();
          }
          _isPaused = !_isPaused;
          emit(_newDayData());
        }
      },
    );

    // Halt the solutiion
    on<DayHaltEvent>(
      (event, emit) {
        if (_isRunning) {
          if (_isPaused) {
            _solutionTask!.resume(_pausedCapability!);
            _isPaused = false;
            _pausedCapability = null;
          }
          _solutionTask!.kill();
          _isRunning = false;
          emit(_newDayData());
        }
      },
    );

    // Messages to output panel
    on<DaySendMessage>(
      (event, emit) {
        _messages.add(event.message);
        emit(_newDayData());
      },
    );

    // Clear output panel
    on<DayClearOutputEvent>(
      (event, emit) {
        _messages.clear();
        emit(_newDayData());
      },
    );
  }
}


// // Run the selected solution
//     on<DayRunEvent>(
//       (event, emit) async {
//         if (!_isRunning) {
//           if (_fileName != null && _fileName != '') {
//             _isRunning = true;
//             final file = join(_dirName!, _fileName!);
//             _messages.add('Running solution for day $_dayNum, part $_partNum');
//             // emit(_newDayData(
//             //     message: 'Running solution for day $_dayNum, part $_partNum'));
//             _messages.add('Using : $file');
//             emit(_newDayData());

//             final solution = _solutions[_dayNum - 1][_partNum - 1];
//             // solution.run(file, event.dayEventHandler);
//             final receivePort = ReceivePort();
//             receivePort.listen((dynamic message) {
//               print('Message is ${message.toString()}');
//               if (message is String) {
//                 print('It is a string');
//                 _messages.add(message);
//                 // emit(_newDayData());
//               } else if (message == null) {
//                 print('Closing down.  The buuffer is:');
//                 for (final line in _messages) {
//                   print(line);
//                 }
//                 _isRunning = false;
//                 // emit(_newDayData());
//               }
//             });
//             final isolate = await Isolate.spawn(solution.run,
//                 SolutionArgs(sendPort: receivePort.sendPort, fileName: file));
//             // await for (var message in receivePort) {
//             //   if (message == null) {
//             //     break;
//             //   }
//             //   if (message is String) {
//             //     _messages.add(message);
//             //     emit(_newDayData());
//             //   }
//             // }

//             // _isRunning = false;
//             // emit(_newDayData());
//           } else {
//             emit(_newDayData(exception: DayNoFileSelectedException()));
//           }
//         }
//       },
//     );