// Widget Test for VeltroApp (Desktop and Mobile Viewports)
// Path: test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veltro/main.dart';

void main() {
  testWidgets('Veltro app loads and renders desktop navigation shell', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VeltroApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Alex'), findsOneWidget);
    expect(find.text('PayPal Sandbox Account'), findsOneWidget);
  });

  testWidgets('Veltro app loads and renders mobile viewport with bottom navigation bar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VeltroApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Payments'), findsWidgets);
    expect(find.text('Shield'), findsWidgets);
    expect(find.text('WisePilot'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
