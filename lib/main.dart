// Veltro Application Entry Point
// Path: lib/main.dart

import 'package:flutter/material.dart';
import 'core/theme/veltro_theme.dart';
import 'presentation/widgets/veltro_navigation_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VeltroApp());
}

class VeltroApp extends StatelessWidget {
  const VeltroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veltro — Intelligent Global Payments & Anti-Scam Platform',
      debugShowCheckedModeBanner: false,
      theme: VeltroTheme.lightTheme,
      home: const VeltroNavigationShell(),
    );
  }
}
