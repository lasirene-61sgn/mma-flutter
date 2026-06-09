import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toaster {
  /// Displays a success toast with a green background.
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF2E7D32), // Premium Green
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Displays an error toast with a red/maroon background.
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: const Color(0xFFC62828), // Premium Red
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Displays an informational toast with a dark grey background.
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF323232), // Dark Charcoal
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Displays a warning toast with an orange background.
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFFEF6C00), // Premium Orange
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}
