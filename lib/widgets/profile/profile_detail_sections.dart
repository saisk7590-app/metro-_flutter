import 'package:flutter/material.dart';
import 'profile_info_tiles.dart';

class ProfileDetailSections extends StatelessWidget {
  final String email;
  final String mobile;
  final String address;
  final String staffNo;
  final String designation;
  final String unitName;
  final String locationName;
  final String vendorName;
  final String username;
  final String lastLogin;
  final String sessionId;
  final VoidCallback onEditContact;

  const ProfileDetailSections({
    super.key,
    required this.email,
    required this.mobile,
    required this.address,
    required this.staffNo,
    required this.designation,
    required this.unitName,
    required this.locationName,
    required this.vendorName,
    required this.username,
    required this.lastLogin,
    required this.sessionId,
    required this.onEditContact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Contact Details Card
        ProfileSectionCard(
          title: 'Contact Information',
          icon: Icons.contact_mail_outlined,
          items: [
            ProfileInfoTile(
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: email,
              onTap: onEditContact,
            ),
            ProfileInfoTile(
              icon: Icons.phone_outlined,
              label: 'Mobile Number',
              value: mobile,
              onTap: onEditContact,
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
              value: designation,
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
            if (vendorName.isNotEmpty)
              ProfileInfoTile(
                icon: Icons.domain,
                label: 'Organization / Vendor',
                value: vendorName,
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
              value: username,
            ),
            ProfileInfoTile(
              icon: Icons.schedule_outlined,
              label: 'Last Login',
              value: lastLogin,
            ),
            ProfileInfoTile(
              icon: Icons.verified_user_outlined,
              label: 'Session ID',
              value: sessionId,
            ),
          ],
        ),
      ],
    );
  }
}
