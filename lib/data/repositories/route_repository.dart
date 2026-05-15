import 'dart:math' as math;
import 'package:string_similarity/string_similarity.dart';
import '../models/metro_models.dart';

/// RouteRepository: pathfinding and fare logic using REAL distances.
class RouteRepository {
  final List<Station> _stations = [];
  final List<Segment> _segments = [];

  RouteRepository();

  Future<void> init() async {
    _stations.clear();
    _seedStations();
    
    _segments.clear();
    _seedSegments();
    
    print('✅ RouteRepository initialized with ${_stations.length} local stations');
  }

  // Haversine formula to calculate distance in km
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371; // Radius of the earth in km
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) * math.cos(_deg2rad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c; // Distance in km
  }

  double _deg2rad(double deg) {
    return deg * (math.pi / 180);
  }

  void _seedStations() {
    // purple
    _stations.add(const Station(id: 'P01', name: 'Whitefield (Kadugodi)', lineId: 'purple', lat: 12.99558, lng: 77.7579));
    _stations.add(const Station(id: 'P02', name: 'Hopefarm Channasandra', lineId: 'purple', lat: 12.98737, lng: 77.75391));
    _stations.add(const Station(id: 'P03', name: 'Kadugodi Tree Park', lineId: 'purple', lat: 12.98564, lng: 77.74705));
    _stations.add(const Station(id: 'P04', name: 'Pattandur Agrahara', lineId: 'purple', lat: 12.98762, lng: 77.7378));
    _stations.add(const Station(id: 'P05', name: 'Sri Sathya Sai Hospital', lineId: 'purple', lat: 12.97757, lng: 77.72877));
    _stations.add(const Station(id: 'P06', name: 'Nallur Halli', lineId: 'purple', lat: 12.9766, lng: 77.72481));
    _stations.add(const Station(id: 'P07', name: 'Kundalahalli', lineId: 'purple', lat: 12.97757, lng: 77.71559));
    _stations.add(const Station(id: 'P08', name: 'Seetharampalya', lineId: 'purple', lat: 12.98095, lng: 77.70875));
    _stations.add(const Station(id: 'P09', name: 'Hoodi', lineId: 'purple', lat: 12.98884, lng: 77.71139));
    _stations.add(const Station(id: 'P10', name: 'Garudacharpalya', lineId: 'purple', lat: 12.99343, lng: 77.7037));
    _stations.add(const Station(id: 'P11', name: 'Singayyanapalya', lineId: 'purple', lat: 12.99658, lng: 77.6926));
    _stations.add(const Station(id: 'P12', name: 'Krishnarajapura', lineId: 'purple', lat: 12.99991, lng: 77.67788));
    _stations.add(const Station(id: 'P13', name: 'Benniganahalli', lineId: 'purple', lat: 12.99652, lng: 77.66847));
    _stations.add(const Station(id: 'P14', name: 'Baiyappanahalli', lineId: 'purple', lat: 12.99069, lng: 77.65239));
    _stations.add(const Station(id: 'P15', name: 'Swami Vivekananda Road', lineId: 'purple', lat: 12.98593, lng: 77.6449));
    _stations.add(const Station(id: 'P16', name: 'Indiranagar', lineId: 'purple', lat: 12.97833, lng: 77.63866));
    _stations.add(const Station(id: 'P17', name: 'Halasuru', lineId: 'purple', lat: 12.9765, lng: 77.62669));
    _stations.add(const Station(id: 'P18', name: 'Trinity', lineId: 'purple', lat: 12.97302, lng: 77.61702));
    _stations.add(const Station(id: 'P19', name: 'Mahatma Gandhi Road', lineId: 'purple', lat: 12.97553, lng: 77.60678));
    _stations.add(const Station(id: 'P20', name: 'Cubbon Park', lineId: 'purple', lat: 12.98094, lng: 77.59757));
    _stations.add(const Station(id: 'P21', name: 'Vidhana Soudha', lineId: 'purple', lat: 12.97849, lng: 77.59148));
    _stations.add(const Station(id: 'P22', name: 'Sir M. Visvesvaraya Stn., Central College', lineId: 'purple', lat: 12.97453, lng: 77.58422));
    _stations.add(const Station(id: 'MAJ', name: 'Nadaprabhu Kempegowda Station, Majestic', lineId: 'purple', isInterchange: true, lat: 12.97561, lng: 77.57288));
    _stations.add(const Station(id: 'P24', name: 'Krantivira Sangolli Rayanna Railway Station', lineId: 'purple', lat: 12.97588, lng: 77.56538));
    _stations.add(const Station(id: 'P25', name: 'Magadi Road', lineId: 'purple', lat: 12.97564, lng: 77.55536));
    _stations.add(const Station(id: 'P26', name: 'Hosahalli', lineId: 'purple', lat: 12.9742, lng: 77.54562));
    _stations.add(const Station(id: 'P27', name: 'Vijayanagar', lineId: 'purple', lat: 12.97095, lng: 77.53741));
    _stations.add(const Station(id: 'P28', name: 'Attiguppe', lineId: 'purple', lat: 12.96187, lng: 77.53357));
    _stations.add(const Station(id: 'P29', name: 'Deepanjali Nagar', lineId: 'purple', lat: 12.95204, lng: 77.53702));
    _stations.add(const Station(id: 'P30', name: 'Mysuru Road', lineId: 'purple', lat: 12.94668, lng: 77.53008));
    _stations.add(const Station(id: 'P31', name: 'Pantharapalya - Nayandahalli', lineId: 'purple', lat: 12.94167, lng: 77.52512));
    _stations.add(const Station(id: 'P32', name: 'Rajarajeshwari Nagar', lineId: 'purple', lat: 12.93665, lng: 77.51966));
    _stations.add(const Station(id: 'P33', name: 'Jnanabharathi', lineId: 'purple', lat: 12.93543, lng: 77.51241));
    _stations.add(const Station(id: 'P34', name: 'Kengeri Bus Terminal', lineId: 'purple', lat: 12.91469, lng: 77.48785)); // Using corrected mapping for lat/long
    _stations.add(const Station(id: 'P35', name: 'Kengeri', lineId: 'purple', lat: 12.90791, lng: 77.47658));
    _stations.add(const Station(id: 'P36', name: 'Challaghatta', lineId: 'purple', lat: 12.89731, lng: 77.46123));

    // green
    _stations.add(const Station(id: 'G01', name: 'Madavara', lineId: 'green', lat: 13.05742, lng: 77.4728));
    _stations.add(const Station(id: 'G02', name: 'Chikkabidarakallu', lineId: 'green', lat: 13.05236, lng: 77.48792));
    _stations.add(const Station(id: 'G03', name: 'Manjunathanagara', lineId: 'green', lat: 13.05009, lng: 77.49445));
    _stations.add(const Station(id: 'G04', name: 'Nagasandra', lineId: 'green', lat: 13.04796, lng: 77.50014));
    _stations.add(const Station(id: 'G05', name: 'Dasarahalli', lineId: 'green', lat: 13.04326, lng: 77.51253));
    _stations.add(const Station(id: 'G06', name: 'Jalahalli', lineId: 'green', lat: 13.03941, lng: 77.51974));
    _stations.add(const Station(id: 'G07', name: 'Peenya Industry', lineId: 'green', lat: 13.03631, lng: 77.52551));
    _stations.add(const Station(id: 'G08', name: 'Peenya', lineId: 'green', lat: 13.03302, lng: 77.53320));
    _stations.add(const Station(id: 'G09', name: 'Goraguntepalya', lineId: 'green', lat: 13.02833, lng: 77.54105));
    _stations.add(const Station(id: 'G10', name: 'Yeshwantpur', lineId: 'green', lat: 13.02333, lng: 77.54973));
    _stations.add(const Station(id: 'G11', name: 'Sandal Soap Factory', lineId: 'green', lat: 13.0147, lng: 77.55401));
    _stations.add(const Station(id: 'G12', name: 'Mahalakshmi', lineId: 'green', lat: 13.00815, lng: 77.54881));
    _stations.add(const Station(id: 'G13', name: 'Rajajinagar', lineId: 'green', lat: 13.0004, lng: 77.54968));
    _stations.add(const Station(id: 'G14', name: 'Mahakavi Kuvempu Road', lineId: 'green', lat: 12.99848, lng: 77.55691));
    _stations.add(const Station(id: 'G15', name: 'Srirampura', lineId: 'green', lat: 12.9965, lng: 77.56333));
    _stations.add(const Station(id: 'G16', name: 'Mantri Square Sampige Road', lineId: 'green', lat: 12.9904, lng: 77.57071));
    _stations.add(const Station(id: 'MAJ_G', name: 'Nadaprabhu Kempegowda Station, Majestic', lineId: 'green', isInterchange: true, lat: 12.97561, lng: 77.57288));
    _stations.add(const Station(id: 'G18', name: 'Chickpete', lineId: 'green', lat: 12.96684, lng: 77.57455));
    _stations.add(const Station(id: 'G19', name: 'Krishna Rajendra Market', lineId: 'green', lat: 12.9607, lng: 77.57463));
    _stations.add(const Station(id: 'G20', name: 'National College', lineId: 'green', lat: 12.95051, lng: 77.57369));
    _stations.add(const Station(id: 'G21', name: 'Lalbagh', lineId: 'green', lat: 12.94641, lng: 77.58001));
    _stations.add(const Station(id: 'G22', name: 'South End Circle', lineId: 'green', lat: 12.93826, lng: 77.58006));
    _stations.add(const Station(id: 'G23', name: 'Jayanagar', lineId: 'green', lat: 12.92954, lng: 77.58015));
    _stations.add(const Station(id: 'RV_G', name: 'Rashtreeya Vidyalaya Road', lineId: 'green', isInterchange: true, lat: 12.92137, lng: 77.58017));
    _stations.add(const Station(id: 'G25', name: 'Banashankari', lineId: 'green', lat: 12.91532, lng: 77.57362));
    _stations.add(const Station(id: 'G26', name: 'Jaya Prakash Nagar', lineId: 'green', lat: 12.90746, lng: 77.57312));
    _stations.add(const Station(id: 'G27', name: 'Yelachenahalli', lineId: 'green', lat: 12.89604, lng: 77.57019));
    _stations.add(const Station(id: 'G28', name: 'Konanakunte Cross', lineId: 'green', lat: 12.88898, lng: 77.5627));
    _stations.add(const Station(id: 'G29', name: 'Doddakallasandra', lineId: 'green', lat: 12.88466, lng: 77.55277));
    _stations.add(const Station(id: 'G30', name: 'Vajarahalli', lineId: 'green', lat: 12.87753, lng: 77.54478));
    _stations.add(const Station(id: 'G31', name: 'Thalaghattapura', lineId: 'green', lat: 12.8714, lng: 77.53838));
    _stations.add(const Station(id: 'G32', name: 'Silk Institute', lineId: 'green', lat: 12.8616, lng: 77.52989));

    // yellow
    _stations.add(const Station(id: 'RV_Y', name: 'Rashtreeya Vidyalaya Road', lineId: 'yellow', isInterchange: true, lat: 12.92137, lng: 77.58017));
    _stations.add(const Station(id: 'Y02', name: 'Ragigudda', lineId: 'yellow', lat: 12.91708, lng: 77.58824));
    _stations.add(const Station(id: 'Y03', name: 'Jayadeva Hospital', lineId: 'yellow', lat: 12.91675, lng: 77.60009));
    _stations.add(const Station(id: 'Y04', name: 'BTM Layout', lineId: 'yellow', lat: 12.91659, lng: 77.60813));
    _stations.add(const Station(id: 'Y05', name: 'Central Silk Board', lineId: 'yellow', lat: 12.91657, lng: 77.62057));
    _stations.add(const Station(id: 'Y06', name: 'Bommanahalli', lineId: 'yellow', lat: 12.91075, lng: 77.62641));
    _stations.add(const Station(id: 'Y07', name: 'Hongasandra', lineId: 'yellow', lat: 12.90173, lng: 77.63197));
    _stations.add(const Station(id: 'Y08', name: 'Kudlu Gate', lineId: 'yellow', lat: 12.88994, lng: 77.63921));
    _stations.add(const Station(id: 'Y09', name: 'Singasandra', lineId: 'yellow', lat: 12.88081, lng: 77.64486));
    _stations.add(const Station(id: 'Y10', name: 'Hosa Road', lineId: 'yellow', lat: 12.87074, lng: 77.65245));
    _stations.add(const Station(id: 'Y11', name: 'Beratena Agrahara', lineId: 'yellow', lat: 12.8639, lng: 77.65789));
    _stations.add(const Station(id: 'Y12', name: 'Electronic City', lineId: 'yellow', lat: 12.85654, lng: 77.66349));
    _stations.add(const Station(id: 'Y13', name: 'Infosys Foundation Konappana Agrahara', lineId: 'yellow', lat: 12.84644, lng: 77.67119));
    _stations.add(const Station(id: 'Y14', name: 'Huskur Road', lineId: 'yellow', lat: 12.83907, lng: 77.67743));
    _stations.add(const Station(id: 'Y15', name: 'Biocon Hebbagodi', lineId: 'yellow', lat: 12.82902, lng: 77.68139));
    _stations.add(const Station(id: 'Y16', name: 'Delta Electronics Bommasandra', lineId: 'yellow', lat: 12.81942, lng: 77.68832));
  }

  void _seedSegments() {
    int segmentIdx = 1;
    void addSeg(Station a, Station b) {
      double dist = _calculateDistance(a.lat, a.lng, b.lat, b.lng);
      // Speed 34.5 km/h -> duration = (dist / 34.5) * 60
      int mins = ((dist / 34.5) * 60).round();
      if (mins < 1) mins = 1;

      final sid = 'S${segmentIdx++}';
      _segments.add(Segment(
          id: sid,
          fromStationId: a.id,
          toStationId: b.id,
          durationMins: mins,
          distanceKm: dist,
          lineId: a.lineId));
      _segments.add(Segment(
          id: '${sid}r',
          fromStationId: b.id,
          toStationId: a.id,
          durationMins: mins,
          distanceKm: dist,
          lineId: a.lineId));
    }

    // Connect stations along the lines sequentially
    Station? prevPurple;
    Station? prevGreen;
    Station? prevYellow;

    for (final s in _stations) {
      if (s.lineId == 'purple') {
        if (prevPurple != null) addSeg(prevPurple, s);
        prevPurple = s;
      } else if (s.lineId == 'green') {
        if (prevGreen != null) addSeg(prevGreen, s);
        prevGreen = s;
      } else if (s.lineId == 'yellow') {
        if (prevYellow != null) addSeg(prevYellow, s);
        prevYellow = s;
      }
    }

    // Add interchanges manually (walking distance)
    void addInterchange(String id1, String id2, int minsWalking) {
      final sid = 'I${segmentIdx++}';
      _segments.add(Segment(id: sid, fromStationId: id1, toStationId: id2, durationMins: minsWalking, distanceKm: 0.2, lineId: 'interchange'));
      _segments.add(Segment(id: '${sid}r', fromStationId: id2, toStationId: id1, durationMins: minsWalking, distanceKm: 0.2, lineId: 'interchange'));
    }

    addInterchange('MAJ', 'MAJ_G', 5);
    addInterchange('RV_G', 'RV_Y', 3);
  }

  // BMRCL Fixed distance-slab fare model (Feb 9, 2025)
  // 0-2 km: ₹10
  // 2-4 km: ₹20
  // 4-6 km: ₹30
  // 6-8 km: ₹40
  // 8-10 km: ₹50
  // ... Max ₹90
  int _fareForDistance(double totalKm) {
    if (totalKm <= 2) return 10;
    if (totalKm <= 4) return 20;
    if (totalKm <= 6) return 30;
    if (totalKm <= 8) return 40;
    if (totalKm <= 10) return 50;
    if (totalKm <= 14) return 60; // Just approximating >10 to 90.
    if (totalKm <= 18) return 70;
    if (totalKm <= 24) return 80;
    return 90;
  }

  List<Station> get allStations => List.unmodifiable(_stations);

  List<Station> searchStations(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase().trim();
    
    final containsMatches = _stations
        .where((s) => s.name.toLowerCase().contains(q))
        .toList();
    if (containsMatches.isNotEmpty) return containsMatches;

    return _stations
        .where((s) {
          final similarity = StringSimilarity.compareTwoStrings(q, s.name.toLowerCase());
          return similarity >= 0.3;
        })
        .toList()
      ..sort((a, b) => StringSimilarity.compareTwoStrings(q, b.name.toLowerCase())
          .compareTo(StringSimilarity.compareTwoStrings(q, a.name.toLowerCase())));
  }

  RouteResult computeRoute(String startId, String endId) {
    if (startId == endId) {
      return RouteResult.error('Source and destination are the same. Please change one.');
    }

    final startIdx = _stations.indexWhere((s) => s.id == startId);
    final endIdx = _stations.indexWhere((s) => s.id == endId);
    if (startIdx < 0) return RouteResult.error('Station not found: $startId');
    if (endIdx < 0) return RouteResult.error('Station not found: $endId');

    final dist = <String, int>{};
    final distKmMap = <String, double>{};
    final prev = <String, String>{};
    final unvisited = <String>{};

    for (final s in _stations) {
      dist[s.id] = 0x7FFFFFFF;
      distKmMap[s.id] = 0.0;
      unvisited.add(s.id);
    }
    dist[startId] = 0;

    while (unvisited.isNotEmpty) {
      String? current;
      int minDist = 0x7FFFFFFF;
      for (final id in unvisited) {
        final d = dist[id] ?? 0x7FFFFFFF;
        if (d < minDist) {
          minDist = d;
          current = id;
        }
      }

      if (current == null || current == endId) break;
      if (minDist == 0x7FFFFFFF) break;

      unvisited.remove(current);

      final outgoing = _segments
          .where((seg) => seg.fromStationId == current)
          .toList();

      for (final seg in outgoing) {
        final neighbor = seg.toStationId;
        if (!unvisited.contains(neighbor)) continue;
        final newDist = (dist[current] ?? 0x7FFFFFFF) + seg.durationMins;
        if (newDist < (dist[neighbor] ?? 0x7FFFFFFF)) {
          dist[neighbor] = newDist;
          distKmMap[neighbor] = (distKmMap[current] ?? 0.0) + seg.distanceKm;
          prev[neighbor] = current;
        }
      }
    }

    if (!prev.containsKey(endId) && startId != endId) {
      return RouteResult.error('No Metro route found. These stations may not be connected.');
    }

    final pathIds = <String>[];
    String? cursor = endId;
    while (cursor != null) {
      pathIds.add(cursor);
      cursor = prev[cursor];
    }
    final orderedIds = pathIds.reversed.toList();

    final pathStations =
        orderedIds.map((id) => _stations.firstWhere((s) => s.id == id)).toList();

    final totalTime = dist[endId] ?? 0;
    final totalDistanceKm = distKmMap[endId] ?? 0.0;
    final fare = _fareForDistance(totalDistanceKm);

    bool hasInterchange = false;
    Station? interchangeStation;
    for (final s in pathStations) {
      if (s.isInterchange) {
        hasInterchange = true;
        interchangeStation = s;
        break;
      }
    }

    return RouteResult(
      stations: pathStations,
      totalTimeMins: totalTime,
      totalDistanceKm: totalDistanceKm,
      fare: fare,
      hasInterchange: hasInterchange,
      interchangeStation: interchangeStation,
    );
  }

  Station? stationById(String id) {
    try {
      return _stations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Segment? segmentBetween(String fromId, String toId) {
    try {
      return _segments.firstWhere(
          (s) => s.fromStationId == fromId && s.toStationId == toId);
    } catch (_) {
      return null;
    }
  }
}
