import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/hiit_workout_controller.dart';
import '../../core/veltrox_theme.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  String _filter = 'All';

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$min';
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HiitWorkoutController>();
    final history = controller.history;

    int totalMinutes = 0;
    int totalBurn = 0;

    for (final s in history) {
      totalMinutes += (s.totalDurationSeconds ~/ 60);
      totalBurn += s.caloriesBurned;
    }

    final filtered = history.where((s) {
      if (_filter == 'All') return true;
      if (_filter == 'High Burn') return s.caloriesBurned >= 80;
      return s.intensity.toLowerCase() == _filter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SESSION LOGBOOK'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: VeltroxColors.textMuted),
              tooltip: 'Clear Log',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: VeltroxColors.cardSurface,
                    title: const Text('Clear All Session Records?'),
                    content: const Text('This will permanently erase all completed workout history records.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: VeltroxColors.neonRed),
                        onPressed: () {
                          controller.clearHistory();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Clear All', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Summary Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    VeltroxColors.cardSurface,
                    VeltroxColors.surfaceElevated,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: VeltroxColors.borderSubtle),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('WORKOUTS', '${history.length}', VeltroxColors.textBright),
                  _buildDivider(),
                  _buildStatItem('SWEAT MINS', '$totalMinutes', VeltroxColors.electricCyan),
                  _buildDivider(),
                  _buildStatItem('TOTAL BURN', '$totalBurn kcal', VeltroxColors.neonRed),
                ],
              ),
            ),

            // Filter Chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: ['All', 'High Burn', 'Tabata', 'EMOM', 'Pyramid'].map((f) {
                  final isSelected = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _filter = f);
                      },
                      selectedColor: VeltroxColors.neonRed.withAlpha(40),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? VeltroxColors.neonRed : VeltroxColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // History List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center, size: 64, color: VeltroxColors.textDim),
                          const SizedBox(height: 12),
                          const Text(
                            'No completed sessions logged yet',
                            style: TextStyle(
                              color: VeltroxColors.textMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Complete an interval workout to see performance data',
                            style: TextStyle(color: VeltroxColors.textDim, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final session = filtered[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      session.routineTitle,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: VeltroxColors.textBright,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: VeltroxColors.electricCyan.withAlpha(30),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        session.intensity,
                                        style: const TextStyle(
                                          color: VeltroxColors.electricCyan,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(session.timestamp),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: VeltroxColors.textDim,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _buildDetailBadge(
                                      Icons.timer_outlined,
                                      _formatDuration(session.totalDurationSeconds),
                                      VeltroxColors.textMuted,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildDetailBadge(
                                      Icons.check_circle_outline,
                                      '${session.setsCompleted} Sets',
                                      VeltroxColors.amberWarning,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildDetailBadge(
                                      Icons.local_fire_department,
                                      '${session.caloriesBurned} kcal',
                                      VeltroxColors.neonRed,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: VeltroxColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: VeltroxColors.borderSubtle,
    );
  }

  Widget _buildDetailBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: VeltroxColors.textBright,
          ),
        ),
      ],
    );
  }
}
