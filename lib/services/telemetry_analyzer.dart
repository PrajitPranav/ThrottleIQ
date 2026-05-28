// telemetry_analyzer.dart — Real-time acceleration & braking detection engine.
//
// Uses Δv/Δt between consecutive speed samples to detect:
//   • Aggressive acceleration (>3.5 m/s²)
//   • Smooth acceleration (0.8–3.5 m/s²)
//   • Harsh braking (<−3.0 m/s²)
//   • Smooth braking (−0.5 to −3.0 m/s²)
//
// All thresholds are debounced to avoid counting the same event burst
// multiple times. No fake data — pure telemetry math.

class TelemetryAnalyzer {
  // ─── Event counters ──────────────────────────────────────────────────────────
  int _aggressiveAccelCount = 0;
  int _smoothAccelCount     = 0;
  int _harshBrakingCount    = 0;
  int _smoothBrakingCount   = 0;

  int get aggressiveAccelCount => _aggressiveAccelCount;
  int get smoothAccelCount     => _smoothAccelCount;
  int get harshBrakingCount    => _harshBrakingCount;
  int get smoothBrakingCount   => _smoothBrakingCount;

  // ─── Live state ──────────────────────────────────────────────────────────────
  double _currentAccelMs2 = 0.0;
  bool   _isAccelerating  = false;
  bool   _isBraking       = false;

  double get currentAccelMs2 => _currentAccelMs2;
  bool   get isAccelerating  => _isAccelerating;
  bool   get isBraking       => _isBraking;

  // ─── Internal tracking ───────────────────────────────────────────────────────
  double?  _lastSpeedKmh;
  DateTime? _lastTimestamp;

  // Cooldown timestamps to debounce event detection
  DateTime? _lastAccelEvent;
  DateTime? _lastBrakeEvent;

  static const Duration _accelCooldown = Duration(milliseconds: 1500);
  static const Duration _brakeCooldown = Duration(milliseconds: 2000);

  // ─── Thresholds (m/s²) ───────────────────────────────────────────────────────
  static const double _aggressiveAccelThreshold = 3.5;
  static const double _smoothAccelLower         = 0.8;
  static const double _harshBrakeThreshold      = -3.0;
  static const double _smoothBrakeLower         = -0.5;
  static const double _minSpeedForBraking       = 15.0; // km/h — ignore below

  // ─── Public API ──────────────────────────────────────────────────────────────

  /// Process a new smoothed speed sample. Call on every GPS position update.
  void processSample(double speedKmh, DateTime timestamp) {
    if (_lastSpeedKmh == null || _lastTimestamp == null) {
      _lastSpeedKmh   = speedKmh;
      _lastTimestamp  = timestamp;
      return;
    }

    final double dtSeconds = timestamp.difference(_lastTimestamp!).inMilliseconds / 1000.0;
    if (dtSeconds <= 0 || dtSeconds > 5.0) {
      // Skip stale or zero-time deltas
      _lastSpeedKmh  = speedKmh;
      _lastTimestamp = timestamp;
      return;
    }

    // Convert km/h → m/s for both samples
    final double prevMs  = _lastSpeedKmh! / 3.6;
    final double currMs  = speedKmh / 3.6;
    final double accelMs2 = (currMs - prevMs) / dtSeconds;

    _currentAccelMs2 = accelMs2;
    _isAccelerating  = accelMs2 > _smoothAccelLower;
    _isBraking       = accelMs2 < _smoothBrakeLower;

    _detectAcceleration(accelMs2, timestamp);
    _detectBraking(accelMs2, speedKmh, timestamp);

    _lastSpeedKmh  = speedKmh;
    _lastTimestamp = timestamp;
  }

  void reset() {
    _aggressiveAccelCount = 0;
    _smoothAccelCount     = 0;
    _harshBrakingCount    = 0;
    _smoothBrakingCount   = 0;
    _currentAccelMs2      = 0.0;
    _isAccelerating       = false;
    _isBraking            = false;
    _lastSpeedKmh         = null;
    _lastTimestamp        = null;
    _lastAccelEvent       = null;
    _lastBrakeEvent       = null;
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────

  void _detectAcceleration(double accelMs2, DateTime timestamp) {
    if (accelMs2 <= _smoothAccelLower) return;

    final bool cooledDown = _lastAccelEvent == null ||
        timestamp.difference(_lastAccelEvent!) > _accelCooldown;
    if (!cooledDown) return;

    if (accelMs2 >= _aggressiveAccelThreshold) {
      _aggressiveAccelCount++;
      _lastAccelEvent = timestamp;
    } else {
      _smoothAccelCount++;
      _lastAccelEvent = timestamp;
    }
  }

  void _detectBraking(double accelMs2, double currentSpeedKmh, DateTime timestamp) {
    if (accelMs2 >= _smoothBrakeLower) return;
    if (currentSpeedKmh < _minSpeedForBraking) return; // ignore parking maneuvers

    final bool cooledDown = _lastBrakeEvent == null ||
        timestamp.difference(_lastBrakeEvent!) > _brakeCooldown;
    if (!cooledDown) return;

    if (accelMs2 <= _harshBrakeThreshold) {
      _harshBrakingCount++;
      _lastBrakeEvent = timestamp;
    } else {
      _smoothBrakingCount++;
      _lastBrakeEvent = timestamp;
    }
  }
}
