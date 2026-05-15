import 'dart:convert';

/// ExitGate model matching PRD Section 8 — ExitGates Table
class ExitGate {
  final String exitId;
  final String stationId;
  final String gateNumber;
  final String directionLabel; // max 30 chars
  final int walkingDistM; // > 0 metres
  final List<String> landmarks; // JSON array of strings
  final String? photoPath; // nullable local file path

  ExitGate({
    required this.exitId,
    required this.stationId,
    required this.gateNumber,
    required this.directionLabel,
    required this.walkingDistM,
    required this.landmarks,
    this.photoPath,
  });

  factory ExitGate.fromJson(Map<String, dynamic> json) {
    return ExitGate(
      exitId: json['exit_id'] as String,
      stationId: json['station_id'] as String,
      gateNumber: json['gate_number'] as String,
      directionLabel: json['direction_label'] as String,
      walkingDistM: json['walking_dist_m'] as int,
      landmarks: (jsonDecode(json['landmarks'] as String) as List)
          .cast<String>(),
      photoPath: json['photo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'exit_id': exitId,
        'station_id': stationId,
        'gate_number': gateNumber,
        'direction_label': directionLabel,
        'walking_dist_m': walkingDistM,
        'landmarks': jsonEncode(landmarks),
        'photo_path': photoPath,
      };

  ExitGate copyWith({
    String? gateNumber,
    String? directionLabel,
    int? walkingDistM,
    List<String>? landmarks,
    String? photoPath,
  }) {
    return ExitGate(
      exitId: exitId,
      stationId: stationId,
      gateNumber: gateNumber ?? this.gateNumber,
      directionLabel: directionLabel ?? this.directionLabel,
      walkingDistM: walkingDistM ?? this.walkingDistM,
      landmarks: landmarks ?? this.landmarks,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
