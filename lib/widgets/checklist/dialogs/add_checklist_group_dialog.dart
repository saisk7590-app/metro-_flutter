import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/checklist_provider.dart';

/// Modal dialog to add a new group to a checklist matching `AddChecklistGroupComponent`
class AddChecklistGroupDialog extends StatefulWidget {
  final String checklistName;
  final int checklistId;

  const AddChecklistGroupDialog({
    super.key,
    required this.checklistName,
    required this.checklistId,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String checklistName,
    required int checklistId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddChecklistGroupDialog(
        checklistName: checklistName,
        checklistId: checklistId,
      ),
    );
  }

  @override
  State<AddChecklistGroupDialog> createState() => _AddChecklistGroupDialogState();
}

class _AddChecklistGroupDialogState extends State<AddChecklistGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<ChecklistProvider>();

    final success = await provider.createChecklistGroup(
      checklistId: widget.checklistId,
      groupName: _groupNameController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00D25B),
            content: Text('Checklist Group Added Successfully ✓'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error while adding Checklist Group'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.playlist_add, color: Color(0xFF00D25B)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Add Checklist Group',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // 1. ChecklistName (Read-only)
                _buildLabel('ChecklistName', isRequired: true),
                const SizedBox(height: 4),
                TextFormField(
                  initialValue: widget.checklistName,
                  readOnly: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Group Name (Required)
                _buildLabel('Group Name', isRequired: true),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _groupNameController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter Group Name',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Group Name is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Actions: Reset + Save
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _groupNameController.clear(),
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D25B),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
        children: [
          TextSpan(text: label),
          if (isRequired)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
