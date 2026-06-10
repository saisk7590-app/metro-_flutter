import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_notifier.dart';
import '../constants/data.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_dropdown.dart';
import '../widgets/custom_input.dart';

class AMSUpdateScreen extends StatefulWidget {
  const AMSUpdateScreen({super.key});

  @override
  State<AMSUpdateScreen> createState() => _AMSUpdateScreenState();
}

class _AMSUpdateScreenState extends State<AMSUpdateScreen> {
  String depot = '';
  String trainNo = '';
  String section = '';
  String track = '';
  String status = '';

  final remarksController = TextEditingController();

  Color getStatusColor() {
    switch (status) {
      case 'Running':
        return Colors.green;

      case 'Idle':
        return Colors.orange;

      case 'Maintenance':
      case 'Failure':
        return Colors.red;

      default:
        return Theme.of(context).primaryColor;
    }
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: true,

        title: Text(
          'AMS CONTROL PANEL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            letterSpacing: 1,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              themeNotifier.toggleTheme();
            },
            icon: Icon(
              themeNotifier.isDark ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),

            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),

                border: Border.all(color: colors.outline),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// DEPOT
                  CustomDropdown(
                    key: const ValueKey('depot'),
                    label: 'Depot',
                    selectedValue: depot,
                    options: AppData.depots,
                    onChanged: (value) {
                      setState(() {
                        depot = value;

                        // Reset dependent fields
                        section = '';
                        track = '';
                      });
                    },
                  ),

                  /// TRAIN SET
                  CustomDropdown(
                    key: const ValueKey('train'),
                    label: 'Train Set',
                    selectedValue: trainNo,
                    options: AppData.trainsets,
                    keyboardEnabled: true,
                    onChanged: (value) {
                      setState(() {
                        trainNo = value;
                      });
                    },
                  ),

                  /// SECTION
                  CustomDropdown(
                    key: ValueKey('section_$depot'),
                    label: 'Section',
                    selectedValue: section,
                    options: depot.isEmpty ? [] : AppData.sections[depot] ?? [],
                    onChanged: (value) {
                      setState(() {
                        section = value;
                        track = '';

                        final trackList = AppData.tracks[depot]?[value] ?? [];

                        if (trackList.length == 1) {
                          track = trackList.first;
                        }
                      });
                    },
                  ),

                  /// MULTIPLE TRACKS → DROPDOWN
                  if (depot.isNotEmpty &&
                      section.isNotEmpty &&
                      ((AppData.tracks[depot]?[section]?.length ?? 0) > 1))
                    CustomDropdown(
                      key: ValueKey('track_${depot}_$section'),
                      label: 'Track',
                      selectedValue: track,
                      options: AppData.tracks[depot]?[section] ?? [],
                      keyboardEnabled: true,
                      onChanged: (value) {
                        setState(() {
                          track = value;
                        });
                      },
                    ),

                  /// SINGLE TRACK → AUTO DISPLAY
                  if (depot.isNotEmpty &&
                      section.isNotEmpty &&
                      ((AppData.tracks[depot]?[section]?.length ?? 0) == 1))
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Track',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colors.secondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// STATUS
                  CustomDropdown(
                    key: const ValueKey('status'),
                    label: 'Status',
                    selectedValue: status,
                    options: AppData.status,
                    onChanged: (value) {
                      setState(() {
                        status = value;
                      });
                    },
                  ),

                  /// REMARKS
                  CustomInput(
                    label: 'Remarks',
                    controller: remarksController,
                    placeholder: 'Optional notes...',
                    multiline: true,
                  ),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
                  CustomButton(
                    title: 'SAVE UPDATE',
                    backgroundColor: getStatusColor(),
                    onPressed: () {
                      debugPrint('Depot: $depot');
                      debugPrint('Train: $trainNo');
                      debugPrint('Section: $section');
                      debugPrint('Track: $track');
                      debugPrint('Status: $status');
                      debugPrint('Remarks: ${remarksController.text}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
