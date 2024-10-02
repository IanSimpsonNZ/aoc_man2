import 'package:aoc_manager/services/prefs_service.dart';
import 'package:aoc_manager/utilities/dialogs/clear_prefs_dialog.dart';
import 'package:extended_text/extended_text.dart';
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
  int? _dayNum;
  int _partNum = 1;
  String? _dataDir;

  String _dayPartKey() => '${appNamePrefKey}_${_dayNum}_part';
  String _dayDirKey() => '${appNamePrefKey}_${_dayNum}_dir';

  Future<String?> _getDir({
    required String? currentDir,
    required String key,
    required String title,
  }) async {
    print('${await _prefs.getAll()}');
    // If Dir hasn't been set, try and get value from prefs
    String? newDir = currentDir ?? await _prefs.getString(key);
    // getDirectoryPath will take a null initialDirectory
    final selectedDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: title,
      initialDirectory: newDir,
    );
    // If they pick something, save it in prefs
    if (selectedDir != null) {
      await _prefs.setString(key, selectedDir);
      newDir = selectedDir;
    }
    return newDir;
  }

  Future<String?> getUniversalPrefs() async {
    _dayNum ??= await _prefs
        .getInt(dayNumPrefKey); // init always ensures this has a value
    return _prefs.getString(rootDirPrefKey);
  }

  Future<void> getDayPrefs() async {
    _partNum = await _prefs.getInt(_dayPartKey()) ?? 1;
    _dataDir = await _prefs.getString(_dayDirKey());
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
        child: FutureBuilder<String?>(
            future: getUniversalPrefs(),
            builder: (
              BuildContext context,
              AsyncSnapshot snapshot,
            ) {
              if (snapshot.hasData) {
                _rootDir = snapshot.data;
              } else {
                _rootDir = null;
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Day',
                          style: Theme.of(context).textTheme.headlineSmall),
                      _daySelector(),
                      _partSelector(),
                    ],
                  ),
                  _directorySelector(),
                  _fileSelector(),
                ],
              );
            }),
      ),
    );
  }

  Widget _settingsMenu() {
    return PopupMenuButton<HomeMenuAction>(
      onSelected: (value) async {
        switch (value) {
          case HomeMenuAction.setRoot:
            _rootDir = await _getDir(
              currentDir: _rootDir,
              key: rootDirPrefKey,
              title: 'Set root directory',
            );
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
    return NumberPicker(
      value: _dayNum ?? minDay,
      minValue: minDay,
      maxValue: maxDay,
      step: 1,
      haptics: true,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      selectedTextStyle: Theme.of(context).textTheme.headlineSmall,
      itemHeight: 30.0,
      itemWidth: 50.0,
      onChanged: (value) async {
        setState(() => _dayNum = value);
        await _prefs.setInt(dayNumPrefKey, value);
        await getDayPrefs();
      },
    );
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
                  RadioListTile<int>(
                      title: Text(
                        'Part 1',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      value: 1,
                      groupValue: _partNum,
                      dense: true,
                      onChanged: (int? value) {
                        setState(
                          () async {
                            _partNum = value ?? 1;
                            _prefs.setInt(_dayPartKey(), _partNum);
                          },
                        );
                      }),
                  RadioListTile<int>(
                      title: Text(
                        'Part 2',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      value: 2,
                      groupValue: _partNum,
                      dense: true,
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
              CircularProgressIndicator(),
            ]);
          }
        });
  }

  Widget _directorySelector() {
    return Wrap(
      spacing: 5,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 120,
          child: Text(
            'Data Directory: ',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        SizedBox(
          width: 250,
          child: FutureBuilder<String?>(
            future: _prefs.getString(_dayDirKey()),
            builder: (
              BuildContext context,
              AsyncSnapshot<String?> snapshot,
            ) {
              final String dirTxt;
              if (snapshot.hasData) {
                _dataDir = snapshot.data;
                dirTxt = _dataDir ?? (_rootDir ?? 'Empty');
              } else {
                dirTxt = _rootDir ?? 'None';
              }
              return ExtendedText(
                dirTxt,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflowWidget: const TextOverflowWidget(
                  position: TextOverflowPosition.start,
                  child: Text('...'),
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: 30,
          child: IconButton(
            onPressed: () async {
              _dataDir = await _getDir(
                currentDir: _dataDir,
                key: _dayDirKey(),
                title: 'Set data directory',
              );
              setState(() {});
            },
            icon: const Icon(Icons.folder),
          ),
        ),
      ],
    );
  }

  Widget _fileSelector() {
    return Wrap(
        spacing: 5,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text('Data File: ',
                style: Theme.of(context).textTheme.bodyLarge),
          ),
          SizedBox(
            width: 250,
            child:
                Text('FileName ', style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(
            width: 30,
          )
        ]);
  }
}
