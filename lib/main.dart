import 'package:aoc_manager/panels/button_panel.dart';
import 'package:aoc_manager/panels/day_panel.dart';
import 'package:aoc_manager/panels/file_panel.dart';
import 'package:aoc_manager/panels/settings_menu.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocBuilder<DayBloc, DayState>(
      builder: (context, state) {
        if (state is DayWorking) {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        } else if (state is DayReady) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
              actions: const <Widget>[SettingsMenu()],
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DayPanel(),
                  FilePanel(),
                  Padding(padding: EdgeInsets.all(10.0)),
                  ButtonPanel(),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Something bad happened'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: const CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
