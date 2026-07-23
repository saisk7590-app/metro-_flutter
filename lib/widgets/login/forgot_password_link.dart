import 'package:flutter/material.dart';

class ForgotPasswordLink extends StatelessWidget {
  final VoidCallback onTap;

  const ForgotPasswordLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onTap,
      child: Text(
        "Forgot Credentials?",
        style: TextStyle(color: theme.primaryColor),
      ),
    );
  }
}
