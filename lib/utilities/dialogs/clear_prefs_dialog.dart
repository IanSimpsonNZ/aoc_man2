import 'package:flutter/material.dart';
import 'package:aoc_manager/utilities/dialogs/generic_dialog.dart';

Future<bool> showClearPrefsDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Clear preferences',
    content: 'Are you sure you want to clear all the preferences?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}
