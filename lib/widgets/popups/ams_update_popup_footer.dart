import 'package:flutter/material.dart';

class AmsPopupFooter extends StatelessWidget {
  final bool isSaving;
  final bool isSaveDisabled;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const AmsPopupFooter({
    super.key,
    required this.isSaving,
    required this.isSaveDisabled,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Cancel Button (btn-outline-danger style)
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            side: const BorderSide(color: Color(0xFFDC2626)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: isSaving ? null : onCancel,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
        ),

        const SizedBox(width: 12),

        // Save Button (btn-success style)
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF10B981).withValues(alpha: 0.5),
            disabledForegroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            elevation: 2,
          ),
          onPressed: isSaveDisabled ? null : onSave,
          icon: isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, size: 16),
          label: Text(
            isSaving ? 'Saving...' : 'Save',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
