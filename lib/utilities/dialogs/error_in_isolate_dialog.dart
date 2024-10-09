import 'package:flutter/material.dart';
import 'package:aoc_manager/utilities/dialogs/generic_dialog.dart';

Future<bool> errorInIsolateDialog(
  BuildContext context,
  String errorText,
) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Solution Error',
    content: errorText,
    optionsBuilder: () => {
      'Cancel': false,
      'Show stack trace': true,
    },
  ).then((value) => value ?? false);
}
