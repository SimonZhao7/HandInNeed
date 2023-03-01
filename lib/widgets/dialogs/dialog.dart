import 'package:flutter/material.dart';
// Widgets
import '../button.dart';
// Constants
import 'package:hand_in_need/widgets/dialogs/dialog_constants.dart';

/// Display a generic dialog with the given [context], [title], and [actions]
///
/// Arguments:
///
/// `context`: the build context passed by the callee
///
/// `title`: the title of the dialog
///
/// `actions`: A `List` of `Map` objects in the form:
///
///       String label: the action text,
///
///       T val: the value that will be returned when dialog is dismissed
///
///       Color? bgColor: the background color of the button
///
///       Color? color: the foreground color of the button

Future<T?> displayDialog<T>(
  BuildContext context, {
  required String title,
  required List<Map<String, dynamic>> actions,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(20),
        buttonPadding: const EdgeInsets.all(20),
        insetPadding: const EdgeInsets.all(20),
        title: Text(title),
        actions: [
          Row(
            children: actions
                .map(
                  (action) => Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Button(
                            onPressed: () => Navigator.of(context).pop(
                              action[val],
                            ),
                            label: action[label],
                            backgroundColor: action[bgColor],
                            textColor: action[color],
                          ),
                        ),
                        if (actions.indexOf(action) < actions.length - 1)
                          const SizedBox(width: 10),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      );
    },
  );
}
