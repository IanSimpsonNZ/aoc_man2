import 'package:aoc_manager/services/prefs_service.dart';
import 'package:aoc_manager/utilities/dialogs/clear_prefs_dialog.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aoc_manager/constants/pref_constants.dart';
import 'package:aoc_manager/constants/day_constants.dart';
import 'package:aoc_manager/enums/menu_action.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart'
//     show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPrefs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advent of Code Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Advent of Code Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _prefs = SharedPreferencesAsync();

  String? _rootDir;
  int _dayNum = minDay;
  int _partNum = 1;

  String _dayPartKey() => '${appNamePrefKey}_${_dayNum}_part';

  Future<void> getRootDir() async {
    print('${await _prefs.getAll()}');
    // If root hasn't been set, get the one from prefs (which might also be null)
    _rootDir ??= await _prefs.getString(rootDirPrefKey);
    // getDirectoryPath will take a null initialDirectory
    final selectedDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Set root directory',
      initialDirectory: _rootDir,
    );
    // If they pick something, save it in prefs
    if (selectedDir != null) {
      await _prefs.setString(rootDirPrefKey, selectedDir);
      _rootDir = selectedDir;
    }
    // Otherwise stay as we are
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[_settingsMenu()],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 16,
              //width: 32,
            ),
            Text('Day', style: Theme.of(context).textTheme.headlineSmall),
            _daySelector(),
            _partSelector(),
          ],
        ),
      ),
    );
  }

  Widget _settingsMenu() {
    return PopupMenuButton<HomeMenuAction>(
      onSelected: (value) async {
        switch (value) {
          case HomeMenuAction.setRoot:
            await getRootDir();
          case HomeMenuAction.clearPrefs:
            final shouldClear = await showClearPrefsDialog(context);
            if (shouldClear) await _prefs.clear();
        }
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem<HomeMenuAction>(
            value: HomeMenuAction.setRoot,
            child: Text('Set root directory'),
          ),
          PopupMenuItem<HomeMenuAction>(
            value: HomeMenuAction.clearPrefs,
            child: Text('Reset preferences'),
          ),
        ];
      },
      icon: const Icon(Icons.settings),
      tooltip: 'Manage settings',
    );
  }

  Widget _daySelector() {
    return FutureBuilder<int?>(
        future: _prefs.getInt(dayNumPrefKey),
        builder: (
          BuildContext context,
          AsyncSnapshot<int?> snapshot,
        ) {
          if (snapshot.hasData) {
            _dayNum = snapshot.data ?? minDay;
            return NumberPicker(
              value: _dayNum,
              minValue: minDay,
              maxValue: maxDay,
              step: 1,
              haptics: true,
              onChanged: (value) async {
                setState(() => _dayNum = value);
                await _prefs.setInt(dayNumPrefKey, value);
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Widget _partSelector() {
    return FutureBuilder<int?>(
        future: _prefs.getInt(_dayPartKey()),
        builder: (
          BuildContext context,
          AsyncSnapshot<int?> snapshot,
        ) {
          if (snapshot.hasData) {
            _partNum = snapshot.data ?? 1;
            return IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   height: 16,
                  //   width: 16,
                  // ),
                  RadioListTile<int>(
                      // tileColor: Colors.green,
                      title: const Text('Part 1'),
                      value: 1,
                      groupValue: _partNum,
                      onChanged: (int? value) {
                        setState(
                          () async {
                            _partNum = value ?? 1;
                            _prefs.setInt(_dayPartKey(), _partNum);
                          },
                        );
                      }),
                  RadioListTile<int>(
                      // tileColor: Colors.green,
                      title: const Text('Part 2'),
                      value: 2,
                      groupValue: _partNum,
                      onChanged: (int? value) {
                        setState(
                          () {
                            _partNum = value ?? 1;
                            _prefs.setInt(_dayPartKey(), _partNum);
                          },
                        );
                      }),
                ],
              ),
            );
          } else {
            return const Column(children: [
              const CircularProgressIndicator(),
            ]);
          }
        });
  }
}
