import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum IntervalPhase { idle, prep, work, rest, complete }

class IntervalRoutine {
  final String id;
  final String title;
  final String description;
  final int workSeconds;
  final int restSeconds;
  final int totalSets;
  final int prepSeconds;
  final String tag;

  const IntervalRoutine({
    required this.id,
    required this.title,
    required this.description,
    required this.workSeconds,
    required this.restSeconds,
    required this.totalSets,
    this.prepSeconds = 5,
    required this.tag,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'workSeconds': workSeconds,
      'restSeconds': restSeconds,
      'totalSets': totalSets,
      'prepSeconds': prepSeconds,
      'tag': tag,
    };
  }

  factory IntervalRoutine.fromMap(Map<String, dynamic> map) {
    return IntervalRoutine(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      workSeconds: map['workSeconds'] as int,
      restSeconds: map['restSeconds'] as int,
      totalSets: map['totalSets'] as int,
      prepSeconds: map['prepSeconds'] as int? ?? 5,
      tag: map['tag'] as String? ?? 'General',
    );
  }
}

class WorkoutSessionRecord {
  final String id;
  final String routineTitle;
  final DateTime timestamp;
  final int totalDurationSeconds;
  final int setsCompleted;
  final int caloriesBurned;
  final String intensity;

  WorkoutSessionRecord({
    required this.id,
    required this.routineTitle,
    required this.timestamp,
    required this.totalDurationSeconds,
    required this.setsCompleted,
    required this.caloriesBurned,
    required this.intensity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routineTitle': routineTitle,
      'timestamp': timestamp.toIso8601String(),
      'totalDurationSeconds': totalDurationSeconds,
      'setsCompleted': setsCompleted,
      'caloriesBurned': caloriesBurned,
      'intensity': intensity,
    };
  }

  factory WorkoutSessionRecord.fromMap(Map<String, dynamic> map) {
    return WorkoutSessionRecord(
      id: map['id'] as String,
      routineTitle: map['routineTitle'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      totalDurationSeconds: map['totalDurationSeconds'] as int,
      setsCompleted: map['setsCompleted'] as int,
      caloriesBurned: map['caloriesBurned'] as int,
      intensity: map['intensity'] as String? ?? 'High',
    );
  }
}

class HiitWorkoutController extends ChangeNotifier {
  static const String _prefRoutinesKey = 'veltrox_custom_routines';
  static const String _prefHistoryKey = 'veltrox_history_records';

  final List<IntervalRoutine> _routines = [
    const IntervalRoutine(
      id: 'tabata_classic',
      title: 'Tabata Standard',
      description: 'Classic high-intensity 20s sprint with 10s recovery',
      workSeconds: 20,
      restSeconds: 10,
      totalSets: 8,
      prepSeconds: 5,
      tag: 'Tabata',
    ),
    const IntervalRoutine(
      id: 'emom_power',
      title: 'EMOM Sprint Circuit',
      description: 'Every minute on the minute high-power output intervals',
      workSeconds: 45,
      restSeconds: 15,
      totalSets: 10,
      prepSeconds: 10,
      tag: 'EMOM',
    ),
    const IntervalRoutine(
      id: 'pyramid_climb',
      title: 'Pyramid Pace Builder',
      description: 'Moderate recovery with progressive tempo challenge',
      workSeconds: 30,
      restSeconds: 15,
      totalSets: 6,
      prepSeconds: 5,
      tag: 'Pyramid',
    ),
    const IntervalRoutine(
      id: 'endurance_surge',
      title: 'Endurance Surge',
      description: 'Long steady engine building intervals',
      workSeconds: 40,
      restSeconds: 20,
      totalSets: 12,
      prepSeconds: 5,
      tag: 'Endurance',
    ),
  ];

  final List<WorkoutSessionRecord> _history = [];

  IntervalRoutine _activeRoutine = const IntervalRoutine(
    id: 'tabata_classic',
    title: 'Tabata Standard',
    description: 'Classic high-intensity 20s sprint with 10s recovery',
    workSeconds: 20,
    restSeconds: 10,
    totalSets: 8,
    prepSeconds: 5,
    tag: 'Tabata',
  );

  IntervalPhase _phase = IntervalPhase.idle;
  int _currentSet = 1;
  int _secondsLeftInPhase = 0;
  int _totalElapsedSeconds = 0;
  bool _isRunning = false;
  Timer? _ticker;

  List<IntervalRoutine> get routines => List.unmodifiable(_routines);
  List<WorkoutSessionRecord> get history => List.unmodifiable(_history);
  IntervalRoutine get activeRoutine => _activeRoutine;
  IntervalPhase get phase => _phase;
  int get currentSet => _currentSet;
  int get secondsLeftInPhase => _secondsLeftInPhase;
  int get totalElapsedSeconds => _totalElapsedSeconds;
  bool get isRunning => _isRunning;

  double get phaseProgress {
    int total = 1;
    switch (_phase) {
      case IntervalPhase.prep:
        total = _activeRoutine.prepSeconds;
        break;
      case IntervalPhase.work:
        total = _activeRoutine.workSeconds;
        break;
      case IntervalPhase.rest:
        total = _activeRoutine.restSeconds;
        break;
      case IntervalPhase.idle:
      case IntervalPhase.complete:
        return 1.0;
    }
    if (total <= 0) return 1.0;
    return (_secondsLeftInPhase / total).clamp(0.0, 1.0);
  }

  int get estimatedCaloriesBurned {
    // Approx 11 calories burned per work minute, 4 per rest minute
    final minutes = _totalElapsedSeconds / 60.0;
    return (minutes * 10.5).round();
  }

  HiitWorkoutController() {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customJson = prefs.getStringList(_prefRoutinesKey);
      if (customJson != null) {
        for (final item in customJson) {
          final map = jsonDecode(item) as Map<String, dynamic>;
          final routine = IntervalRoutine.fromMap(map);
          if (!_routines.any((r) => r.id == routine.id)) {
            _routines.add(routine);
          }
        }
      }

      final historyJson = prefs.getStringList(_prefHistoryKey);
      if (historyJson != null) {
        _history.clear();
        for (final item in historyJson) {
          final map = jsonDecode(item) as Map<String, dynamic>;
          _history.add(WorkoutSessionRecord.fromMap(map));
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persistRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customOnly = _routines.where((r) => !r.id.startsWith('tabata_') && !r.id.startsWith('emom_') && !r.id.startsWith('pyramid_') && !r.id.startsWith('endurance_')).map((r) => jsonEncode(r.toMap())).toList();
      await prefs.setStringList(_prefRoutinesKey, customOnly);
    } catch (_) {}
  }

  Future<void> _persistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _history.map((h) => jsonEncode(h.toMap())).toList();
      await prefs.setStringList(_prefHistoryKey, data);
    } catch (_) {}
  }

  void selectRoutine(IntervalRoutine routine) {
    if (_isRunning) return;
    _activeRoutine = routine;
    _resetSessionState();
    notifyListeners();
  }

  void addCustomRoutine(IntervalRoutine routine) {
    _routines.add(routine);
    _persistRoutines();
    notifyListeners();
  }

  void removeCustomRoutine(String id) {
    _routines.removeWhere((r) => r.id == id);
    if (_activeRoutine.id == id && _routines.isNotEmpty) {
      _activeRoutine = _routines.first;
    }
    _persistRoutines();
    notifyListeners();
  }

  void startWorkout() {
    if (_isRunning) return;
    if (_phase == IntervalPhase.idle || _phase == IntervalPhase.complete) {
      _resetSessionState();
      if (_activeRoutine.prepSeconds > 0) {
        _phase = IntervalPhase.prep;
        _secondsLeftInPhase = _activeRoutine.prepSeconds;
      } else {
        _phase = IntervalPhase.work;
        _secondsLeftInPhase = _activeRoutine.workSeconds;
      }
    }
    _isRunning = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void pauseWorkout() {
    _isRunning = false;
    _ticker?.cancel();
    notifyListeners();
  }

  void resumeWorkout() {
    if (_isRunning) return;
    _isRunning = true;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void resetWorkout() {
    _ticker?.cancel();
    _isRunning = false;
    _resetSessionState();
    notifyListeners();
  }

  void skipInterval() {
    if (!_isRunning && _phase == IntervalPhase.idle) return;
    _advancePhase();
    notifyListeners();
  }

  void _resetSessionState() {
    _phase = IntervalPhase.idle;
    _currentSet = 1;
    _secondsLeftInPhase = _activeRoutine.workSeconds;
    _totalElapsedSeconds = 0;
  }

  void _onTick(Timer timer) {
    _totalElapsedSeconds++;
    if (_secondsLeftInPhase > 1) {
      _secondsLeftInPhase--;
    } else {
      _advancePhase();
    }
    notifyListeners();
  }

  void _advancePhase() {
    switch (_phase) {
      case IntervalPhase.prep:
        _phase = IntervalPhase.work;
        _secondsLeftInPhase = _activeRoutine.workSeconds;
        break;
      case IntervalPhase.work:
        if (_currentSet >= _activeRoutine.totalSets) {
          _completeSession();
        } else {
          _phase = IntervalPhase.rest;
          _secondsLeftInPhase = _activeRoutine.restSeconds;
        }
        break;
      case IntervalPhase.rest:
        _currentSet++;
        _phase = IntervalPhase.work;
        _secondsLeftInPhase = _activeRoutine.workSeconds;
        break;
      case IntervalPhase.idle:
      case IntervalPhase.complete:
        break;
    }
  }

  void _completeSession() {
    _ticker?.cancel();
    _isRunning = false;
    _phase = IntervalPhase.complete;
    _secondsLeftInPhase = 0;

    final record = WorkoutSessionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      routineTitle: _activeRoutine.title,
      timestamp: DateTime.now(),
      totalDurationSeconds: _totalElapsedSeconds,
      setsCompleted: _activeRoutine.totalSets,
      caloriesBurned: estimatedCaloriesBurned,
      intensity: _activeRoutine.tag,
    );

    _history.insert(0, record);
    _persistHistory();
  }

  void clearHistory() {
    _history.clear();
    _persistHistory();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
