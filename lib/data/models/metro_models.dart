/// RouteResult: returned by RouteRepository.computeRoute()
/// Carries the full path, computed time, fare, and interchange info.
class Station {
  final String id;
  final String name;
  final String lineId; // 'purple' | 'green' | 'interchange'
  final bool isInterchange;
  final double lat;
  final double lng;

  const Station({
    required this.id,
    required this.name,
    required this.lineId,
    this.isInterchange = false,
    this.lat = 0.0,
    this.lng = 0.0,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['station_id'] as String,
      name: json['station_name'] as String,
      lineId: json['line_id'] as String,
      isInterchange:
          json['is_interchange'] == true || json['is_interchange'] == 1,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Station && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class Line {
  final String id;
  final String name;
  final String colorHex;

  const Line({
    required this.id,
    required this.name,
    required this.colorHex,
  });
}

class Segment {
  final String id;
  final String fromStationId;
  final String toStationId;
  final int durationMins; // avg_duration_mins per PRD
  final double distanceKm;
  final String lineId;

  const Segment({
    required this.id,
    required this.fromStationId,
    required this.toStationId,
    required this.durationMins,
    required this.distanceKm,
    required this.lineId,
  });
}

/// RouteResult returned by RouteRepository.computeRoute()
class RouteResult {
  final List<Station> stations; // ordered path (origin → destination)
  final int totalTimeMins; // SUM(segment.durationMins) along path
  final double totalDistanceKm; // SUM(segment.distanceKm) along path
  final int fare; // fare_inr from FareMatrix
  final bool hasInterchange; // true if Purple↔Green switch exists
  final Station? interchangeStation;
  final String? errorMessage; // null = success

  const RouteResult({
    required this.stations,
    required this.totalTimeMins,
    required this.totalDistanceKm,
    required this.fare,
    required this.hasInterchange,
    this.interchangeStation,
    this.errorMessage,
  });

  /// Convenience ctor for error cases
  factory RouteResult.error(String message) => RouteResult(
        stations: [],
        totalTimeMins: 0,
        totalDistanceKm: 0.0,
        fare: 0,
        hasInterchange: false,
        errorMessage: message,
      );

  bool get isValid => errorMessage == null && stations.isNotEmpty;

  /// Number of user-visible stops (excludes the internal interchange node)
  int get stopCount => stations
      .where((s) => s.lineId != 'interchange')
      .length;
}
