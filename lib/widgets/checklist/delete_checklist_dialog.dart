import 'package:flutter/material.dart';

Future<bool?> showDeleteChecklistDialog(
  BuildContext context, {
  required String checklistName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text("Delete Checklist"),
        content: Text(
          "Are you sure you want to delete\n\n$checklistName ?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),

          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}