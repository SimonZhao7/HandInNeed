import 'package:flutter/material.dart';
// Widgets
import 'package:hand_in_need/widgets/dialogs/dialog_constants.dart';
import 'package:hand_in_need/widgets/dialogs/dialog.dart';
// Constants
import 'package:hand_in_need/constants/colors.dart';

Future<bool?> showDeleteConfirmationDialog<bool>(BuildContext context, String title) {
  return displayDialog(
    context,
    title: title,
    actions: [
      {
        val: true,
        label: 'Yes',
        bgColor: negativeRed,
      },
      {
        val: false,
        label: 'No',
      }
    ],
  );
}
