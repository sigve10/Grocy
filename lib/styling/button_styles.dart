import 'package:flutter/material.dart';

/// Styles for buttons
/// - ElevatedButton that is filled
/// - OutlinedButton that is an outlined button
class ButtonStyles {
  // ButtonFilled (ElevatedButton)
  static final ButtonStyle filled = ElevatedButton.styleFrom(
    minimumSize: const Size(200, 60),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
    textStyle: const TextStyle(fontSize: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Style for OutlinedButton (ButtonOutlined)
  static final ButtonStyle outlined = OutlinedButton.styleFrom(
    minimumSize: const Size(200, 60),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
    textStyle: const TextStyle(fontSize: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
