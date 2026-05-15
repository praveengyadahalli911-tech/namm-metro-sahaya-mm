import 'package:string_similarity/string_similarity.dart';
import '../models/exit_gate_model.dart';

/// ExitRepository: sole class that reads/writes ExitGate data.
/// Uses in-memory storage (simulates Room DB per PRD Section 8).
/// BR-01: All gate lookups are offline-first.
/// BR-02: Fuzzy landmark matching (case-insensitive contains).
class ExitRepository {
  final List<ExitGate> _exits = [];

  ExitRepository();
  
  Future<void> init() async {
    _seedData();
  }

  void _seedData() {
    _exits.addAll([

      // ── PURPLE LINE ──────────────────────────────────────────────────────

      // P01 – Whitefield (Kadugodi)
      ExitGate(exitId: 'EX_P01_1', stationId: 'P01', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 50,
          landmarks: ['Whitefield Main Road', 'ITPL Road', 'Kadugodi Market']),
      ExitGate(exitId: 'EX_P01_2', stationId: 'P01', gateNumber: 'Gate 2',
          directionLabel: 'East Exit', walkingDistM: 200,
          landmarks: ['Whitefield Bus Stand', 'Forum Mall Whitefield']),

      // P02 – Hopefarm Channasandra
      ExitGate(exitId: 'EX_P02_1', stationId: 'P02', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Hopefarm Junction', 'Channasandra Market', 'KSRTC Bus Stop']),
      ExitGate(exitId: 'EX_P02_2', stationId: 'P02', gateNumber: 'Gate 2',
          directionLabel: 'West Exit', walkingDistM: 150,
          landmarks: ['Channasandra Lake', 'RMZ Infinity']),

      // P03 – Kadugodi Tree Park
      ExitGate(exitId: 'EX_P03_1', stationId: 'P03', gateNumber: 'Gate 1',
          directionLabel: 'Park Side Exit', walkingDistM: 60,
          landmarks: ['Kadugodi Tree Park', 'Swami Vivekananda Nagar']),

      // P04 – Pattandur Agrahara
      ExitGate(exitId: 'EX_P04_1', stationId: 'P04', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 100,
          landmarks: ['Pattandur Agrahara Village', 'Nallurhalli Road']),

      // P05 – Sri Sathya Sai Hospital
      ExitGate(exitId: 'EX_P05_1', stationId: 'P05', gateNumber: 'Gate 1',
          directionLabel: 'Hospital Exit', walkingDistM: 30,
          landmarks: ['Sri Sathya Sai Hospital', 'Whitefield Hospital', 'EPIP Zone']),
      ExitGate(exitId: 'EX_P05_2', stationId: 'P05', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 120,
          landmarks: ['ITPL Tech Park', 'SAP Labs']),

      // P06 – Nallurhalli
      ExitGate(exitId: 'EX_P06_1', stationId: 'P06', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Nallurhalli Park', 'Whitefield Road', 'Vibgyor School']),

      // P07 – Channasandra
      ExitGate(exitId: 'EX_P07_1', stationId: 'P07', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 100,
          landmarks: ['Channasandra Cross', 'Ramagondanahalli']),

      // P08 – Baiyappanahalli
      ExitGate(exitId: 'EX_P08_1', stationId: 'P08', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Baiyappanahalli Bus Stop', 'Old Madras Road']),
      ExitGate(exitId: 'EX_P08_2', stationId: 'P08', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 200,
          landmarks: ['Baiyappanahalli Depot', 'Ramamurthy Nagar']),

      // P09 – Swami Vivekananda Road
      ExitGate(exitId: 'EX_P09_1', stationId: 'P09', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 50,
          landmarks: ['Swami Vivekananda Road', 'Old Airport Road', 'Kamanahalli']),

      // P10 – Indiranagar
      ExitGate(exitId: 'EX_P10_1', stationId: 'P10', gateNumber: 'Gate 1',
          directionLabel: 'North Exit', walkingDistM: 40,
          landmarks: ['100 Feet Road', 'Indiranagar CMH Road', 'Defence Colony']),
      ExitGate(exitId: 'EX_P10_2', stationId: 'P10', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 120,
          landmarks: ['Domlur Flyover', 'Indiranagar Market', '12th Main Indiranagar']),

      // P11 – Halasuru
      ExitGate(exitId: 'EX_P11_1', stationId: 'P11', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 70,
          landmarks: ['Halasuru Lake', 'Ulsoor Road', 'Halasuru Someshwara Temple']),

      // P12 – Trinity
      ExitGate(exitId: 'EX_P12_1', stationId: 'P12', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 50,
          landmarks: ['Trinity Circle', 'HAL Old Airport Road', 'Oberoi Hotel']),

      // P13 – MG Road
      ExitGate(exitId: 'EX_P13_1', stationId: 'P13', gateNumber: 'Gate 1',
          directionLabel: 'West Exit', walkingDistM: 80,
          landmarks: ['MG Road', 'Commercial Street', 'Brigade Road']),
      ExitGate(exitId: 'EX_P13_2', stationId: 'P13', gateNumber: 'Gate 2',
          directionLabel: 'East Exit', walkingDistM: 150,
          landmarks: ['Anil Kumble Circle', 'Chinnaswamy Stadium', 'BBMP Office']),

      // P14 – Cubbon Park
      ExitGate(exitId: 'EX_P14_1', stationId: 'P14', gateNumber: 'Gate 1',
          directionLabel: 'Park Exit', walkingDistM: 30,
          landmarks: ['Cubbon Park', 'High Court of Karnataka', 'State Central Library']),
      ExitGate(exitId: 'EX_P14_2', stationId: 'P14', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 100,
          landmarks: ['Raj Bhavan', 'Vidhana Soudha Road']),

      // P15 – Vidhana Soudha
      ExitGate(exitId: 'EX_P15_1', stationId: 'P15', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 60,
          landmarks: ['Vidhana Soudha', 'Dr. Ambedkar Veedhi', 'Indian Express Building']),

      // MAJ – Majestic (Interchange)
      ExitGate(exitId: 'EX_MAJ_1', stationId: 'MAJ', gateNumber: 'Gate 1',
          directionLabel: 'North Exit', walkingDistM: 50,
          landmarks: ['KSRTC Bus Stand', 'Kempe Gowda Bus Station', 'Satellite Bus Stand']),
      ExitGate(exitId: 'EX_MAJ_2', stationId: 'MAJ', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 120,
          landmarks: ['City Railway Station', 'KSR Railway Station', 'Kempegowda Road']),
      ExitGate(exitId: 'EX_MAJ_3', stationId: 'MAJ', gateNumber: 'Gate 3',
          directionLabel: 'East Exit', walkingDistM: 200,
          landmarks: ['Gandhi Nagar', 'Majestic Market', 'Chikpete']),
      ExitGate(exitId: 'EX_MAJ_4', stationId: 'MAJ', gateNumber: 'Gate 4',
          directionLabel: 'West Exit', walkingDistM: 180,
          landmarks: ['Ananda Rao Circle', 'City Market', 'Gupta Market']),

      // MAJ_G – Majestic Green Line (Interchange)
      ExitGate(exitId: 'EX_MAJG_1', stationId: 'MAJ_G', gateNumber: 'Gate 1',
          directionLabel: 'North Exit', walkingDistM: 50,
          landmarks: ['KSRTC Bus Stand', 'Kempe Gowda Bus Station', 'Satellite Bus Stand']),
      ExitGate(exitId: 'EX_MAJG_2', stationId: 'MAJ_G', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 120,
          landmarks: ['City Railway Station', 'KSR Railway Station', 'Kempegowda Road']),
      ExitGate(exitId: 'EX_MAJG_3', stationId: 'MAJ_G', gateNumber: 'Gate 3',
          directionLabel: 'East Exit', walkingDistM: 200,
          landmarks: ['Gandhi Nagar', 'Majestic Market', 'Chikpete']),

      // P17 – City Railway Station
      ExitGate(exitId: 'EX_P17_1', stationId: 'P17', gateNumber: 'Gate 1',
          directionLabel: 'Station Exit', walkingDistM: 30,
          landmarks: ['KSR City Railway Station', 'Platform 1', 'Railway Retiring Room']),
      ExitGate(exitId: 'EX_P17_2', stationId: 'P17', gateNumber: 'Gate 2',
          directionLabel: 'Market Side', walkingDistM: 100,
          landmarks: ['Kempegowda Road', 'City Market', 'Shivajinagar']),

      // P18 – Magadi Road
      ExitGate(exitId: 'EX_P18_1', stationId: 'P18', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Magadi Road', 'Srirampuram', 'Govindarajanagar']),

      // P19 – Hosahalli
      ExitGate(exitId: 'EX_P19_1', stationId: 'P19', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 70,
          landmarks: ['Hosahalli Cross', 'Vijayanagara Main Road']),

      // P20 – Vijayanagara
      ExitGate(exitId: 'EX_P20_1', stationId: 'P20', gateNumber: 'Gate 1',
          directionLabel: 'North Exit', walkingDistM: 50,
          landmarks: ['Vijayanagara Circle', 'RPC Layout', 'Chord Road']),
      ExitGate(exitId: 'EX_P20_2', stationId: 'P20', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 150,
          landmarks: ['Vijayanagara Market', 'Deepanjali Nagar', 'Subramanyanagar']),

      // P21 – Attiguppe
      ExitGate(exitId: 'EX_P21_1', stationId: 'P21', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Attiguppe Bus Stop', 'Vijayanagara Main Road', 'Attiguppe Market']),

      // P22 – Deepanjali Nagar
      ExitGate(exitId: 'EX_P22_1', stationId: 'P22', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 60,
          landmarks: ['Deepanjali Nagar Layout', 'Mysuru Road Service Road']),

      // P23 – Mysuru Road
      ExitGate(exitId: 'EX_P23_1', stationId: 'P23', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 50,
          landmarks: ['Mysuru Road', 'NICE Road Junction', 'Kengeri Bus Terminal']),
      ExitGate(exitId: 'EX_P23_2', stationId: 'P23', gateNumber: 'Gate 2',
          directionLabel: 'Depot Exit', walkingDistM: 200,
          landmarks: ['Mysuru Road Depot', 'Kengeri Satellite Town']),

      // ── GREEN LINE ───────────────────────────────────────────────────────

      // G01 – Nagasandra
      ExitGate(exitId: 'EX_G01_1', stationId: 'G01', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 60,
          landmarks: ['Nagasandra Bus Stop', 'Nagasandra Cross', 'Tumkur Road']),

      // G02 – Dasarahalli
      ExitGate(exitId: 'EX_G02_1', stationId: 'G02', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Dasarahalli Cross', 'Dasarahalli Market', 'Peenya Road']),

      // G03 – Jalahalli
      ExitGate(exitId: 'EX_G03_1', stationId: 'G03', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 70,
          landmarks: ['Jalahalli Cross', 'BEL Layout', 'Air Force Station']),
      ExitGate(exitId: 'EX_G03_2', stationId: 'G03', gateNumber: 'Gate 2',
          directionLabel: 'East Exit', walkingDistM: 150,
          landmarks: ['BEL Circle', 'HMT Factory', 'ITI Factory']),

      // G04 – Peenya Industry
      ExitGate(exitId: 'EX_G04_1', stationId: 'G04', gateNumber: 'Gate 1',
          directionLabel: 'Industrial Exit', walkingDistM: 50,
          landmarks: ['Peenya Industrial Area', 'KIADB Industrial Estate', 'KSSIDC']),

      // G05 – Peenya
      ExitGate(exitId: 'EX_G05_1', stationId: 'G05', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 60,
          landmarks: ['Peenya Bus Stand', 'Peenya Market', 'Tumkur Road']),

      // G06 – Goraguntepalya
      ExitGate(exitId: 'EX_G06_1', stationId: 'G06', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Goraguntepalya Bus Stop', 'Peenya 2nd Stage', 'Rajiv Gandhi Nagar']),

      // G07 – Yeshwanthpur
      ExitGate(exitId: 'EX_G07_1', stationId: 'G07', gateNumber: 'Gate 1',
          directionLabel: 'Station Exit', walkingDistM: 50,
          landmarks: ['Yeshwanthpur Railway Station', 'Yeshwanthpur Circle', 'Chord Road']),
      ExitGate(exitId: 'EX_G07_2', stationId: 'G07', gateNumber: 'Gate 2',
          directionLabel: 'Market Exit', walkingDistM: 150,
          landmarks: ['Yeshwanthpur Market', 'APMC Yard', 'Tumkur Road']),

      // G08 – Sandal Soap Factory
      ExitGate(exitId: 'EX_G08_1', stationId: 'G08', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 60,
          landmarks: ['Sandal Soap Factory', 'Rajajinagar Industrial Town', 'Chord Road']),

      // G09 – Mahalakshmi
      ExitGate(exitId: 'EX_G09_1', stationId: 'G09', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 70,
          landmarks: ['Mahalakshmi Layout', 'Chord Road', 'Mahalakshmi Temple']),

      // G10 – Rajajinagar
      ExitGate(exitId: 'EX_G10_1', stationId: 'G10', gateNumber: 'Gate 1',
          directionLabel: 'North Exit', walkingDistM: 50,
          landmarks: ['Rajajinagar 1st Block', 'Chord Road', 'BDA Market Rajajinagar']),
      ExitGate(exitId: 'EX_G10_2', stationId: 'G10', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 150,
          landmarks: ['Rajajinagar 4th Block', 'Prakash Nagar', 'Basaveshwara Nagar']),

      // G11 – Kuvempu Road
      ExitGate(exitId: 'EX_G11_1', stationId: 'G11', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 60,
          landmarks: ['Kuvempu Road', 'Rajajinagar Market', 'Shivananda Circle']),

      // G12 – Srirampura
      ExitGate(exitId: 'EX_G12_1', stationId: 'G12', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 80,
          landmarks: ['Srirampuram Bus Stop', 'Magadi Road', 'Viswanatha Nagenahalli']),

      // G13 – Mantri Square Sampige Road
      ExitGate(exitId: 'EX_G13_1', stationId: 'G13', gateNumber: 'Gate 1',
          directionLabel: 'Mall Exit', walkingDistM: 30,
          landmarks: ['Mantri Square Mall', 'Sampige Road', 'Malleshwaram Circle']),
      ExitGate(exitId: 'EX_G13_2', stationId: 'G13', gateNumber: 'Gate 2',
          directionLabel: 'Market Exit', walkingDistM: 150,
          landmarks: ['Malleshwaram Market', '8th Cross Malleshwaram', 'Margosa Road']),

      // G15 – City Market
      ExitGate(exitId: 'EX_G15_1', stationId: 'G15', gateNumber: 'Gate 1',
          directionLabel: 'Market Exit', walkingDistM: 40,
          landmarks: ['City Market', 'KR Market', 'Chikpete Flower Market']),
      ExitGate(exitId: 'EX_G15_2', stationId: 'G15', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 120,
          landmarks: ['Avenue Road', 'Cottonpete', 'Upparpet']),

      // G16 – National College
      ExitGate(exitId: 'EX_G16_1', stationId: 'G16', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 50,
          landmarks: ['National College', 'Basavanagudi', 'DVG Road']),
      ExitGate(exitId: 'EX_G16_2', stationId: 'G16', gateNumber: 'Gate 2',
          directionLabel: 'East Exit', walkingDistM: 130,
          landmarks: ['Gavipuram Guttahalli', 'Minerva Circle']),

      // G17 – Lalbagh
      ExitGate(exitId: 'EX_G17_1', stationId: 'G17', gateNumber: 'Gate 1',
          directionLabel: 'Garden Exit', walkingDistM: 30,
          landmarks: ['Lalbagh Botanical Garden', 'Lalbagh West Gate', 'Mavalli']),
      ExitGate(exitId: 'EX_G17_2', stationId: 'G17', gateNumber: 'Gate 2',
          directionLabel: 'East Exit', walkingDistM: 200,
          landmarks: ['Lalbagh East Gate', 'Havelock Road', 'Richmond Town']),

      // G18 – South End Circle
      ExitGate(exitId: 'EX_G18_1', stationId: 'G18', gateNumber: 'Gate 1',
          directionLabel: 'Circle Exit', walkingDistM: 50,
          landmarks: ['South End Circle', 'KR Road', 'Jayanagar Shopping Complex']),

      // G19 – Jayanagar
      ExitGate(exitId: 'EX_G19_1', stationId: 'G19', gateNumber: 'Gate 1',
          directionLabel: 'North Exit', walkingDistM: 60,
          landmarks: ['Jayanagar 4th Block', 'Jayanagar Complex', 'Jayanagar Bus Stand']),
      ExitGate(exitId: 'EX_G19_2', stationId: 'G19', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 180,
          landmarks: ['Jayanagar 9th Block', 'BDA Complex', 'JP Nagar Ring Road']),

      // G20 – Rashtreeya Vidyalaya Road
      ExitGate(exitId: 'EX_G20_1', stationId: 'G20', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 60,
          landmarks: ['RV College Road', 'Jayanagar 5th Block', 'Vasanthnagar']),

      // G21 – Banashankari
      ExitGate(exitId: 'EX_G21_1', stationId: 'G21', gateNumber: 'Gate 1',
          directionLabel: 'Temple Exit', walkingDistM: 80,
          landmarks: ['Banashankari Temple', 'Banashankari Bus Stand', 'BMTC Depot']),
      ExitGate(exitId: 'EX_G21_2', stationId: 'G21', gateNumber: 'Gate 2',
          directionLabel: 'South Exit', walkingDistM: 200,
          landmarks: ['Banashankari 2nd Stage', 'Katriguppe', 'Dollars Colony']),

      // G22 – Jayaprakash Nagar
      ExitGate(exitId: 'EX_G22_1', stationId: 'G22', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 70,
          landmarks: ['JP Nagar', 'Jayaprakash Nagar Bus Stop', 'NIMHANS']),
      ExitGate(exitId: 'EX_G22_2', stationId: 'G22', gateNumber: 'Gate 2',
          directionLabel: 'Hospital Exit', walkingDistM: 150,
          landmarks: ['NIMHANS Hospital', 'Victoria Hospital Road', 'Hosur Road']),

      // G23 – Yelachenahalli
      ExitGate(exitId: 'EX_G23_1', stationId: 'G23', gateNumber: 'Gate 1',
          directionLabel: 'Main Exit', walkingDistM: 50,
          landmarks: ['Yelachenahalli Bus Stop', 'Kanakapura Road', 'Silk Institute']),
      ExitGate(exitId: 'EX_G23_2', stationId: 'G23', gateNumber: 'Gate 2',
          directionLabel: 'Depot Exit', walkingDistM: 150,
          landmarks: ['Yelachenahalli Depot', 'JP Nagar 8th Phase', 'NICE Road']),
    ]);
  }

  /// All exits (for admin panel)
  List<ExitGate> get allExits => List.unmodifiable(_exits);

  /// Get exits for a specific station
  List<ExitGate> getExitsForStation(String stationId) {
    return _exits.where((e) => e.stationId == stationId).toList();
  }

  /// BR-02: Fuzzy landmark query — advanced similarity matching
  List<ExitGate> findByLandmark(String stationId, String landmark) {
    final query = landmark.toLowerCase().trim();
    
    // 1. Direct contains match (Priority 1)
    final directMatches = _exits
        .where((e) =>
            e.stationId == stationId &&
            e.landmarks.any((lm) => lm.toLowerCase().contains(query)))
        .toList();
    
    if (directMatches.isNotEmpty) return directMatches..sort((a, b) => a.walkingDistM.compareTo(b.walkingDistM));

    // 2. Fuzzy similarity match (Priority 2)
    return _exits.where((e) {
      if (e.stationId != stationId) return false;
      return e.landmarks.any((lm) {
        final similarity = StringSimilarity.compareTwoStrings(query, lm.toLowerCase());
        return similarity > 0.4;
      });
    }).toList()
      ..sort((a, b) => a.walkingDistM.compareTo(b.walkingDistM));
  }

  /// FR-NMS-14: Upsert exit gate (add or edit). Validates uniqueness.
  /// Returns null on success; error message on failure.
  String? upsert(ExitGate gate) {
    // Validate walking distance > 0
    if (gate.walkingDistM <= 0) {
      return 'Walking distance must be greater than 0.';
    }

    // Validate direction label length <= 30
    if (gate.directionLabel.length > 30) {
      return 'Direction label must be 30 characters or fewer.';
    }

    // Check gate number uniqueness within station (excluding self on edit)
    final duplicate = _exits.any((e) =>
        e.stationId == gate.stationId &&
        e.gateNumber == gate.gateNumber &&
        e.exitId != gate.exitId);
    if (duplicate) {
      return 'Gate ${gate.gateNumber} already exists for this station.';
    }

    final idx = _exits.indexWhere((e) => e.exitId == gate.exitId);
    if (idx >= 0) {
      _exits[idx] = gate;
    } else {
      _exits.add(gate);
    }
    return null; // success
  }

  /// Delete an exit gate
  void delete(String exitId) {
    _exits.removeWhere((e) => e.exitId == exitId);
  }
}
