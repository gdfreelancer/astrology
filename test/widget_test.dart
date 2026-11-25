import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:astrology/app.dart';

void main() {
  testWidgets('shows the Saral Jyotish app identity', (tester) async {
    await tester.pumpWidget(const AstrologyApp());

    expect(find.text('Saral Jyotish'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
