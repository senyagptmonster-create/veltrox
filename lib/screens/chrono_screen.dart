import 'dart:async';
import 'package:flutter/material.dart';
import '../painters/segmented_ring_timer_painter.dart';
import '../theme/veltrox_theme.dart';

class ChronoScreen extends StatefulWidget {
  const ChronoScreen({super.key});

  @override
  State<ChronoScreen> createState() => _ChronoScreenState();
}

class _ChronoScreenState extends State<ChronoScreen> {
  int _selectedMode = 0; // 0: Stopwatch, 1: Split Table, 2: Cadence Pacer

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _elapsedMs = 0;
  final List<int> _laps = [];

  // Cadence Pacer
  int _cadenceSpm = 175;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startStopwatch() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      setState(() {
        _elapsedMs = _stopwatch.elapsedMilliseconds;
      });
    });
  }

  void _pauseStopwatch() {
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    _timer?.cancel();
    setState(() {
      _elapsedMs = 0;
      _laps.clear();
    });
  }

  void _lapSplit() {
    if (_stopwatch.isRunning) {
      setState(() {
        _laps.insert(0, _elapsedMs);
      });
    }
  }

  String _formatTime(int ms) {
    final minutes = (ms ~/ 60000).toString().padLeft(2, '0');
    final seconds = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final hundredths = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$hundredths';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veltrox Sports Chrono'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top SegmentedButton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('Stopwatch')),
                  ButtonSegment(value: 1, label: Text('Laps')),
                  ButtonSegment(value: 2, label: Text('Cadence')),
                ],
                selected: {_selectedMode},
                onSelectionChanged: (val) => setState(() => _selectedMode = val.first),
              ),
            ),

            Expanded(
              child: _selectedMode == 0
                  ? _buildStopwatchView()
                  : _selectedMode == 1
                      ? _buildLapsView()
                      : _buildCadenceView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopwatchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Segmented Ring Dial CustomPaint
          SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: SegmentedRingTimerPainter(milliseconds: _elapsedMs),
            ),
          ),
          const SizedBox(height: 16),

          // Digital Readout
          Text(
            _formatTime(_elapsedMs),
            style: const TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontFamily: 'monospace',
              color: VeltroxTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 28),

          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: VeltroxTheme.textSecondary,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: _resetStopwatch,
                child: const Text('RESET'),
              ),
              const SizedBox(width: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _stopwatch.isRunning ? VeltroxTheme.crimson : VeltroxTheme.cyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: _stopwatch.isRunning ? _pauseStopwatch : _startStopwatch,
                child: Text(
                  _stopwatch.isRunning ? 'PAUSE' : 'START',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 14),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeltroxTheme.surface,
                  foregroundColor: VeltroxTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onPressed: _stopwatch.isRunning ? _lapSplit : null,
                child: const Text('LAP'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLapsView() {
    if (_laps.isEmpty) {
      return const Center(
        child: Text('No recorded split laps yet', style: TextStyle(color: VeltroxTheme.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(18),
      itemCount: _laps.length,
      separatorBuilder: (context, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final lapTime = _laps[i];
        final lapNum = _laps.length - i;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: VeltroxTheme.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lap #$lapNum', style: const TextStyle(fontWeight: FontWeight.bold, color: VeltroxTheme.textPrimary)),
              Text(_formatTime(lapTime), style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: VeltroxTheme.cyan)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCadenceView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: VeltroxTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Running Cadence Target', style: TextStyle(color: VeltroxTheme.textSecondary)),
                const SizedBox(height: 8),
                Text(
                  '$_cadenceSpm SPM',
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: VeltroxTheme.cyan),
                ),
                Slider(
                  value: _cadenceSpm.toDouble(),
                  min: 150,
                  max: 200,
                  divisions: 50,
                  activeColor: VeltroxTheme.cyan,
                  inactiveColor: Colors.white12,
                  onChanged: (val) => setState(() => _cadenceSpm = val.toInt()),
                ),
                const Text(
                  'Optimal distance running cadence is 170-180 strides per minute to minimize joint impact forces.',
                  style: TextStyle(fontSize: 12, color: VeltroxTheme.textSecondary, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
