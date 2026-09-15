import 'package:flutter/material.dart';

/// Shared "Confirm Changes?" dialog used by every add/edit screen.
/// Returns true if the user tapped Yes, false (or null) otherwise.
Future<bool> showConfirmChangesDialog(
  BuildContext context, {
  required String message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Changes?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}