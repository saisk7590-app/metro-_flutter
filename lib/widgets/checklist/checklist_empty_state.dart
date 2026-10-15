import 'package:flutter/material.dart';

class ChecklistEmptyState extends StatelessWidget {
  final VoidCallback onResetFilters;

  const ChecklistEmptyState({
    super.key,
    required this.onResetFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Website banner matching: <span class="bg-warning text-center fw-bold">CheckList Details not found</span>
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withValues(alpha: 0.2), // Warning amber
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFC107), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD39E00),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CheckList Details not found',
                    style: TextStyle(
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No checklists match your selected filters (Category, JobPlan, Checklist, Status).',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Reset Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D25B), // NxAMS theme green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: onResetFilters,
            ),
          ],
        ),
      ),
    );
  }
}
