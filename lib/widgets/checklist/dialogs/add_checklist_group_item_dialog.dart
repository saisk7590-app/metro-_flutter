import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/checklist_provider.dart';

/// Modal dialog to add a new check item to a group matching `AddChecklistGroupItemComponent`
class AddChecklistGroupItemDialog extends StatefulWidget {
  final String checklistName;
  final String groupName;
  final int groupId;

  const AddChecklistGroupItemDialog({
    super.key,
    required this.checklistName,
    required this.groupName,
    required this.groupId,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String checklistName,
    required String groupName,
    required int groupId,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddChecklistGroupItemDialog(
        checklistName: checklistName,
        groupName: groupName,
        groupId: groupId,
      ),
    );
  }

  @override
  State<AddChecklistGroupItemDialog> createState() => _AddChecklistGroupItemDialogState();
}

class _AddChecklistGroupItemDialogState extends State<AddChecklistGroupItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subSystemController = TextEditingController();
  final _checkDescriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subSystemController.dispose();
    _checkDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<ChecklistProvider>();

    final success = await provider.createChecklistGroupItem(
      groupId: widget.groupId,
      subGroup: _subSystemController.text.trim(),
      checkDescription: _checkDescriptionController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00D25B),
            content: Text('Check Item Added Successfully ✓'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error while adding Check Item'),
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_task, color: Color(0xFF00D25B)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Add Check Item',
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

                  const SizedBox(height: 12),

                  // 2. Group Name (Read-only)
                  _buildLabel('Group Name', isRequired: true),
                  const SizedBox(height: 4),
                  TextFormField(
                    initialValue: widget.groupName,
                    readOnly: true,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Sub System (Required)
                  _buildLabel('Sub System', isRequired: true),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _subSystemController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter Sub System',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Sub System is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // 4. Check Description (Required)
                  _buildLabel('Check Description', isRequired: true),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _checkDescriptionController,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter Check Description',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Check Description is required';
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
                        onPressed: () {
                          _subSystemController.clear();
                          _checkDescriptionController.clear();
                        },
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
