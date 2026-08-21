import 'package:flutter/material.dart';

abstract final class CohabiSnackbar {
  static void error(BuildContext context, String message) {
    _show(context, message, Colors.redAccent);
  }

  static void success(BuildContext context, String message) {
    _show(context, message, Colors.green);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, Colors.blueGrey);
  }

  static void _show(BuildContext context, String message, Color color) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
