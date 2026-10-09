import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/checklist_provider.dart';
import '../../../models/checklist_model.dart';

/// Modal dialog to edit Checklist Name only matching `EditChecklistNamePopupComponent`
class EditChecklistNameDialog extends StatefulWidget {
  final JobPlanChecklistModel checklist;

  const EditChecklistNameDialog({super.key, required this.checklist});

  static Future<bool?> show(BuildContext context, {required JobPlanChecklistModel checklist}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => EditChecklistNameDialog(checklist: checklist),
    );
  }

  @override
  State<EditChecklistNameDialog> createState() => _EditChecklistNameDialogState();
}

class _EditChecklistNameDialogState extends State<EditChecklistNameDialog> {
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.checklist.jpcChecklistName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSubmitting = true);
    final provider = context.read<ChecklistProvider>();

    final success = await provider.updateChecklistName(
      jpcId: widget.checklist.jpcId,
      checklistName: name,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF00D25B),
            content: Text('Checklist Name updated successfully ✓'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error updating Checklist Name'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Edit Checklist Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              children: [
                TextSpan(text: 'Checklist Name'),
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter Checklist Name',
              isDense: true,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Close'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D25B),
            foregroundColor: Colors.white,
          ),
          onPressed: _isSubmitting ? null : _handleUpdate,
          child: _isSubmitting
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Update'),
        ),
      ],
    );
  }
}
