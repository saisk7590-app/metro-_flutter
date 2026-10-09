import 'package:flutter/material.dart';
import '../../models/auth/login_model.dart';
import '../../providers/login_provider.dart';
import '../../navigation/maintenance_bay_navigation_screen.dart';
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

    Future<void> select(int index) async {
      final roleId = index < ids.length ? ids[index] : '';
      final roleName = names[index];
      final unitScope = index < scopes.length ? scopes[index] : '';

      final loginProv = context.read<LoginProvider>();
      loginProv.selectRole(
        roleId: roleId,
        roleName: roleName,
        unitAccessScope: unitScope,
      );

      // Save session for future biometric login
      await loginProv.saveSessionForBiometrics(
        roleId: roleId,
        roleName: roleName,
        unitAccessScope: unitScope,
      );

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MaintenanceBayNavigationScreen()),
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
