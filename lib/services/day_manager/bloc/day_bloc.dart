import 'dart:io';
import 'dart:convert';
// import 'dart:isolate';
import 'package:async/async.dart';

import 'package:aoc_manager/constants/day_constants.dart';
import 'package:aoc_manager/constants/pref_constants.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:aoc_manager/services/day_manager/day_manager_exceptions.dart';
// import 'package:aoc_manager/solutions/day01.dart';
// import 'package:aoc_manager/solutions/day02.dart';
// import 'package:aoc_manager/solutions/day03.dart';
// import 'package:aoc_manager/solutions/day04.dart';
// import 'package:aoc_manager/solutions/day05.dart';
// import 'package:aoc_manager/solutions/day06.dart';
// import 'package:aoc_manager/solutions/day07.dart';
// import 'package:aoc_manager/solutions/day08.dart';
// import 'package:aoc_manager/solutions/day09.dart';
// import 'package:aoc_manager/solutions/day10.dart';
// import 'package:aoc_manager/solutions/day11.dart';
// import 'package:aoc_manager/solutions/day12.dart';
// import 'package:aoc_manager/solutions/day13.dart';
// import 'package:aoc_manager/solutions/day14.dart';
// import 'package:aoc_manager/solutions/day15.dart';
// import 'package:aoc_manager/solutions/day16.dart';
// import 'package:aoc_manager/solutions/day17.dart';
// import 'package:aoc_manager/solutions/day18.dart';
// import 'package:aoc_manager/solutions/day19.dart';
// import 'package:aoc_manager/solutions/day20.dart';
// import 'package:aoc_manager/solutions/day21.dart';
// import 'package:aoc_manager/solutions/day22.dart';
// import 'package:aoc_manager/solutions/day23.dart';
// import 'package:aoc_manager/solutions/day24.dart';
// import 'package:aoc_manager/solutions/day25.dart';
// import 'package:aoc_manager/solutions/generic_solution.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' show join;
// import 'dart:developer' as devtools show log;

const minTime = Duration(milliseconds: 100);

class DayBloc extends Bloc<DayEvent, DayState> {
  final _prefs = SharedPreferencesAsync();
  String? _rootDir;
  int _dayNum = minDay;
  int _partNum = 1;
  String? _dataDirName;
  String? _dataFileName;
  String? _progDirName;
  String? _progFileName;
  bool _isRunning = false;
  bool _isPaused = false;
  Process? _process;

  final List<String> _messages = [];
  final List<String> _pausedMessages = [];
  final List<String> _errorMessages = [];
  final List<String> _pausedErrorMessages = [];

  // Solution? _solution;
  // Capability? _pausedCapability;
  // Isolate? _solutionTask;

  // final List<List<Solution>> _solutions = [
  //   [Day01P1(), Day01P2()], // 1
  //   [Day02P1(), Day02P2()], // 2
  //   [Day03P1(), Day03P2()], // 3
  //   [Day04P1(), Day04P2()], // 4
  //   [Day05P1(), Day05P2()], // 5
  //   [Day06P1(), Day06P2()], // 6
  //   [Day07P1(), Day07P2()], // 7
  //   [Day08P1(), Day08P2()], // 8
  //   [Day09P1(), Day09P2()], // 9
  //   [Day10P1(), Day10P2()], // 10
  //   [Day11P1(), Day11P2()], // 11
  //   [Day12P1(), Day12P2()], // 12
  //   [Day13P1(), Day13P2()], // 13
  //   [Day14P1(), Day14P2()], // 14
  //   [Day15P1(), Day15P2()], // 15
  //   [Day16P1(), Day16P2()], // 16
  //   [Day17P1(), Day17P2()], // 17
  //   [Day18P1(), Day18P2()], // 18
  //   [Day19P1(), Day19P2()], // 19
  //   [Day20P1(), Day20P2()], // 20
  //   [Day21P1(), Day21P2()], // 21
  //   [Day22P1(), Day22P2()], // 22
  //   [Day23P1(), Day23P2()], // 23
  //   [Day24P1(), Day24P2()], // 24
  //   [Day25P1(), Day25P2()], // 25
  // ];

  String _dayPartKey() => '${appNamePrefKey}_${_dayNum}_part';
  String _dayDataDirKey() => '${appNamePrefKey}_${_dayNum}_dir';
  String _dayDataFileKey() => '${appNamePrefKey}_${_dayNum}_${_partNum}_file';
  String _dayProgDirKey() => '${appNamePrefKey}_${_dayNum}_progdir';
  String _dayProgFileKey() =>
      '${appNamePrefKey}_${_dayNum}_${_partNum}_progfile';

  Future<void> _getPrefsForDay() async {
    _partNum = await _prefs.getInt(_dayPartKey()) ?? 1;
    _dataDirName = await _prefs.getString(_dayDataDirKey());
    _dataFileName = await _prefs.getString(_dayDataFileKey());
    _progDirName = await _prefs.getString(_dayProgDirKey());
    _progFileName = await _prefs.getString(_dayProgFileKey());
  }

  DayReady _newDayData({Exception? exception}) => DayReady(
        dayNum: _dayNum,
        partNum: _partNum,
        dataDirName: _dataDirName ?? (_rootDir ?? ''),
        dataFileName: _dataFileName ?? '',
        progDirName: _progDirName ?? (_rootDir ?? ''),
        progFileName: _progFileName ?? '',
        rootDir: _rootDir ?? '',
        isRunning: _isRunning,
        isPaused: _isPaused,
        messages: _messages,
        errorMessages: _errorMessages,
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

    // Update Data Dir
    on<DayChangeDataDirEvent>(
      (event, emit) async {
        if (!_isRunning) {
          // Did we select a new directory?
          if (event.newDir != null) {
            emit(const DayWorking());
            // If it's a new drectory, clear the file selection
            if (event.newDir != _dataDirName) {
              await _prefs.remove(_dayDataFileKey());
              final tmp = _partNum;
              _partNum = (_partNum % 2) + 1;
              await _prefs.remove(_dayDataFileKey());
              _partNum = tmp;
              _dataFileName = null;
            }
            // and save the directory
            await _prefs.setString(_dayDataDirKey(), event.newDir!);
            _dataDirName = event.newDir;

            emit(_newDayData());
          }
        }
      },
    );

    // Update Data file
    on<DayChangeDataFileEvent>(
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
              await _prefs.setString(_dayDataFileKey(), fileName);
              _dataFileName = fileName;
              await _prefs.setString(_dayDataDirKey(), pathName!);
              _dataDirName = pathName;
            }
            emit(_newDayData());
          }
        }
      },
    );

    // Update Programme Dir
    on<DayChangeProgDirEvent>(
      (event, emit) async {
        if (!_isRunning) {
          // Did we select a new directory?
          if (event.newDir != null) {
            emit(const DayWorking());
            // If it's a new drectory, clear the file selection
            if (event.newDir != _progDirName) {
              await _prefs.remove(_dayProgFileKey());
              final tmp = _partNum;
              _partNum = (_partNum % 2) + 1;
              await _prefs.remove(_dayProgFileKey());
              _partNum = tmp;
              _progFileName = null;
            }
            // and save the directory
            await _prefs.setString(_dayProgDirKey(), event.newDir!);
            _progDirName = event.newDir;

            emit(_newDayData());
          }
        }
      },
    );

    // Update programme file
    on<DayChangeProgFileEvent>(
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
              await _prefs.setString(_dayProgFileKey(), fileName);
              _progFileName = fileName;
              await _prefs.setString(_dayProgDirKey(), pathName!);
              _progDirName = pathName;
            }
            emit(_newDayData());
          }
        }
      },
    );

    // Change root dir
    on<DayChangeRootDirEvent>(
      (event, emit) async {
        // devtools.log((await _prefs.getAll()).toString());
        if (event.newRootDir != null) {
          _rootDir = event.newRootDir;
          await _prefs.setString(rootDirPrefKey, event.newRootDir!);
        }
      },
    );

    // Create the directory structure
    on<DayCreateFoldersEvent>(
      (event, emit) async {
        if (_rootDir == null) {
          _dispLn('Something has gone wrong.  rootDir is null',
              emit: emit, ensureNewLine: true);
        } else {
          for (int dayNum = 1; dayNum <= 25; dayNum++) {
            final dayNumStr = dayNum.toString().padLeft(2, '0');
            final newFolder = join(_rootDir!, 'Day$dayNumStr');
            final createDirProcess =
                await Process.start('mkdir', [newFolder], runInShell: true);
            if ((await createDirProcess.exitCode) == 0) {
              _dispLn('Created $newFolder', emit: emit);
            } else {
              _dispLn('Could not create $newFolder', emit: emit);
            }
          }
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
          if (_dataFileName != null && _dataFileName != '') {
            _isRunning = true;
            final dataFile = join(_dataDirName!, _dataFileName!);
            final progFile = join(_progDirName!, _progFileName!);

            _dispLn('');
            _dispLn('Day $_dayNum, part $_partNum');
            _dispLn('Running : $progFile');
            _dispLn('Using   : $dataFile', emit: emit);

            // var process = await Process.start('type', [file],
            //     runInShell: true, mode: ProcessStartMode.detachedWithStdio);
            // var process = await Process.start('dir', [], runInShell: true);

            _process =
                await Process.start(progFile, [dataFile], runInShell: true);

            var stdoutSplitter = StreamSplitter(_process!.stdout
                    .transform(utf8.decoder)
                    .transform(const LineSplitter()))
                .split();

            var stderrSplitter = StreamSplitter(_process!.stderr
                    .transform(utf8.decoder)
                    .transform(const LineSplitter()))
                .split();

            stdoutSplitter.forEach((message) {
              if (_isPaused) {
                _pausedMessages.add(message);
              } else {
                _messages.add(message);
                emit(_newDayData());
              }
            });

            stderrSplitter.forEach((message) {
              if (_isPaused) {
                _pausedErrorMessages.add(message);
              } else {
                _errorMessages.add(message);
                emit(_newDayData());
              }
            });

            int exitCode = await _process!.exitCode;

            while (_isPaused) {
              await Future.delayed(minTime);
            }

            _isRunning = false;
            await Future.delayed(minTime);

            _dispLn('');
            if (exitCode == 0) {
              _dispLn('Process ended normally');
            } else {
              _dispLn('Process ended with code $exitCode');
            }

            emit(_newDayData());
          } else {
            emit(_newDayData(exception: DayNoFileSelectedException()));
          }
        }
      },
    );

    on<DayShowStackTraceEvent>(
      (event, emit) {
        final stackTrace =
            const LineSplitter().convert(event.error.stackTrace.toString());
        _dispLn(event.error.toString());
        for (final line in stackTrace) {
          _dispLn(line);
        }
        _dispLn('', emit: emit);
      },
    );

    // Toggle the pause mode
    on<DayPauseEvent>(
      (event, emit) {
        if (_isRunning) {
          if (_isPaused) {
            _messages.addAll(_pausedMessages);
            _pausedMessages.clear();
            _errorMessages.addAll(_pausedErrorMessages);
            _pausedErrorMessages.clear();
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
            // _solutionTask!.resume(_pausedCapability!);
            _isPaused = false;
            // _pausedCapability = null;
          }
          _dispLn('Requesting process halt ...',
              emit: emit, ensureNewLine: true);
          //emit(_newDayData());

          if (_process != null) {
            final sigSent = _process!.kill();
            if (sigSent) {
              _dispLn('Sent kill signal', emit: emit, ensureNewLine: true);
            }
            _isRunning = false;
          } else {
            _dispLn('Something went wrong, process is null',
                emit: emit, ensureNewLine: true);
          }
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
        _errorMessages.clear();
        emit(_newDayData());
      },
    );
  }
}
