// turn_detector.dart — GPS heading-based directional turn detection.
//
// Tracks cumulative heading change between GPS position updates.
// When heading rotates beyond a threshold in a continuous direction,
// a turn event is recorded.
//
// Uses GPS heading (compass degrees 0–360) as the primary source.
// Gyroscope Z-axis is handled inside GpsService where sensor fusion happens.
//
// Thresholds:
//   • Turn detected:       heading delta ≥ 15° cumulative in one direction
//   • Sharp turn:          heading delta ≥ 45° in one continuous movement
//   • Reversal guard:      direction must stay consistent; reversal resets accumulator
//   • Speed guard:         no turns recorded below 8 km/h

class TurnDetector {
  // ─── Event counters ──────────────────────────────────────────────────────────
  int _leftTurnCount  = 0;
  int _rightTurnCount = 0;
  int _sharpTurnCount = 0;

  int get leftTurnCount  => _leftTurnCount;
  int get rightTurnCount => _rightTurnCount;
  int get sharpTurnCount => _sharpTurnCount;

  // ─── Internal state ──────────────────────────────────────────────────────────
  double?   _lastHeading;
  double    _cumulativeDelta = 0.0;
  int       _turnDirection   = 0; // -1=left, 0=none, 1=right
  DateTime? _lastMovement;

  // Cooldown to avoid counting same turn multiple times
  DateTime? _lastTurnEvent;
  static const Duration _turnCooldown = Duration(milliseconds: 2500);

  // Thresholds (degrees)
  static const double _turnThreshold      = 15.0;
  static const double _sharpTurnThreshold = 45.0;
  static const double _minSpeedKmh        = 8.0;

  // Stillness reset — if no movement for 2s, reset accumulator
  static const Duration _stillnessReset   = Duration(seconds: 2);

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Call on every GPS position update with heading in degrees (0–360) and speed.
  void processHeading(double headingDeg, double speedKmh, DateTime timestamp) {
    // Speed guard
    if (speedKmh < _minSpeedKmh) {
      _reset();
      return;
    }

    // Stillness reset
    if (_lastMovement != null &&
        timestamp.difference(_lastMovement!) > _stillnessReset) {
      _reset();
    }
    _lastMovement = timestamp;

    if (_lastHeading == null) {
      _lastHeading = headingDeg;
      return;
    }

    // Compute smallest angular delta (-180 to +180)
    double delta = headingDeg - _lastHeading!;
    if (delta > 180)  delta -= 360;
    if (delta < -180) delta += 360;

    _lastHeading = headingDeg;

    // Ignore tiny GPS heading noise (< 2°)
    if (delta.abs() < 2.0) return;

    final int direction = delta > 0 ? 1 : -1;

    if (_turnDirection == 0) {
      // First movement — establish direction
      _turnDirection   = direction;
      _cumulativeDelta = delta.abs();
    } else if (_turnDirection == direction) {
      // Continuing in same direction
      _cumulativeDelta += delta.abs();
    } else {
      // Reversed direction — check if we should record a turn first
      if (_cumulativeDelta >= _turnThreshold) {
        _recordTurn(_cumulativeDelta, timestamp);
      }
      // Reset accumulator with new direction
      _turnDirection   = direction;
      _cumulativeDelta = delta.abs();
    }

    // Check if accumulated turn is complete
    if (_cumulativeDelta >= _turnThreshold) {
      _recordTurn(_cumulativeDelta, timestamp);
      _reset(); // reset after recording
    }
  }

  void reset() => _reset();

  // ─── Private helpers ─────────────────────────────────────────────────────────

  void _reset() {
    _cumulativeDelta = 0.0;
    _turnDirection   = 0;
    _lastHeading     = null;
  }

  void _recordTurn(double totalDelta, DateTime timestamp) {
    // Debounce
    if (_lastTurnEvent != null &&
        timestamp.difference(_lastTurnEvent!) < _turnCooldown) {
      return;
    }

    final bool isSharp = totalDelta >= _sharpTurnThreshold;

    if (_turnDirection == -1) {
      _leftTurnCount++;
    } else {
      _rightTurnCount++;
    }

    if (isSharp) _sharpTurnCount++;

    _lastTurnEvent = timestamp;
  }

  void fullReset() {
    _leftTurnCount  = 0;
    _rightTurnCount = 0;
    _sharpTurnCount = 0;
    _reset();
    _lastTurnEvent = null;
    _lastMovement  = null;
  }
}
