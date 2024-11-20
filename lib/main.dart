import 'package:aoc_manager/panels/button_panel.dart';
import 'package:aoc_manager/panels/day_panel.dart';
import 'package:aoc_manager/panels/data_file_panel.dart';
import 'package:aoc_manager/panels/prog_file_panel.dart';
import 'package:aoc_manager/panels/output_panel.dart';
import 'package:aoc_manager/panels/error_panel.dart';
import 'package:aoc_manager/panels/settings_menu.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:aoc_manager/services/day_manager/day_manager_exceptions.dart';
import 'package:aoc_manager/utilities/dialogs/error_dialog.dart';
import 'package:aoc_manager/utilities/dialogs/error_in_isolate_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: BlocProvider<DayBloc>(
        create: (context) => DayBloc(),
        child: const MyHomePage(title: 'Advent of Code Manager'),
      ),
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
  @override
  Widget build(BuildContext context) {
    context.read<DayBloc>().add(const DayInitialiseEvent());
    return BlocListener<DayBloc, DayState>(
      listener: (context, state) async {
        if (state is DayReady) {
          if (state.exception is DayNoFileSelectedException) {
            await showErrorDialog(
              context,
              'A data file needs to be selected',
            );
          } else if (state.exception is RemoteErrorException) {
            devtools.log('Caught remote error');
            final remoteError = state.exception as RemoteErrorException;
            final showTrace = await errorInIsolateDialog(
                context, remoteError.error.toString());
            if (showTrace) {
              if (context.mounted) {
                context
                    .read<DayBloc>()
                    .add(DayShowStackTraceEvent(error: remoteError.error));
              } else {
                devtools.log('main - RemoteError -  context not mounted');
              }
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: const <Widget>[SettingsMenu()],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const DayPanel(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 500,
                    child: ProgFilePanel(),
                  ),
                  SizedBox(
                    width: 500,
                    child: DataFilePanel(),
                  ),
                ],
              ),
              // const DataFilePanel(),
              const Padding(padding: EdgeInsets.all(10.0)),
              const ButtonPanel(),
              const Padding(padding: EdgeInsets.all(8.0)),
              const Divider(
                height: 4,
                thickness: 2,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text('Output'),
              ),
              const Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: OutputPanel(),
                ),
              ),
              const Divider(
                height: 4,
                thickness: 2,
                indent: 0,
                endIndent: 0,
                color: Colors.black,
              ),
              Container(
                alignment: Alignment.topLeft,
                child: const Text('Errors'),
              ),
              Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(maxHeight: 125),
                child: const ErrorPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
