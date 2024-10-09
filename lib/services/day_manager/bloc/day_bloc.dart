import 'dart:isolate';

import 'package:aoc_manager/constants/day_constants.dart';
import 'package:aoc_manager/constants/pref_constants.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:aoc_manager/services/day_manager/day_manager_exceptions.dart';
import 'package:aoc_manager/solutions/day01.dart';
import 'package:aoc_manager/solutions/day02.dart';
import 'package:aoc_manager/solutions/day03.dart';
import 'package:aoc_manager/solutions/day04.dart';
import 'package:aoc_manager/solutions/day05.dart';
import 'package:aoc_manager/solutions/day06.dart';
import 'package:aoc_manager/solutions/day07.dart';
import 'package:aoc_manager/solutions/day25.dart';
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

  final List<List<Solution>> _solutions = [
    [Day01P1(), Day01P2()], // 1
    [Day02P1(), Day02P2()], // 2
    [Day03P1(), Day03P2()], // 3
    [Day04P1(), Day04P2()], // 4
    [Day05P1(), Day05P2()], // 5
    [Day06P1(), Day06P2()], // 6
    [Day07P1(), Day07P2()], // 7
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
    [Day25P1(), Day25P2()], // 25
  ];

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

  // void _addMessage(String newMessage) {
  //   if (_messages.isEmpty) {
  //     _messages.add(newMessage);
  //   } else {
  //     _messages.last = '${_messages.last}$newMessage';
  //   }
  // }

  // Display stuff on the output panel
  void _disp(String newMessage, {Emitter? emit, bool ensureNewLine = false}) {
    if (_messages.isEmpty) {
      _messages.add(newMessage);
    } else {
      if (ensureNewLine && _messages.last != '') {
        _messages.add('');
      }
      _messages.last = '${_messages.last}$newMessage';
    }
    if (emit != null) emit(_newDayData());
  }

  void _dispLn(String newMessage, {Emitter? emit, bool ensureNewLine = false}) {
    _disp(newMessage, ensureNewLine: ensureNewLine);
    _messages.add('');
    if (emit != null) emit(_newDayData());
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
            _dispLn('');
            _dispLn('Running solution for day $_dayNum, part $_partNum');
            _dispLn('Using : $file', emit: emit);
            //emit(_newDayData());

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
                if (message is String) {
                  _messages.add(message);
                } else if (message == null) {
                  _isRunning = false;
                  _dispLn('Process finished', ensureNewLine: true);
                  //_messages.add('Process finished');
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
            _solutionTask!.resume(_pausedCapability!);
            _pausedCapability = null;
          } else {
            _pausedCapability = _solutionTask!.pause();
          }
          _isPaused = !_isPaused;
          emit(_newDayData());
        }
      },
    );

    // Halt the solutiion
    on<DayHaltEvent>(
      (event, emit) async {
        if (_isRunning) {
          if (_isPaused) {
            _solutionTask!.resume(_pausedCapability!);
            _isPaused = false;
            _pausedCapability = null;
          }
          _dispLn('Requesting process halt ...',
              emit: emit, ensureNewLine: true);
          //emit(_newDayData());
          _solutionTask!.kill(priority: Isolate.beforeNextEvent);
          await Future.delayed(const Duration(seconds: 1));

          for (int i = 3; i > 0; i--) {
            if (!_isRunning) break;
            _disp('$i ... ', emit: emit);
            await Future.delayed(const Duration(seconds: 1));
            //emit(_newDayData());
          }
          if (_isRunning) {
            // _isRunning will be set to false by the isolate OnExitListener if the halt request worked
            //_messages.add('');
            _dispLn('Halt request ignored - issuing kill request ...',
                emit: emit, ensureNewLine: true);
            //emit(_newDayData());
            _solutionTask!.kill(priority: Isolate.immediate);
          }
          //_isRunning = false;
          //emit(_newDayData());
        }
      },
    );

    // Messages to output panel
    on<DaySendMessage>(
      (event, emit) {
        _dispLn(event.message, emit: emit);
        //emit(_newDayData());
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
