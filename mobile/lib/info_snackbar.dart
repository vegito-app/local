import 'package:flutter/material.dart';

class InfoSnackBar {
  static void show(BuildContext context, String message,
      {String? semanticsLabel}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(
          label: semanticsLabel ?? 'info-snackbar',
          child: Text(message),
        ),
      ),
    );
  }
}
