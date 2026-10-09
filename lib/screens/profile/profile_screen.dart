import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/login_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/profile/edit_profile_dialog.dart';
import '../../widgets/profile/profile_header_card.dart';
import '../../widgets/profile/profile_info_tiles.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final loginProvider = context.read<LoginProvider>();
    final staffId = loginProvider.loginData?.staffId ?? 0;
    if (staffId > 0) {
      context.read<ProfileProvider>().fetchProfile(staffId.toString());
    }
  }

  String _getInitials(String name, String username) {
    final target = name.trim().isNotEmpty ? name.trim() : username.trim();
    if (target.isEmpty) return 'U';
    final parts = target.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return target.substring(0, target.length >= 2 ? 2 : 1).toUpperCase();
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out from NxAMS?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<LoginProvider>().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginProvider = context.watch<LoginProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final loginData = loginProvider.loginData;
    final liveProfile = profileProvider.profile;

    final staffName = liveProfile?.staffName.isNotEmpty == true
        ? liveProfile!.staffName
        : (loginData?.staffName.isNotEmpty == true
            ? loginData!.staffName
            : (loginData?.userName ?? 'User'));

    final roleName = loginProvider.selectedRoleName?.isNotEmpty == true
        ? loginProvider.selectedRoleName!
        : (loginData?.roleNames ?? 'Administrator');

    final unitName = liveProfile?.unitName.isNotEmpty == true
        ? liveProfile!.unitName
        : (loginData?.unitName ?? '');

    final locationName = liveProfile?.locationName.isNotEmpty == true
        ? liveProfile!.locationName
        : (loginData?.locationName ?? '');

    final email = liveProfile?.email.isNotEmpty == true
        ? liveProfile!.email
        : (loginData?.userName.contains('@') == true ? loginData!.userName : '');

    final mobile = liveProfile?.mobile ?? '';
    final address = liveProfile?.address ?? '';
    final staffNo = liveProfile?.staffNo.isNotEmpty == true
        ? liveProfile!.staffNo
        : (loginData?.staffId.toString() ?? '');

    final initials = _getInitials(staffName, loginData?.userName ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Contact Details',
            onPressed: () => EditProfileDialog.show(
              context,
              currentEmail: email,
              currentMobile: mobile,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Profile',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              if (profileProvider.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(),
                ),

              // Profile Header Card
              ProfileHeaderCard(
                name: staffName,
                role: roleName,
                unitName: unitName,
                locationName: locationName,
                status: liveProfile?.status ?? 'Active',
                initials: initials,
              ),

              const SizedBox(height: 20),

              // Contact Details Card
              ProfileSectionCard(
                title: 'Contact Information',
                icon: Icons.contact_mail_outlined,
                items: [
                  ProfileInfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email Address',
                    value: email,
                    onTap: () => EditProfileDialog.show(
                      context,
                      currentEmail: email,
                      currentMobile: mobile,
                    ),
                  ),
                  ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Mobile Number',
                    value: mobile,
                    onTap: () => EditProfileDialog.show(
                      context,
                      currentEmail: email,
                      currentMobile: mobile,
                    ),
                  ),
                  if (address.isNotEmpty)
                    ProfileInfoTile(
                      icon: Icons.home_outlined,
                      label: 'Office / Depot Address',
                      value: address,
                    ),
                ],
              ),

              // Staff & Assignment Card
              ProfileSectionCard(
                title: 'Employment & Role',
                icon: Icons.badge_outlined,
                items: [
                  ProfileInfoTile(
                    icon: Icons.numbers,
                    label: 'Staff ID / Number',
                    value: staffNo,
                  ),
                  ProfileInfoTile(
                    icon: Icons.work_outline,
                    label: 'Designation',
                    value: liveProfile?.designationName.isNotEmpty == true
                        ? liveProfile!.designationName
                        : roleName,
                  ),
                  ProfileInfoTile(
                    icon: Icons.business_outlined,
                    label: 'Assigned Unit',
                    value: unitName,
                  ),
                  ProfileInfoTile(
                    icon: Icons.pin_drop_outlined,
                    label: 'Depot Location',
                    value: locationName,
                  ),
                  if (liveProfile?.vendorName.isNotEmpty == true)
                    ProfileInfoTile(
                      icon: Icons.domain,
                      label: 'Organization / Vendor',
                      value: liveProfile!.vendorName,
                    ),
                ],
              ),

              // Account & Security Card
              ProfileSectionCard(
                title: 'Account Security',
                icon: Icons.security_outlined,
                items: [
                  ProfileInfoTile(
                    icon: Icons.account_circle_outlined,
                    label: 'Username',
                    value: loginData?.userName ?? '—',
                  ),
                  ProfileInfoTile(
                    icon: Icons.schedule_outlined,
                    label: 'Last Login',
                    value: loginData?.lastLogin ?? '—',
                  ),
                  ProfileInfoTile(
                    icon: Icons.verified_user_outlined,
                    label: 'Session ID',
                    value: loginData?.userSessionId.toString().isNotEmpty == true
                        ? '#${loginData!.userSessionId}'
                        : 'Active',
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Logout Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Log Out from System',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
