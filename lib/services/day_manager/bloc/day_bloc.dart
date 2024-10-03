import 'package:aoc_manager/constants/day_constants.dart';
import 'package:aoc_manager/constants/pref_constants.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DayBloc extends Bloc<DayEvent, DayState> {
  final _prefs = SharedPreferencesAsync();
  String? _rootDir;
  int _dayNum = minDay;
  int _partNum = 1;
  String? _dirName;
  String? _fileName;

  String? get rootDir => _rootDir;
  int get dayNum => _dayNum;
  int get partNum => _partNum;
  String get dirName => _dirName ?? (_rootDir ?? '');
  String get fileName => _fileName ?? '';

  String _dayPartKey() => '${appNamePrefKey}_${_dayNum}_part';
  String _dayDirKey() => '${appNamePrefKey}_${_dayNum}_dir';
  String _dayFileKey() => '${appNamePrefKey}_${_dayNum}_file';

  Future<void> getPrefsForDay() async {
    _partNum = await _prefs.getInt(_dayPartKey()) ?? 1;
    _dirName = await _prefs.getString(_dayDirKey());
    _fileName = await _prefs.getString(_dayFileKey());
  }

  DayReady _newDayData() => DayReady(
        dayNum: _dayNum,
        partNum: _partNum,
        dirName: _dirName ?? (_rootDir ?? ''),
        fileName: _fileName ?? '',
      );

  Future<void> initPrefs() async {
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
    await getPrefsForDay();
  }

  DayBloc() : super(const DayUninitialised()) {
    // Initiate - get previous settings, or create them if first run
    on<DayInitialiseEvent>((event, emit) async {
      emit(const DayWorking());
      await initPrefs();
      // Set up basic prefs if required
      emit(_newDayData());
    });

    // Update Day
    on<DayChangeDayEvent>(
      (event, emit) async {
        emit(const DayWorking());
        _dayNum = event.newDay;
        assert(_dayNum >= minDay && _dayNum <= maxDay);
        await _prefs.setInt(dayNumPrefKey, event.newDay);
        await getPrefsForDay();
        emit(_newDayData());
      },
    );

    // Update Part
    on<DayChangePartEvent>(
      (event, emit) async {
        emit(const DayWorking());
        _partNum = event.newPart;
        assert(_partNum == 1 || _partNum == 2);
        await _prefs.setInt(_dayPartKey(), event.newPart);
        emit(_newDayData());
      },
    );

    // Update Dir
    on<DayChangeDirEvent>(
      (event, emit) async {
        // Did we select a new directory?
        if (event.newDir != null) {
          emit(const DayWorking());
          // If it's a new drectory, clear the file selection
          if (event.newDir != _dirName) {
            await _prefs.remove(_dayFileKey());
            _fileName = null;
          }
          // and save the directory
          await _prefs.setString(_dayDirKey(), event.newDir!);
          _dirName = event.newDir;

          emit(_newDayData());
        }
      },
    );

    // Update file
    on<DayChangeFileEvent>(
      (event, emit) async {
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
      },
    );

    // Change root dir
    on<DayChangeRootDirEvent>(
      (event, emit) async {
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
        await initPrefs(); // This sets _dayNum
        _rootDir = await _prefs.getString(rootDirPrefKey);
        await getPrefsForDay();
        emit(_newDayData());
      },
    );
  }
}
