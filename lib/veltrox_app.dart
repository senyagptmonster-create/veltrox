import 'package:flutter/material.dart';
import 'screens/chrono_screen.dart';
import 'theme/veltrox_theme.dart';

class VeltroxApp extends StatelessWidget {
  const VeltroxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veltrox Sports Chrono',
      debugShowCheckedModeBanner: false,
      theme: VeltroxTheme.themeData,
      home: const ChronoScreen(),
    );
  }
}
