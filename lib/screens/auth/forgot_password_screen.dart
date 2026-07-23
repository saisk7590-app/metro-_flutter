import 'package:flutter/material.dart';

import '../../widgets/common/coming_soon_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password"), centerTitle: true),
      body: const ComingSoonScreen(
        moduleName: "AUTHENTICATION",
        title: "Forgot Password",
        description:
            "Authorized employees will be able to securely recover or reset their account credentials from this screen.",
        icon: Icons.lock_reset,
      ),
    );
  }
}
