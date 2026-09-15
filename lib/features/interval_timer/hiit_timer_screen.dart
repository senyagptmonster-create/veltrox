import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/hiit_workout_controller.dart';
import '../../core/veltrox_theme.dart';

class HiitTimerScreen extends StatelessWidget {
  const HiitTimerScreen({super.key});

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color _getPhaseColor(IntervalPhase phase) {
    switch (phase) {
      case IntervalPhase.work:
        return VeltroxColors.neonRed;
      case IntervalPhase.rest:
        return VeltroxColors.electricCyan;
      case IntervalPhase.prep:
        return VeltroxColors.amberWarning;
      case IntervalPhase.complete:
        return VeltroxColors.emeraldSuccess;
      case IntervalPhase.idle:
        return VeltroxColors.textMuted;
    }
  }

  String _getPhaseTitle(IntervalPhase phase) {
    switch (phase) {
      case IntervalPhase.work:
        return 'WORK BLAST';
      case IntervalPhase.rest:
        return 'ACTIVE RECOVERY';
      case IntervalPhase.prep:
        return 'GET READY';
      case IntervalPhase.complete:
        return 'SESSION CRUSHED!';
      case IntervalPhase.idle:
        return 'READY TO IGNITE';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HiitWorkoutController>();
    final active = controller.activeRoutine;
    final phaseColor = _getPhaseColor(controller.phase);

    return Scaffold(
      appBar: AppBar(
        title: const Text('INTERVAL PACE ENGINE'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: VeltroxColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: VeltroxColors.borderSubtle),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: VeltroxColors.neonRed, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${controller.estimatedCaloriesBurned} kcal',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Routine selector bar
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.routines.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final routine = controller.routines[index];
                    final isSelected = routine.id == active.id;
                    return ChoiceChip(
                      label: Text(routine.title),
                      selected: isSelected,
                      onSelected: controller.isRunning
                          ? null
                          : (selected) {
                              if (selected) controller.selectRoutine(routine);
                            },
                      selectedColor: VeltroxColors.neonRed.withAlpha(60),
                      backgroundColor: VeltroxColors.cardSurface,
                      labelStyle: TextStyle(
                        color: isSelected ? VeltroxColors.neonRed : VeltroxColors.textMuted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: isSelected ? VeltroxColors.neonRed : VeltroxColors.borderSubtle,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Phase Banner & Routine Tag
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: phaseColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: phaseColor, width: 1.5),
                      ),
                      child: Text(
                        _getPhaseTitle(controller.phase),
                        style: TextStyle(
                          color: phaseColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${active.title} • Set ${controller.currentSet} of ${active.totalSets}',
                      style: const TextStyle(
                        color: VeltroxColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Massive Timer Ring Display
              Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: controller.phaseProgress,
                          strokeWidth: 12,
                          backgroundColor: VeltroxColors.surfaceElevated,
                          valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.secondsLeftInPhase.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontSize: 74,
                              fontWeight: FontWeight.w900,
                              color: phaseColor,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.phase == IntervalPhase.work
                                ? 'WORK INTENSITY'
                                : (controller.phase == IntervalPhase.rest ? 'DEEP BREATHS' : 'SECONDS LEFT'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: VeltroxColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Sets Progress Indicator Dots
              Center(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: List.generate(active.totalSets, (index) {
                    final setNum = index + 1;
                    final isDone = setNum < controller.currentSet || controller.phase == IntervalPhase.complete;
                    final isCurrent = setNum == controller.currentSet && controller.phase != IntervalPhase.complete;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isCurrent ? 28 : 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDone
                            ? VeltroxColors.neonRed
                            : (isCurrent ? VeltroxColors.electricCyan : VeltroxColors.surfaceElevated),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrent ? Colors.white : VeltroxColors.borderSubtle,
                        ),
                      ),
                      child: isDone
                          ? const Center(
                              child: Icon(Icons.check, size: 10, color: Colors.white),
                            )
                          : null,
                    );
                  }),
                ),
              ),

              const SizedBox(height: 28),

              // Metric Dashboard Cards
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      label: 'TOTAL TIME',
                      value: _formatDuration(controller.totalElapsedSeconds),
                      icon: Icons.timer_outlined,
                      accentColor: VeltroxColors.electricCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile(
                      label: 'WORK / REST',
                      value: '${active.workSeconds}s / ${active.restSeconds}s',
                      icon: Icons.speed,
                      accentColor: VeltroxColors.neonRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Main Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton.filledTonal(
                    onPressed: controller.resetWorkout,
                    style: IconButton.styleFrom(
                      backgroundColor: VeltroxColors.surfaceElevated,
                      foregroundColor: VeltroxColors.textBright,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.replay, size: 24),
                  ),
                  const SizedBox(width: 20),

                  // Big Play/Pause Button
                  ElevatedButton(
                    onPressed: () {
                      if (controller.isRunning) {
                        controller.pauseWorkout();
                      } else {
                        controller.startWorkout();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isRunning ? VeltroxColors.amberWarning : VeltroxColors.neonRed,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: (controller.isRunning ? VeltroxColors.amberWarning : VeltroxColors.neonRed).withAlpha(120),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(controller.isRunning ? Icons.pause : Icons.play_arrow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          controller.isRunning ? 'PAUSE' : (controller.phase == IntervalPhase.idle ? 'START PACE' : 'RESUME'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Skip Interval Button
                  IconButton.filledTonal(
                    onPressed: controller.skipInterval,
                    style: IconButton.styleFrom(
                      backgroundColor: VeltroxColors.surfaceElevated,
                      foregroundColor: VeltroxColors.electricCyan,
                      padding: const EdgeInsets.all(16),
                    ),
                    icon: const Icon(Icons.skip_next, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: VeltroxColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VeltroxColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: VeltroxColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: VeltroxColors.textBright,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
