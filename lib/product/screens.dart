import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/brand.dart';
import 'veltrox_store.dart';

class VeltroxHome extends StatefulWidget {
  const VeltroxHome({super.key});

  @override
  State<VeltroxHome> createState() => _VeltroxHomeState();
}

class _VeltroxHomeState extends State<VeltroxHome> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cBg,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          IntervalTimerScreen(),
          RoutineBuilderScreen(),
          SessionHistoryScreen(),
          PerformanceStatsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cSurface,
        selectedItemColor: cAccent,
        unselectedItemColor: cInk.withValues(alpha: 0.5),
        currentIndex: _currentIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Routines'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}

class IntervalTimerScreen extends StatelessWidget {
  const IntervalTimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VeltroxStore>();
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('INTERVAL TIMER', style: AppTheme.display(cAccent)),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cEdge, width: 4),
              ),
              child: Text(
                '${store.timeRemaining}',
                style: AppTheme.display(cInk).copyWith(fontSize: 48),
              ),
            ),
            const SizedBox(height: 20),
            Text('Set: ${store.currentSet} / ${store.totalSets}', style: AppTheme.text(cInk)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(store.isRunning ? Icons.pause : Icons.play_arrow, color: cAccent, size: 40),
                  onPressed: store.toggleTimer,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.stop, color: cAccent2, size: 40),
                  onPressed: store.stopTimer,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RoutineBuilderScreen extends StatelessWidget {
  const RoutineBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Routine Builder', style: AppTheme.display(cAccent)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    tileColor: cSurface,
                    title: Text('HIIT Basics', style: AppTheme.text(cInk)),
                    subtitle: Text('30s Work / 15s Rest', style: AppTheme.text(cInk.withValues(alpha: 0.7))),
                    trailing: const Icon(Icons.edit, color: cAccent2),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    tileColor: cSurface,
                    title: Text('Tabata', style: AppTheme.text(cInk)),
                    subtitle: Text('20s Work / 10s Rest', style: AppTheme.text(cInk.withValues(alpha: 0.7))),
                    trailing: const Icon(Icons.edit, color: cAccent2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SessionHistoryScreen extends StatelessWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('History', style: AppTheme.display(cAccent)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    color: cSurface,
                    child: ListTile(
                      title: Text('Yesterday', style: AppTheme.text(cInk)),
                      subtitle: Text('Tabata - 20 mins', style: AppTheme.text(cInk.withValues(alpha: 0.7))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceStatsScreen extends StatelessWidget {
  const PerformanceStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stats', style: AppTheme.display(cAccent)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: cSurface, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('Total Workouts: 42', style: AppTheme.text(cInk)),
                  const SizedBox(height: 10),
                  Text('Total Minutes: 480', style: AppTheme.text(cInk)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
