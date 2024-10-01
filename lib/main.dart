import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aoc_manager/constants/pref_constants.dart';
import 'package:aoc_manager/constants/day_constants.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:path/path.dart' show join;
// import 'package:path_provider/path_provider.dart'
//     show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;

void main() {
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
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _prefs = SharedPreferencesAsync();
  String? _rootDir;
  int _dayNum = minDay;

  Future<String?> getRootDir(String? currentRoot) async {
    print('${await _prefs.getAll()}');
    // If root hasn't been set, get the one from prefs (which might also be null)
    String? rootDir = currentRoot ?? await _prefs.getString(rootDirPrefKey);
    // getDirectoryPath will take a null initialDirectory
    final selectedDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Set root directory',
      initialDirectory: rootDir,
    );
    // If they pick something, save it in prefs
    if (selectedDir != null) {
      await _prefs.setString(rootDirPrefKey, selectedDir);
      rootDir = selectedDir;
    }
    // Otherwise stay as we are
    return rootDir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              _rootDir = await getRootDir(_rootDir);
            },
            icon: const Icon(Icons.settings),
            tooltip: 'Set root directory',
          )
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 16),
            Text('Day', style: Theme.of(context).textTheme.headlineMedium),
            FutureBuilder<int?>(
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
                }),
          ],
        ),
      ),
    );
  }
}
