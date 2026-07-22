import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:metro_flutter/widgets/custom_dropdown.dart';

void main() {
  testWidgets('CustomDropdown opens options without throwing an assertion', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomDropdown(
            label: 'Train Number',
            selectedValue: '',
            options: const ['TS01', 'TS02', 'TS03'],
            onChanged: (_) {},
            keyboardEnabled: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pump();

    expect(find.text('TS01'), findsOneWidget);
  });
}
