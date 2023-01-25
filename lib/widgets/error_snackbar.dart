import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Text(
          message,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.red,
    ),
  );
}
