import 'package:aoc_manager/enums/menu_action.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:aoc_manager/utilities/dialogs/clear_prefs_dialog.dart';
import 'package:aoc_manager/utilities/dialogs/create_folders_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io' as io;
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
                final checkedRoot = await io.Directory(state.rootDir).exists()
                    ? state.rootDir
                    : null;
                final selectedDir = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: 'Set root directory',
                  initialDirectory: checkedRoot,
                );
                if (context.mounted) {
                  context
                      .read<DayBloc>()
                      .add(DayChangeRootDirEvent(selectedDir));
                } else {
                  devtools.log('context not mounted in "Set Root" menu');
                }
              case HomeMenuAction.clearPrefs:
                final shouldClear = await showClearPrefsDialog(context);
                if (shouldClear) {
                  if (context.mounted) {
                    context.read<DayBloc>().add(const DayClearPrefsEvent());
                  } else {
                    devtools.log('context not mounted in "Clear prefs" menu');
                  }
                }
              case HomeMenuAction.createFolders:
                final shouldCreate =
                    await showCreateFoldersDialog(context, state.rootDir);
                if (shouldCreate) {
                  if (context.mounted) {
                    context.read<DayBloc>().add(const DayCreateFoldersEvent());
                  } else {
                    devtools.log(
                        'context not mounted in "Create Directories" menu');
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
                value: HomeMenuAction.createFolders,
                child: Text('Create folder structure'),
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
