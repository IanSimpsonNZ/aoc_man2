import 'package:aoc_manager/enums/menu_action.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:aoc_manager/utilities/dialogs/clear_prefs_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayBloc, DayState>(builder: (context, state) {
      if (state is DayReady) {
        return PopupMenuButton<HomeMenuAction>(
          enabled: !state.isRunning,
          onSelected: (value) async {
            switch (value) {
              case HomeMenuAction.setRoot:
                final selectedDir = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: 'Set root directory',
                  initialDirectory: state.rootDir,
                );
                if (context.mounted) {
                  context
                      .read<DayBloc>()
                      .add(DayChangeRootDirEvent(selectedDir));
                } else {
                  devtools.log('context not moiunted in "Set Root" menu');
                }
              case HomeMenuAction.clearPrefs:
                final shouldClear = await showClearPrefsDialog(context);
                if (shouldClear) {
                  if (context.mounted) {
                    context.read<DayBloc>().add(const DayClearPrefsEvent());
                  } else {
                    devtools.log('context not moiunted in "Clear prefs" menu');
                  }
                }
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
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Something went wrong'),
          ),
          body: const CircularProgressIndicator(),
        );
      }
    });
  }
}
