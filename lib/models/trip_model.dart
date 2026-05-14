// trip_model.dart — Placeholder trip data model.

class TripModel {
  final String name;
  final double topSpeedKmh;
  final double distanceKm;
  final String duration;   // formatted HH:MM:SS
  final int    driveScore; // 0–100
  final String dateTime;   // display string
  final String mode;       // e.g. "SPORT+"

  const TripModel({
    required this.name,
    required this.topSpeedKmh,
    required this.distanceKm,
    required this.duration,
    required this.driveScore,
    required this.dateTime,
    required this.mode,
  });

  // Placeholder dataset shown on the Trips screen
  static const List<TripModel> placeholders = [
    TripModel(
      name: 'Night Highway Run',
      topSpeedKmh: 218,
      distanceKm: 47.2,
      duration: '00:41:22',
      driveScore: 94,
      dateTime: 'Today  22:14',
      mode: 'SPORT+',
    ),
    TripModel(
      name: 'Morning Commute',
      topSpeedKmh: 112,
      distanceKm: 18.6,
      duration: '00:28:05',
      driveScore: 81,
      dateTime: 'Today  08:30',
      mode: 'COMFORT',
    ),
    TripModel(
      name: 'Track Day Session',
      topSpeedKmh: 272,
      distanceKm: 34.0,
      duration: '00:52:18',
      driveScore: 98,
      dateTime: 'Yesterday  14:07',
      mode: 'SPORT+',
    ),
    TripModel(
      name: 'City Cruise',
      topSpeedKmh: 76,
      distanceKm: 12.3,
      duration: '00:19:44',
      driveScore: 76,
      dateTime: 'Yesterday  19:22',
      mode: 'ECO',
    ),
    TripModel(
      name: 'Weekend Backroad',
      topSpeedKmh: 164,
      distanceKm: 88.5,
      duration: '01:14:33',
      driveScore: 89,
      dateTime: '12 May  10:15',
      mode: 'SPORT',
    ),
  ];
}
