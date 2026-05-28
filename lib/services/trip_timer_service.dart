// trip_timer_service.dart — Drift-free live trip stopwatch.
//
// Uses Dart's Stopwatch for accurate elapsed-time tracking (no Timer drift).
// A periodic Timer triggers UI notification every second.
//
// Lifecycle:
//   start()  → called when GpsService.startTelemetry() fires
//   stop()   → called when GpsService.stopTelemetry() fires
//   reset()  → called to clear elapsed before a new trip

import 'dart:async';
import 'package:flutter/foundation.dart';

class TripTimerService extends ChangeNotifier {
  static final TripTimerService _instance = TripTimerService._internal();
  factory TripTimerService() => _instance;
  TripTimerService._internal();

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;

  // ─── Public state ─────────────────────────────────────────────────────────

  bool get isRunning => _stopwatch.isRunning;

  Duration get elapsed => _stopwatch.elapsed;

  int get elapsedSeconds => _stopwatch.elapsed.inSeconds;

  /// Formatted as MM:SS for trips < 1 hour, or HH:MM:SS for longer trips.
  String get formattedTime {
    final Duration d = _stopwatch.elapsed;
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:'
             '${m.toString().padLeft(2, '0')}:'
             '${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:'
           '${s.toString().padLeft(2, '0')}';
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  void start() {
    if (_stopwatch.isRunning) return;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  void stop() {
    _stopwatch.stop();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
