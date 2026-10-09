import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

class EditProfileDialog extends StatefulWidget {
  final String currentEmail;
  final String currentMobile;

  const EditProfileDialog({
    super.key,
    required this.currentEmail,
    required this.currentMobile,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentEmail,
    required String currentMobile,
  }) {
    return showDialog(
      context: context,
      builder: (_) => EditProfileDialog(
        currentEmail: currentEmail,
        currentMobile: currentMobile,
      ),
    );
  }

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  late final TextEditingController _mobileCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.currentEmail);
    _mobileCtrl = TextEditingController(text: widget.currentMobile);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    setState(() => _isSaving = true);

    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final success = await context.read<ProfileProvider>().updateProfile(
          mobile: _mobileCtrl.text,
          email: _emailCtrl.text,
        );

    if (mounted) {
      setState(() => _isSaving = false);
      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Profile updated successfully' : 'Failed to update profile',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.edit_note, size: 22),
          SizedBox(width: 8),
          Text('Edit Contact Info'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _mobileCtrl,
              decoration: const InputDecoration(
                labelText: 'Mobile Number *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  (v == null || v.trim().length != 10) ? 'Enter 10-digit mobile' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Address *',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Enter valid email' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
