import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/hiit_workout_controller.dart';
import '../../core/veltrox_theme.dart';

class PerformanceStatsScreen extends StatelessWidget {
  const PerformanceStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HiitWorkoutController>();
    final history = controller.history;

    // Calculate weekly distribution
    final now = DateTime.now();
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekTotals = List<int>.filled(7, 0);

    for (final s in history) {
      final diff = now.difference(s.timestamp).inDays;
      if (diff < 7) {
        final weekdayIndex = s.timestamp.weekday - 1; // 0=Mon, 6=Sun
        weekTotals[weekdayIndex] += s.caloriesBurned;
      }
    }

    final maxVal = weekTotals.fold<int>(0, (prev, curr) => curr > prev ? curr : prev);
    final maxChartVal = maxVal == 0 ? 100 : maxVal;

    int totalBurn = history.fold(0, (acc, h) => acc + h.caloriesBurned);
    int totalMins = history.fold(0, (acc, h) => acc + (h.totalDurationSeconds ~/ 60));
    double avgBurn = history.isEmpty ? 0 : (totalBurn / history.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CARDIO PERFORMANCE & STATS'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Weekly Cardio Volume Chart Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'WEEKLY CALORIC BURN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                              color: VeltroxColors.textBright,
                            ),
                          ),
                          Text(
                            '${weekTotals.fold(0, (a, b) => a + b)} kcal this week',
                            style: const TextStyle(
                              fontSize: 12,
                              color: VeltroxColors.neonRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Bar Chart Graphic
                      SizedBox(
                        height: 160,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(7, (i) {
                            final val = weekTotals[i];
                            final barHeightFraction = (val / maxChartVal).clamp(0.06, 1.0);
                            final isToday = (i == (now.weekday - 1));

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (val > 0)
                                  Text(
                                    '$val',
                                    style: const TextStyle(fontSize: 10, color: VeltroxColors.electricCyan, fontWeight: FontWeight.w700),
                                  ),
                                const SizedBox(height: 4),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 22,
                                  height: 110 * barHeightFraction,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    gradient: LinearGradient(
                                      colors: isToday
                                          ? [VeltroxColors.neonRed, const Color(0xFFFF6584)]
                                          : [VeltroxColors.electricCyan, const Color(0xFF0091EA)],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    boxShadow: val > 0
                                        ? [
                                            BoxShadow(
                                              color: (isToday ? VeltroxColors.neonRed : VeltroxColors.electricCyan).withAlpha(80),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  dayNames[i],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                                    color: isToday ? VeltroxColors.neonRed : VeltroxColors.textMuted,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // KPI Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'TOTAL BURN',
                      '$totalBurn kcal',
                      Icons.local_fire_department,
                      VeltroxColors.neonRed,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      'SWEAT DURATION',
                      '${totalMins}m',
                      Icons.alarm,
                      VeltroxColors.electricCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      'AVG BURN/RUN',
                      '${avgBurn.round()} kcal',
                      Icons.trending_up,
                      VeltroxColors.amberWarning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      'CONSISTENCY',
                      history.length >= 3 ? 'STRONG 🔥' : 'ACTIVE',
                      Icons.military_tech,
                      VeltroxColors.emeraldSuccess,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Achievements Section
              const Text(
                'ENDURANCE MILESTONES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: VeltroxColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              _buildBadgeTile(
                title: 'Tabata Titan',
                subtitle: 'Completed 8 high-speed intervals with zero pauses',
                unlocked: history.any((h) => h.setsCompleted >= 8),
                icon: Icons.flash_on,
              ),
              const SizedBox(height: 8),
              _buildBadgeTile(
                title: 'Calorie Torch 100',
                subtitle: 'Burned more than 100 kcal in a single session',
                unlocked: history.any((h) => h.caloriesBurned >= 100),
                icon: Icons.whatshot,
              ),
              const SizedBox(height: 8),
              _buildBadgeTile(
                title: 'Iron Lungs',
                subtitle: 'Logged 3 or more HIIT sessions in your logbook',
                unlocked: history.length >= 3,
                icon: Icons.fitness_center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VeltroxColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VeltroxColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: VeltroxColors.textBright,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: VeltroxColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeTile({
    required String title,
    required String subtitle,
    required bool unlocked,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? VeltroxColors.surfaceElevated : VeltroxColors.cardSurface.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? VeltroxColors.neonRed.withAlpha(120) : VeltroxColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked ? VeltroxColors.neonRed.withAlpha(40) : Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: unlocked ? VeltroxColors.neonRed : VeltroxColors.textDim,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? VeltroxColors.textBright : VeltroxColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: VeltroxColors.textDim,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: VeltroxColors.electricCyan, size: 20)
          else
            const Icon(Icons.lock_outline, color: VeltroxColors.textDim, size: 20),
        ],
      ),
    );
  }
}
