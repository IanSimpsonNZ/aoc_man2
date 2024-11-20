import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:extended_text/extended_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

class ProgFilePanel extends StatefulWidget {
  const ProgFilePanel({super.key});

  @override
  State<ProgFilePanel> createState() => _ProgFilePanelState();
}

class _ProgFilePanelState extends State<ProgFilePanel> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayBloc, DayState>(
      builder: (context, state) {
        if (state is DayReady) {
          return Opacity(
            opacity: state.isRunning ? 0.5 : 1.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Program Directory: ',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    SizedBox(
                      width: 250,
                      child: ExtendedText(
                        state.progDirName,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflowWidget: const TextOverflowWidget(
                          position: TextOverflowPosition.start,
                          child: Text('...'),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: IconButton(
                        onPressed: state.isRunning
                            ? null
                            : () async {
                                final selectedDir =
                                    await FilePicker.platform.getDirectoryPath(
                                  dialogTitle: 'Set program directory',
                                  initialDirectory: state.progDirName,
                                );
                                if (context.mounted) {
                                  context
                                      .read<DayBloc>()
                                      .add(DayChangeProgDirEvent(selectedDir));
                                } else {
                                  devtools.log(
                                      'context not mounted for "Set Directory"');
                                }
                              },
                        icon: const Icon(Icons.folder),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 5,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 150,
                      child: Text('Program File: ',
                          style: Theme.of(context).textTheme.bodyLarge),
                    ),
                    SizedBox(
                      width: 250,
                      child: Text(
                        state.progFileName,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                      child: IconButton(
                        onPressed: state.isRunning
                            ? null
                            : () async {
                                final file =
                                    await FilePicker.platform.pickFiles(
                                  dialogTitle: 'Select programme file',
                                  initialDirectory: state.progDirName,
                                  allowMultiple: false,
                                  type: FileType.custom,
                                  allowedExtensions: ['exe', 'com'],
                                );
                                if (context.mounted) {
                                  context
                                      .read<DayBloc>()
                                      .add(DayChangeProgFileEvent(file));
                                } else {
                                  devtools.log(
                                      'context not mounted for "Set File"');
                                }
                              },
                        icon: const Icon(Icons.file_open),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}