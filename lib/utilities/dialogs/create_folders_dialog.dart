import 'package:flutter/material.dart';
import 'package:aoc_manager/utilities/dialogs/generic_dialog.dart';

Future<bool> showCreateFoldersDialog(BuildContext context, String? rootDir) {
  if (rootDir == null) {
    return showGenericDialog<bool>(
      context: context,
      title: 'Create folders',
      content: 'ERROR: You must set a root folder first.',
      optionsBuilder: () => {
        'OK': false,
      },
    ).then((value) => false);
  } else {
    return showGenericDialog<bool>(
      context: context,
      title: 'Create folders',
      content:
          'Are you sure you want to create the program folders in $rootDir',
      optionsBuilder: () => {
        'Cancel': false,
        'Yes': true,
      },
    ).then((value) => value ?? false);
  }
}
