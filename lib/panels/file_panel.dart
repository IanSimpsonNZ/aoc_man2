import 'package:aoc_manager/services/day_manager/bloc/day_bloc.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_event.dart';
import 'package:aoc_manager/services/day_manager/bloc/day_manager_state.dart';
import 'package:extended_text/extended_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

class FilePanel extends StatefulWidget {
  const FilePanel({super.key});

  @override
  State<FilePanel> createState() => _FilePanelState();
}

class _FilePanelState extends State<FilePanel> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DayBloc, DayState>(
      builder: (context, state) {
        if (state is DayReady) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Wrap(
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
                    child: ExtendedText(
                      state.dirName,
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
                      onPressed: () async {
                        final selectedDir =
                            await FilePicker.platform.getDirectoryPath(
                          dialogTitle: 'Set data directory',
                          initialDirectory: state.dirName,
                        );
                        if (context.mounted) {
                          context
                              .read<DayBloc>()
                              .add(DayChangeDirEvent(selectedDir));
                        } else {
                          devtools
                              .log('context not moiunted for "Set Directory"');
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
                    width: 120,
                    child: Text('Data File: ',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  SizedBox(
                    width: 250,
                    child: Text(
                      state.fileName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: IconButton(
                      onPressed: () async {
                        final file = await FilePicker.platform.pickFiles(
                          dialogTitle: 'Select data file',
                          initialDirectory: state.dirName,
                          allowMultiple: false,
                          type: FileType.custom,
                          allowedExtensions: ['txt'],
                        );
                        if (context.mounted) {
                          context.read<DayBloc>().add(DayChangeFileEvent(file));
                        } else {
                          devtools.log('context not moiunted for "Set File"');
                        }
                      },
                      icon: const Icon(Icons.file_open),
                    ),
                  ),
                ],
              ),
            ],
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
