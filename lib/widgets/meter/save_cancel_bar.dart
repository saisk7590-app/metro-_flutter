import 'package:flutter/material.dart';

class SaveCancelBar extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  final bool isSaving;
  final bool canSave;

  const SaveCancelBar({
    super.key,
    required this.onCancel,
    required this.onSave,
    this.isSaving = false,
    this.canSave = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.outline.withValues(alpha: .20)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            //------------------------------------------------
            // Cancel Button
            //------------------------------------------------
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onCancel,
                icon: const Icon(Icons.close_rounded),
                label: const Text("Cancel"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            //------------------------------------------------
            // Save Button
            //------------------------------------------------
            Expanded(
              child: FilledButton.icon(
                onPressed: (!canSave || isSaving) ? null : onSave,
                icon: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(isSaving ? "Saving..." : "Save"),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
