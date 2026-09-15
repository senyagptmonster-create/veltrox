import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/hiit_workout_controller.dart';
import '../../core/veltrox_theme.dart';

class CustomRoutineScreen extends StatefulWidget {
  const CustomRoutineScreen({super.key});

  @override
  State<CustomRoutineScreen> createState() => _CustomRoutineScreenState();
}

class _CustomRoutineScreenState extends State<CustomRoutineScreen> {
  void _openRoutineCreator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: VeltroxColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _RoutineDesignerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HiitWorkoutController>();
    final routines = controller.routines;
    final active = controller.activeRoutine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('INTERVAL DESIGNER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: VeltroxColors.neonRed),
            onPressed: () => _openRoutineCreator(context),
            tooltip: 'Create Routine',
          ),
        ],
      ),
      body: routines.isEmpty
          ? const Center(child: Text('No routines found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                final isActive = routine.id == active.id;
                final totalSeconds = (routine.workSeconds + routine.restSeconds) * routine.totalSets + routine.prepSeconds;
                final minutes = totalSeconds ~/ 60;
                final secs = totalSeconds % 60;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isActive ? VeltroxColors.surfaceElevated : VeltroxColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? VeltroxColors.neonRed : VeltroxColors.borderSubtle,
                      width: isActive ? 1.8 : 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: VeltroxColors.neonRed.withAlpha(40),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                routine.tag.toUpperCase(),
                                style: const TextStyle(
                                  color: VeltroxColors.neonRed,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                routine.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: VeltroxColors.textBright,
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: VeltroxColors.electricCyan.withAlpha(40),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    color: VeltroxColors.electricCyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          routine.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: VeltroxColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniParam('WORK', '${routine.workSeconds}s', VeltroxColors.neonRed),
                            _buildMiniParam('REST', '${routine.restSeconds}s', VeltroxColors.electricCyan),
                            _buildMiniParam('SETS', '${routine.totalSets}', VeltroxColors.amberWarning),
                            _buildMiniParam('EST TIME', '${minutes}m ${secs}s', VeltroxColors.textMuted),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: VeltroxColors.borderSubtle, height: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (!routine.id.startsWith('tabata_') &&
                                !routine.id.startsWith('emom_') &&
                                !routine.id.startsWith('pyramid_') &&
                                !routine.id.startsWith('endurance_'))
                              TextButton.icon(
                                onPressed: () => controller.removeCustomRoutine(routine.id),
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                label: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                                ),
                              ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: isActive ? null : () => controller.selectRoutine(routine),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: VeltroxColors.neonRed,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: VeltroxColors.borderSubtle,
                                disabledForegroundColor: VeltroxColors.textMuted,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(isActive ? 'Current Selected' : 'Load Routine'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRoutineCreator(context),
        backgroundColor: VeltroxColors.neonRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('CUSTOM INTERVAL', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildMiniParam(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: VeltroxColors.textDim,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _RoutineDesignerSheet extends StatefulWidget {
  const _RoutineDesignerSheet();

  @override
  State<_RoutineDesignerSheet> createState() => _RoutineDesignerSheetState();
}

class _RoutineDesignerSheetState extends State<_RoutineDesignerSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedTag = 'Tabata';
  double _workSeconds = 30;
  double _restSeconds = 15;
  double _sets = 8;
  double _prepSeconds = 5;

  final List<String> _tags = ['Tabata', 'EMOM', 'Pyramid', 'Sprint', 'Core'];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim().isEmpty ? 'Custom Interval' : _titleController.text.trim();
    final desc = _descController.text.trim().isEmpty ? '$_selectedTag interval session' : _descController.text.trim();

    final routine = IntervalRoutine(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: desc,
      workSeconds: _workSeconds.toInt(),
      restSeconds: _restSeconds.toInt(),
      totalSets: _sets.toInt(),
      prepSeconds: _prepSeconds.toInt(),
      tag: _selectedTag,
    );

    context.read<HiitWorkoutController>().addCustomRoutine(routine);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = ((_workSeconds + _restSeconds) * _sets + _prepSeconds).toInt();
    final mins = totalDuration ~/ 60;
    final secs = totalDuration % 60;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: VeltroxColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'CUSTOM ROUTINE ARCHITECT',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: VeltroxColors.textBright,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Routine Title',
                hintText: 'e.g. Pyramid Inferno',
                filled: true,
                fillColor: VeltroxColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description / Goal',
                hintText: 'e.g. Target leg stamina and peak heart rate',
                filled: true,
                fillColor: VeltroxColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('INTERVAL PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: VeltroxColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedTag = tag);
                  },
                  selectedColor: VeltroxColors.neonRed.withAlpha(60),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Work Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_workSeconds.toInt()}s', style: const TextStyle(color: VeltroxColors.neonRed, fontWeight: FontWeight.w800)),
              ],
            ),
            Slider(
              value: _workSeconds,
              min: 10,
              max: 90,
              divisions: 16,
              activeColor: VeltroxColors.neonRed,
              onChanged: (val) => setState(() => _workSeconds = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rest Duration:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_restSeconds.toInt()}s', style: const TextStyle(color: VeltroxColors.electricCyan, fontWeight: FontWeight.w800)),
              ],
            ),
            Slider(
              value: _restSeconds,
              min: 5,
              max: 60,
              divisions: 11,
              activeColor: VeltroxColors.electricCyan,
              onChanged: (val) => setState(() => _restSeconds = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Sets:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_sets.toInt()} sets', style: const TextStyle(color: VeltroxColors.amberWarning, fontWeight: FontWeight.w800)),
              ],
            ),
            Slider(
              value: _sets,
              min: 2,
              max: 20,
              divisions: 18,
              activeColor: VeltroxColors.amberWarning,
              onChanged: (val) => setState(() => _sets = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preparation Countdown:', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_prepSeconds.toInt()}s', style: const TextStyle(color: VeltroxColors.textBright, fontWeight: FontWeight.w800)),
              ],
            ),
            Slider(
              value: _prepSeconds,
              min: 3,
              max: 15,
              divisions: 12,
              activeColor: VeltroxColors.textMuted,
              onChanged: (val) => setState(() => _prepSeconds = val),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VeltroxColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Workout Time:', style: TextStyle(color: VeltroxColors.textMuted)),
                  Text(
                    '${mins}m ${secs}s',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: VeltroxColors.textBright),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeltroxColors.neonRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('SAVE & REGISTER ROUTINE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
