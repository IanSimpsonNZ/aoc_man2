import 'package:aoc_manager/constants/day_constants.dart';
import 'package:aoc_manager/constants/pref_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create initial defaults if they don't exist
Future<void> initPrefs() async {
  final prefs = SharedPreferencesAsync();
  final currentDay = await prefs.getInt(dayNumPrefKey);
  if (currentDay == null) {
    await prefs.setInt(dayNumPrefKey, minDay);
  }
  for (var day = minDay; day <= maxDay; day++) {
    final partKey = '${appNamePrefKey}_${day}_part';
    final currentPart = await prefs.getInt(partKey);
    if (currentPart == null) prefs.setInt(partKey, 1);
  }
}


// Would this be better as ...
// class MyPreferences extends SharedPreferencesAsync {
// make it a singleton
// don't need - just use "this." (?) final prefs = SharedPreferencesAsync();
// Future<void> initPrefs() async {...}
// all the little helper functions and constants
//}