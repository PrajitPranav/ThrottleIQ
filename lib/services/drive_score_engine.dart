// drive_score_engine.dart — Real telemetry-based trip scoring engine.
//
// Computes a 0–100 drive score from actual trip behavior data.
// No placeholders — every deduction and bonus maps to a real driving event.
//
// Scoring formula:
//   Base: 100
//   Deductions:
//     • Harsh braking:      −4 pts each  (max −20)
//     • Aggressive accel:   −3 pts each  (max −15)
//     • Sharp turns:        −2 pts each  (max −10)
//     • Top speed > 120:    −0.3 per km/h over 120 (max −15)
//     • Max G-Force > 0.8:  −(gForce − 0.8) × 15 (max −15)
//   Bonuses:
//     • Smooth accel ratio ≥ 70%: +3
//     • Zero harsh braking:        +5
//     • Avg speed 30–80 km/h:     +2  (city efficiency bonus)

class DriveScoreEngine {
  /// Calculate the drive score for a completed trip.
  /// All inputs are real telemetry values — no defaults.
  int calculateScore({
    required int    harshBrakingCount,
    required int    aggressiveAccelCount,
    required int    smoothAccelCount,
    required int    sharpTurnCount,
    required double topSpeedKmh,
    required double maxGForce,
    required double avgSpeedKmh,
  }) {
    double score = 100.0;

    // ─── Deductions ───────────────────────────────────────────────────────────
    // Harsh braking penalty
    final double brakePenalty = (harshBrakingCount * 4.0).clamp(0, 20);
    score -= brakePenalty;

    // Aggressive acceleration penalty
    final double accelPenalty = (aggressiveAccelCount * 3.0).clamp(0, 15);
    score -= accelPenalty;

    // Sharp turn penalty
    final double turnPenalty = (sharpTurnCount * 2.0).clamp(0, 10);
    score -= turnPenalty;

    // Speeding penalty (above 120 km/h)
    if (topSpeedKmh > 120) {
      final double speedPenalty = ((topSpeedKmh - 120) * 0.3).clamp(0, 15);
      score -= speedPenalty;
    }

    // G-Force penalty (above 0.8G)
    if (maxGForce > 0.8) {
      final double gPenalty = ((maxGForce - 0.8) * 15.0).clamp(0, 15);
      score -= gPenalty;
    }

    // ─── Bonuses ──────────────────────────────────────────────────────────────
    // Smooth acceleration ratio bonus
    final int totalAccelEvents = smoothAccelCount + aggressiveAccelCount;
    if (totalAccelEvents > 0) {
      final double smoothRatio = smoothAccelCount / totalAccelEvents;
      if (smoothRatio >= 0.70) score += 3.0;
    }

    // Zero harsh braking bonus
    if (harshBrakingCount == 0) score += 5.0;

    // City efficiency bonus (30–80 km/h average)
    if (avgSpeedKmh >= 30 && avgSpeedKmh <= 80) score += 2.0;

    if (!score.isFinite) return 0;
    return score.round().clamp(0, 100);
  }

  /// Generate a human-readable rank label from a score.
  static String rankLabel(int score) {
    if (score >= 95) return 'MASTER DRIVER';
    if (score >= 88) return 'ELITE DRIVER';
    if (score >= 78) return 'EXPERT DRIVER';
    if (score >= 65) return 'SKILLED DRIVER';
    if (score >= 50) return 'DEVELOPING';
    return 'NOVICE DRIVER';
  }

  /// Color category for a score (returns a hex-style int for Color()).
  static int scoreColorValue(int score) {
    if (score >= 85) return 0xFF5A7D65; // sage green
    if (score >= 70) return 0xFF4F6B8F; // slate blue
    if (score >= 50) return 0xFF9E653F; // amber
    return 0xFF8F3232;                  // deep red
  }
}
