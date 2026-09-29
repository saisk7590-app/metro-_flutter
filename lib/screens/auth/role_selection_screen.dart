import 'package:flutter/material.dart';
import '../../models/auth/login_model.dart';
import '../../providers/login_provider.dart';
import 'security_verification_screen.dart';
import 'package:provider/provider.dart';

class RoleSelectionScreen extends StatelessWidget {
  final LoginModel loginData;
  const RoleSelectionScreen({super.key, required this.loginData});

  @override
  Widget build(BuildContext context) {
    final names = loginData.roleNames.split(',').map((x) => x.trim()).toList();
    final ids = loginData.roleIds.split(',').map((x) => x.trim()).toList();
    final scopes = loginData.unitAccessScopes
        .split(',')
        .map((x) => x.trim())
        .toList();

    void select(int index) {
      context.read<LoginProvider>().selectRole(
        roleId: index < ids.length ? ids[index] : '',
        roleName: names[index],
        unitAccessScope: index < scopes.length ? scopes[index] : '',
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SecurityVerificationScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select role')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'This user has multiple roles. Select one to continue.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < names.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: () => select(i),
                      child: Text(names[i]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
