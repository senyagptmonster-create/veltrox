import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/hiit_workout_controller.dart';
import 'core/veltrox_theme.dart';
import 'features/interval_timer/hiit_timer_screen.dart';
import 'features/routine_builder/custom_routine_screen.dart';
import 'features/history/session_history_screen.dart';
import 'features/stats/performance_stats_screen.dart';

class VeltroxApp extends StatelessWidget {
  const VeltroxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HiitWorkoutController(),
      child: MaterialApp(
        title: 'Veltrox Interval Timer',
        debugShowCheckedModeBanner: false,
        theme: VeltroxTheme.darkTheme,
        home: const VeltroxMainNavigation(),
      ),
    );
  }
}

class VeltroxMainNavigation extends StatefulWidget {
  const VeltroxMainNavigation({super.key});

  @override
  State<VeltroxMainNavigation> createState() => _VeltroxMainNavigationState();
}

class _VeltroxMainNavigationState extends State<VeltroxMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HiitTimerScreen(),
    CustomRoutineScreen(),
    SessionHistoryScreen(),
    PerformanceStatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer, color: VeltroxColors.neonRed),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune, color: VeltroxColors.neonRed),
            label: 'Routines',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: VeltroxColors.neonRed),
            label: 'Logbook',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: VeltroxColors.neonRed),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
