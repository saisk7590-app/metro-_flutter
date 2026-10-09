import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/checklist_model.dart';
import '../../../providers/checklist_provider.dart';

/// Modal dialog to edit or delete a Checklist Group matching NxAMS `openGroupPopup`
class EditChecklistGroupDialog extends StatefulWidget {
  final CheckGroupModel group;

  const EditChecklistGroupDialog({
    super.key,
    required this.group,
  });

  static Future<bool?> show(
    BuildContext context, {
    required CheckGroupModel group,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditChecklistGroupDialog(group: group),
    );
  }

  @override
  State<EditChecklistGroupDialog> createState() => _EditChecklistGroupDialogState();
}

class _EditChecklistGroupDialogState extends State<EditChecklistGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _groupNameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.group.group);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<ChecklistProvider>();

    final success = await provider.updateChecklistGroup(
      groupId: widget.group.groupId,
      groupName: _groupNameController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00D25B),
            content: Text('Group Updated Successfully ✓'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error updating Group Name'),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Group', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete group "${widget.group.group}" and all its checks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<ChecklistProvider>();
    final success = await provider.deleteChecklistGroup(groupId: widget.group.groupId);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00D25B),
            content: Text('Group Deleted Successfully ✓'),
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
                    const Icon(Icons.edit_note, color: Color(0xFF00D25B)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Edit Group',
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
                const SizedBox(height: 12),

                // Group Name field
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                    children: [
                      TextSpan(text: 'Group Name'),
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
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

                // Actions: Delete Group + Cancel + Update
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      label: const Text('Delete', style: TextStyle(color: Colors.red, fontSize: 13)),
                      onPressed: _isSubmitting ? null : _handleDelete,
                    ),
                    const Spacer(),
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
}
