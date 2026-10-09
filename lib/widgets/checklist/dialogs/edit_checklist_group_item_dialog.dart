import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/checklist_model.dart';
import '../../../providers/checklist_provider.dart';

/// Modal dialog to edit Sub System and Check Description matching `updateChecklistItem` in NxAMS
class EditChecklistGroupItemDialog extends StatefulWidget {
  final int groupId;
  final String groupName;
  final CheckItemModel item;

  const EditChecklistGroupItemDialog({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.item,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int groupId,
    required String groupName,
    required CheckItemModel item,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditChecklistGroupItemDialog(
        groupId: groupId,
        groupName: groupName,
        item: item,
      ),
    );
  }

  @override
  State<EditChecklistGroupItemDialog> createState() => _EditChecklistGroupItemDialogState();
}

class _EditChecklistGroupItemDialogState extends State<EditChecklistGroupItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subGroupController;
  late TextEditingController _checkDescController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _subGroupController = TextEditingController(text: widget.item.subGroup);
    _checkDescController = TextEditingController(text: widget.item.checkDescription);
  }

  @override
  void dispose() {
    _subGroupController.dispose();
    _checkDescController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<ChecklistProvider>();

    final success = await provider.updateChecklistGroupItem(
      groupId: widget.groupId,
      checkItemId: widget.item.id,
      subGroup: _subGroupController.text.trim(),
      checkDescription: _checkDescController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00D25B),
            content: Text('Check Item Updated Successfully ✓'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error updating Check Item'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                    const Icon(Icons.edit_note, color: Color(0xFF00D25B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Edit Check Item (${widget.groupName})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
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

                // 1. Sub System field (Required)
                _buildLabel('Sub System', isRequired: true),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _subGroupController,
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

                const SizedBox(height: 14),

                // 2. Check Description field (Required)
                _buildLabel('Check Description', isRequired: true),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _checkDescController,
                  maxLines: 3,
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

                // Actions: Close + Update
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D25B),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isSubmitting ? null : _handleUpdate,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Update'),
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
